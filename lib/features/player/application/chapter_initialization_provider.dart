import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';

final chapterInitializationProvider = FutureProvider.family<Audiobook, String>((
  ref,
  bookId,
) async {
  final watch = Stopwatch()..start();
  final repo = ref.read(audiobookRepositoryProvider);
  final current = await repo.getById(bookId);
  if (current == null) {
    throw StateError('Book $bookId not found');
  }

  if (current.chapters.every((c) => c.durationMs != null)) {
    watch.stop();
    log.d(
      '[ChapterInit] Used cached durations for ${current.chapters.length} '
      'chapters in ${watch.elapsedMilliseconds}ms',
    );
    return current;
  }

  final metadataService = ref.read(metadataServiceProvider);
  final missingDurations = current.chapters
      .where((chapter) => chapter.durationMs == null)
      .length;

  final updatedChapters = await Future.wait(
    current.chapters.map((chapter) async {
      if (chapter.durationMs != null) return chapter;
      final durationMs = await metadataService.getDurationMs(chapter.uri);
      // Store 0 (or -1) as a sentinel so we don't retry forever
      return chapter.copyWith(durationMs: durationMs ?? 0);
    }),
  );

  final totalMs = updatedChapters.fold<int>(
    0,
    (sum, c) => sum + (c.durationMs ?? 0),
  );

  final enriched = current.copyWith(
    chapters: updatedChapters,
    totalDurationMs: totalMs,
  );

  await repo.save(enriched);
  watch.stop();
  final failedDurations = updatedChapters
      .where((chapter) => chapter.durationMs == 0)
      .length;
  log.i(
    '[ChapterInit] Initialized $missingDurations/${current.chapters.length} '
    'durations, $failedDurations failed, total ${totalMs}ms '
    'in ${watch.elapsedMilliseconds}ms',
  );

  return enriched;
});
