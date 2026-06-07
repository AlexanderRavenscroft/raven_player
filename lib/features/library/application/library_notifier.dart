import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/library/application/library_scanner.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';

class LibraryNotifier extends AsyncNotifier<List<Audiobook>> {
  AudiobookRepository get _repo => ref.read(audiobookRepositoryProvider);
  LibraryScanner get _scanner => ref.read(libraryScannerProvider);
  AudiobookEnricher get _enricher => ref.read(audiobookEnricherProvider);

  @override
  Future<List<Audiobook>> build() async {
    final home = ref.watch(settingsProvider.select((s) => s.homeFolderUri));
    return _loadLibrary(home);
  }

  Future<void> rescan() async {
    final home = ref.read(settingsProvider).homeFolderUri;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadLibrary(home));
  }

  Future<List<Audiobook>> _loadLibrary(String? home) async {
    if (home == null) {
      return [];
    }

    final existing = await _repo.getAll();

    final folderChanged =
        existing.isNotEmpty &&
        !existing.any((b) => b.folderUri.startsWith(home));

    if (folderChanged) {
      await _repo.clearAll();
      state = const AsyncData([]);
    } else if (existing.isNotEmpty) {
      state = AsyncData(existing);
    }

    final scanned = await _scanner.scan(home);

    await _repo.mergeScanResults(scanned);

    final merged = await _repo.getAll();
    final needsEnrich = merged.where((b) => b.needsMetadataScan).toList();
    if (needsEnrich.isNotEmpty) {
      await _enricher.enrichAll(needsEnrich);
    }

    return _repo.getAll();
  }

  Future<void> renameAudiobook(Audiobook book, String newTitle) async {
    final renamed = book.copyWith(title: newTitle);
    await _repo.save(renamed);
    _patchBookInState(renamed);
  }

  Future<void> toggleReadStatus(Audiobook book) async {
    final toggled = book.copyWith(isRead: !book.isRead);
    await _repo.save(toggled);
    _patchBookInState(toggled);
  }

  Future<void> markAsRead(Audiobook book) async {
    final read = book.copyWith(isRead: true);
    await _repo.save(read);
    _patchBookInState(read);
  }

  void _patchBookInState(Audiobook updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final b in current) b.id == updated.id ? updated : b,
    ]);
  }
}

final libraryScannerProvider = Provider<LibraryScanner>((ref) {
  return LibraryScanner();
});

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, List<Audiobook>>(
  LibraryNotifier.new,
);
