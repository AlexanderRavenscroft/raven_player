import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';

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
      final durationMs = await metadataService.getDurationMs(chapter.uri);
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
  return enriched;
});
