import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:synchronized/synchronized.dart';

class AudiobookRepository {
  final _lock = Lock();

  Future<List<Audiobook>> getAll() async {
    return _lock.synchronized(() async {
      final box = await HiveBoxes.audiobooks();
      return box.values.toList();
    });
  }

  Future<Audiobook?> getById(String id) async {
    return _lock.synchronized(() async {
      final box = await HiveBoxes.audiobooks();
      return box.get(id);
    });
  }

  Future<void> clearAll() async {
    await _lock.synchronized(() async {
      final box = await HiveBoxes.audiobooks();
      await box.clear();
    });
  }

  Future<void> save(Audiobook book) async {
    await _lock.synchronized(() async {
      final box = await HiveBoxes.audiobooks();
      await box.put(book.id, book);
    });
  }

  /// Merges scan results into the persisted library.
  /// Preserves user-owned state on existing books and refreshes chapter data.
  Future<void> mergeScanResults(List<Audiobook> scanned) async {
    await _lock.synchronized(() async {
      final box = await HiveBoxes.audiobooks();
      final scannedIds = scanned.map((b) => b.id).toSet();
      final existingIds = box.keys.cast<String>().toSet();

      await box.deleteAll(existingIds.difference(scannedIds));

      for (final book in scanned) {
        final existing = box.get(book.id);
        if (existing == null) {
          await box.put(book.id, book);
        } else {
          final mergedChapters = book.chapters.map((scannedChapter) {
            final existingChapter = existing.chapters.firstWhere(
              (c) => c.uri == scannedChapter.uri,
              orElse: () => scannedChapter,
            );
            return scannedChapter.copyWith(
              durationMs: existingChapter.durationMs,
            );
          }).toList();

          final merged = existing.copyWith(
            folderUri: book.folderUri,
            chapters: mergedChapters,
          );
          await box.put(book.id, merged);
        }
      }
    });
  }
}

final audiobookRepositoryProvider = Provider<AudiobookRepository>((ref) {
  return AudiobookRepository();
});
