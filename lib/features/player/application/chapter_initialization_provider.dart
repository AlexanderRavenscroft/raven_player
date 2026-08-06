import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';

final chapterInitializationProvider = FutureProvider.family<Audiobook, String>((
  ref,
  bookId,
) async {
  final repo = ref.read(audiobookRepositoryProvider);
  final current = await repo.getById(bookId);

  if (current == null) {
    throw StateError('Book $bookId not found');
  }

  final hasAllChapterDurations = current.chapters.every(
    (chapter) => chapter.durationMs != null,
  );
  if (hasAllChapterDurations && current.totalDurationMs != null) {
    return current;
  }

  final metadataService = ref.read(metadataServiceProvider);
  final updatedChapters = await Future.wait(
    current.chapters.map((chapter) async {
      if (chapter.durationMs != null) return chapter;
      final int? durationMs;

      try {
        durationMs = await metadataService.getDurationMs(chapter.uri);
      } on PlatformException catch (error) {
        log.e('Duration scan failed: ${error.code}.');
        return chapter;
      } on MissingPluginException {
        log.e('Duration scan failed: native SAF plugin is unavailable.');
        return chapter;
      }

      return durationMs == null
          ? chapter
          : chapter.copyWith(durationMs: durationMs);
    }),
  );

  final durationsByUri = {
    for (final chapter in updatedChapters)
      if (chapter.durationMs != null) chapter.uri: chapter.durationMs!,
  };
  final enriched = await repo.updateById(bookId, (latest) {
    final latestChapters = latest.chapters.map((chapter) {
      if (chapter.durationMs != null) return chapter;

      final durationMs = durationsByUri[chapter.uri];
      return durationMs == null
          ? chapter
          : chapter.copyWith(durationMs: durationMs);
    }).toList();
    final hasAllLatestDurations = latestChapters.every(
      (chapter) => chapter.durationMs != null,
    );
    final latestTotalMs = hasAllLatestDurations
        ? latestChapters.fold<int>(
            0,
            (sum, chapter) => sum + chapter.durationMs!,
          )
        : latest.totalDurationMs;

    return latest.copyWith(
      chapters: latestChapters,
      totalDurationMs: latestTotalMs,
    );
  });
  if (enriched == null) {
    throw StateError('Book $bookId not found');
  }

  return enriched;
});
