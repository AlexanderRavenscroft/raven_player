import 'package:flutter/services.dart';
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

  bool _isAudio(SafEntry entry) {
    if (entry.isDir) return false;
    if (entry.mime != null && _audioMimes.contains(entry.mime)) return true;
    final name = entry.name?.toLowerCase() ?? '';
    return _audioExts.any(name.endsWith);
  }

  /// Scans the home folder. Each subfolder = one audiobook.
  /// Returns books that contain at least one audio file.
  Future<List<Audiobook>> scan(String homeUri) async {
    final top = await Saf.listDir(homeUri);
    final books = <Audiobook>[];
    final folders = top.where((e) => e.isDir).toList();

    for (final folder in folders) {
      final List<SafEntry> inner;

      try {
        inner = await Saf.listDir(folder.uri);
      } on PlatformException {
        continue;
      }

      final audioFiles = inner.where(_isAudio).toList()
        ..sort(
          (a, b) => (a.name ?? '').toLowerCase().compareTo(
            (b.name ?? '').toLowerCase(),
          ),
        );

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
}
