import 'package:raven_player/core/saf/saf.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

class LibraryScanner {
  static const _fallbackName = '(unnamed)';
  static const _audioMimes = {
    'audio/mpeg',
    'audio/mp4',
    'audio/x-m4a',
    'audio/m4b',
    'audio/flac',
    'audio/ogg',
    'audio/x-flac',
  };
  static const _audioExts = ['.mp3', '.m4a', '.m4b', '.flac', '.ogg'];

  /// Scans the home folder. Each subfolder = one audiobook.
  /// Returns books that contain at least one audio file.
  Future<List<Audiobook>> scan(String homeUri) async {
    final top = await Saf.listDir(homeUri);
    final books = <Audiobook>[];
    final folders = top.where((e) => e.isDir).toList();

    for (final folder in folders) {
      final inner = await Saf.listDir(folder.uri);

      final audioFiles = inner.where(_isAudio).toList()
        ..sort((a, b) => _naturalCompare(a.name ?? '', b.name ?? ''));

      if (audioFiles.isEmpty) continue;

      final chapters = audioFiles
          .map(
            (f) => Chapter(
              name: f.name ?? _fallbackName,
              uri: f.uri,
              mime: f.mime,
            ),
          )
          .toList();

      books.add(
        Audiobook(
          id: folder.uri,
          title: folder.name ?? _fallbackName,
          folderUri: folder.uri,
          chapters: chapters,
        ),
      );
    }
    return books;
  }

  bool _isAudio(SafEntry entry) {
    if (entry.isDir) return false;
    if (entry.mime != null && _audioMimes.contains(entry.mime)) return true;
    final name = entry.name?.toLowerCase() ?? '';
    return _audioExts.any(name.endsWith);
  }

  final RegExp _naturalPartPattern = RegExp(r'\d+|\D+');

  int _naturalCompare(String left, String right) {
    final leftParts = _naturalPartPattern
        .allMatches(left.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();

    final rightParts = _naturalPartPattern
        .allMatches(right.toLowerCase())
        .map((match) => match.group(0)!)
        .toList();

    final partCount = leftParts.length < rightParts.length
        ? leftParts.length
        : rightParts.length;

    for (var index = 0; index < partCount; index++) {
      final leftPart = leftParts[index];
      final rightPart = rightParts[index];

      final leftNumber = BigInt.tryParse(leftPart);
      final rightNumber = BigInt.tryParse(rightPart);

      if (leftNumber != null && rightNumber != null) {
        final numberResult = leftNumber.compareTo(rightNumber);

        if (numberResult != 0) {
          return numberResult;
        }

        // Numeric values are equal, for example "2" and "002".
        // Prefer the shorter representation.
        final lengthResult = leftPart.length.compareTo(rightPart.length);

        if (lengthResult != 0) {
          return lengthResult;
        }

        continue;
      }

      final textResult = leftPart.compareTo(rightPart);

      if (textResult != 0) {
        return textResult;
      }
    }

    final partCountResult = leftParts.length.compareTo(rightParts.length);

    if (partCountResult != 0) {
      return partCountResult;
    }

    // Provides deterministic ordering when names differ only by case.
    return left.compareTo(right);
  }
}
