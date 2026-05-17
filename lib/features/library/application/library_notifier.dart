import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/library/application/library_scanner.dart';
import 'package:raven_player/models/audiobook.dart';

class LibraryNotifier extends AsyncNotifier<List<Audiobook>> {
  AudiobookRepository get _repo => ref.read(audiobookRepositoryProvider);
  LibraryScanner get _scanner => ref.read(libraryScannerProvider);

  @override
  Future<List<Audiobook>> build() async {
    final existing = await _repo.getAll();

    if (existing.isEmpty) {
      final home = await _repo.getHomeFolderUri();
      if (home != null) {
        final scanned = await _scanner.scan(home);
        await _repo.mergeScanResults(scanned);
        return _repo.getAll();
      }
    }

    return existing;
  }

  Future<void> rescan() async {
    final home = await _repo.getHomeFolderUri();
    if (home == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final scanned = await _scanner.scan(home);
      await _repo.mergeScanResults(scanned);
      return _repo.getAll();
    });
  }

  Future<void> renameAudiobook(Audiobook book, String newTitle) async {
    final renamed = book.copyWith(title: newTitle);
    await _repo.save(renamed);
    // refresh state
    state = AsyncData(await _repo.getAll());
  }

  Future<void> toggleReadStatus(Audiobook book) async {
    final toggled = book.copyWith(isRead: !book.isRead);
    await _repo.save(toggled);
    // refresh state
    state = AsyncData(await _repo.getAll());
  }
}

final libraryScannerProvider = Provider<LibraryScanner>((ref) {
  return LibraryScanner();
});

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, List<Audiobook>>(
  LibraryNotifier.new,
);
