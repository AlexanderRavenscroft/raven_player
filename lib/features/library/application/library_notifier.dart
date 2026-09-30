import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/saf/saf_uri_utils.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/library/application/library_scanner.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';

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
        !existing.any(
          (book) =>
              isSafDocumentInTree(documentUri: book.folderUri, treeUri: home),
        );

    if (!folderChanged && existing.isNotEmpty) {
      state = AsyncData(existing);
    }

    final scanned = await _scanner.scan(home);

    await _repo.mergeScanResults(scanned);

    final merged = await _repo.getAll();
    final needsEnrich = merged.where((book) => book.needsMetadataScan).toList();
    if (needsEnrich.isNotEmpty) {
      await _enricher.enrichAll(needsEnrich);
    }

    final library = await _repo.getAll();
    await _clearLastOpenedAudiobookIfMissing(library);
    return library;
  }

  Future<void> renameAudiobook(Audiobook book, String newTitle) async {
    final renamed = await _repo.updateById(
      book.id,
      (current) => current.copyWith(title: newTitle),
    );
    if (renamed == null) return;

    _patchBookInState(renamed);
  }

  Future<void> toggleReadStatus(Audiobook book) async {
    final toggled = await _repo.updateById(
      book.id,
      (current) => current.copyWith(isRead: !current.isRead),
    );
    if (toggled == null) return;

    _patchBookInState(toggled);
  }

  Future<void> markAsRead(Audiobook book) async {
    final read = await _repo.updateById(
      book.id,
      (current) => current.copyWith(isRead: true),
    );
    if (read == null) return;

    _patchBookInState(read);
    if (ref.read(settingsProvider).lastOpenedAudiobookId == read.id) {
      await ref.read(settingsProvider.notifier).clearLastOpenedAudiobookId();
    }
  }

  void _patchBookInState(Audiobook updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final b in current) b.id == updated.id ? updated : b,
    ]);
  }

  Future<void> _clearLastOpenedAudiobookIfMissing(
    List<Audiobook> library,
  ) async {
    final audiobookId = ref.read(settingsProvider).lastOpenedAudiobookId;
    if (audiobookId == null || library.any((book) => book.id == audiobookId)) {
      return;
    }

    try {
      await ref.read(settingsProvider.notifier).clearLastOpenedAudiobookId();
    } catch (_) {
      log.e('Failed to clear the removed last opened audiobook.');
    }
  }
}

final libraryScannerProvider = Provider<LibraryScanner>((ref) {
  return LibraryScanner();
});

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, List<Audiobook>>(
  LibraryNotifier.new,
);
