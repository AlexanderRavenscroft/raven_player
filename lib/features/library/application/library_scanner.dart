import 'package:raven_player/core/saf/saf.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

class LibraryScanner {
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

  bool _isAudio(SafEntry e) {
    if (e.isDir) return false;
    if (e.mime != null && _audioMimes.contains(e.mime)) return true;
    final n = e.name?.toLowerCase() ?? '';
    return _audioExts.any(n.endsWith);
  }

  /// Scans the home folder. Each subfolder = one audiobook.
  /// Returns books that contain at least one audio file.
  Future<List<Audiobook>> scan(String homeUri) async {
    final top = await Saf.listDir(homeUri);
    final books = <Audiobook>[];

    for (final folder in top.where((e) => e.isDir)) {
      final inner = await Saf.listDir(folder.uri);
      final audioFiles = inner.where(_isAudio).toList()
        ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));

      if (audioFiles.isEmpty) continue;

      final chapters = audioFiles
          .map(
            (f) =>
                Chapter(name: f.name ?? '(unnamed)', uri: f.uri, mime: f.mime),
          )
          .toList();

      books.add(
        Audiobook(
          id: folder.uri,
          title: folder.name ?? '(unnamed)',
          folderUri: folder.uri,
          chapters: chapters,
        ),
      );
    }

    return books;
  }
}
