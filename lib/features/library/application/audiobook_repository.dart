import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookRepository {
  Future<List<Audiobook>> getAll() async {
    final box = await HiveBoxes.audiobooks();
    return box.values.toList();
  }

  Future<Audiobook?> getById(String id) async {
    final box = await HiveBoxes.audiobooks();
    return box.get(id);
  }

  Future<void> clearAll() async {
    final box = await HiveBoxes.audiobooks();
    await box.clear();
  }

  Future<void> save(Audiobook book) async {
    final box = await HiveBoxes.audiobooks();
    await box.put(book.id, book);
  }

  /// Merge:
  /// - keep existing books by id (preserves progress)
  /// - refresh title/chapters from scan
  /// - add new, remove missing
  Future<void> mergeScanResults(List<Audiobook> scanned) async {
    final box = await HiveBoxes.audiobooks();
    final scannedIds = scanned.map((b) => b.id).toSet();
    final existingIds = box.keys.cast<String>().toSet();

    // delete removed
    final toDelete = existingIds.difference(scannedIds);
    await box.deleteAll(toDelete);

    // upsert
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
  }
}

final audiobookRepositoryProvider = Provider<AudiobookRepository>((ref) {
  return AudiobookRepository();
});
