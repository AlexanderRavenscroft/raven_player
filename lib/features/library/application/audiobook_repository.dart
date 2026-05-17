import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookRepository {
  final UserSettingsRepository _settingsRepo;

  AudiobookRepository(this._settingsRepo);

  Future<List<Audiobook>> getAll() async {
    final box = await HiveBoxes.audiobooks();
    return box.values.toList();
  }

  Future<String?> getHomeFolderUri() async {
    final settings = await _settingsRepo.load();
    return settings.homeFolderUri;
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
        final merged = existing.copyWith(
          folderUri: book.folderUri,
          chapters: book.chapters,
        );
        await box.put(book.id, merged);
      }
    }
  }
}

final audiobookRepositoryProvider = Provider<AudiobookRepository>((ref) {
  return AudiobookRepository(ref.read(userSettingsRepositoryProvider));
});
