import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';

final chapterInitializationProvider =
    FutureProvider.family<Audiobook, Audiobook>((ref, book) async {
      // Already have all durations — nothing to do
      final saved = await ref
          .read(audiobookRepositoryProvider)
          .getById(book.id);
      final current = saved ?? book;
      if (current.chapters.every((c) => c.durationMs != null)) return current;

      final metadataService = ref.read(metadataServiceProvider);

      // Fetch duration for every chapter that's missing one
      final updatedChapters = await Future.wait(
        current.chapters.map((chapter) async {
          if (chapter.durationMs != null) return chapter;
          final meta = await metadataService.getMetadata(chapter.uri);
          return chapter.copyWith(durationMs: meta?.durationMs);
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

      await ref.read(audiobookRepositoryProvider).save(enriched);

      return enriched;
    });
