import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/audiobook_enricher.dart';
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
    if (home == null) return [];

    final scanned = await _scanner.scan(home);
    await _repo.mergeScanResults(scanned);

    final merged = await _repo.getAll();

    final needsEnrich = merged.where((b) => !_isEnriched(b)).toList();
    if (needsEnrich.isNotEmpty) await _enricher.enrichAll(needsEnrich);

    return _repo.getAll();
  }

  Future<void> rescan() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final home = ref.read(settingsProvider.select((s) => s.homeFolderUri));
      if (home == null) return state.value ?? [];

      final scanned = await _scanner.scan(home);
      await _repo.mergeScanResults(scanned);

      // force = true re-extracts covers + metadata for everything
      await _enricher.enrichAll(await _repo.getAll(), force: true);
      return _repo.getAll();
    });
  }

  bool _isEnriched(Audiobook b) => b.author != null && b.coverPath != null;

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
