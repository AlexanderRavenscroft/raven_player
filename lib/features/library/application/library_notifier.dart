import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final totalWatch = Stopwatch()..start();

    if (home == null) {
      log.d('[Library] No folder selected');
      return [];
    }

    final hiveLoadWatch = Stopwatch()..start();
    final existing = await _repo.getAll();
    hiveLoadWatch.stop();
    log.d(
      '[Library] Loaded ${existing.length} cached books '
      'in ${hiveLoadWatch.elapsedMilliseconds}ms',
    );

    final folderChanged =
        existing.isNotEmpty &&
        !existing.any((b) => b.folderUri.startsWith(home));

    if (folderChanged) {
      log.d('[Library] Folder changed, clearing cached library');
      await _repo.clearAll();
      state = const AsyncData([]);
    } else if (existing.isNotEmpty) {
      state = AsyncData(existing);
    }

    final scanWatch = Stopwatch()..start();
    final scanned = await _scanner.scan(home);
    scanWatch.stop();
    log.d(
      '[Library] Scan returned ${scanned.length} books '
      'in ${scanWatch.elapsedMilliseconds}ms',
    );

    final mergeWatch = Stopwatch()..start();
    await _repo.mergeScanResults(scanned);
    mergeWatch.stop();
    log.d('[Library] Merge finished in ${mergeWatch.elapsedMilliseconds}ms');

    final merged = await _repo.getAll();
    final needsEnrich = merged.where((b) => b.needsMetadataScan).toList();
    if (needsEnrich.isNotEmpty) {
      final enrichWatch = Stopwatch()..start();
      await _enricher.enrichAll(needsEnrich);
      enrichWatch.stop();
      log.d(
        '[Library] Enriched ${needsEnrich.length} books '
        'in ${enrichWatch.elapsedMilliseconds}ms',
      );
    }

    final loaded = await _repo.getAll();
    totalWatch.stop();
    log.i(
      '[Library] Ready with ${loaded.length} books '
      'in ${totalWatch.elapsedMilliseconds}ms',
    );
    return loaded;
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
