import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/chapter_initialization_provider.dart';
import 'package:raven_player/features/player/presentation/audiobook_length_display.dart';
import 'package:raven_player/features/player/presentation/play_app_bar.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/audiobook_cover.dart';

class PlayPage extends ConsumerWidget {
  final Audiobook book;
  const PlayPage({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterInitialization = ref.watch(
      chapterInitializationProvider(book),
    );

    return Scaffold(
      appBar: PlayAppBar(book: book),
      body: chapterInitialization.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading audiobook: $error')),
        data: (initializedBook) =>
            _buildPlayPageContent(context, ref, initializedBook),
      ),
    );
  }

  Widget _buildPlayPageContent(
    BuildContext context,
    WidgetRef ref,
    Audiobook initializedBook,
  ) {
    final total = initializedBook.totalDuration;
    final totalLabel = total != null ? _formatDuration(total) : '—';
    return Column(
      children: [
        //* BAR && DISPLAY
        // PlayActionToolbar(),
        // AudiobookLengthDisplay(book: book),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        //* COVER
        AudiobookCover(book: initializedBook, isOnTile: false),
        const SizedBox(height: 12),
        Text(
          'Total duration: $totalLabel',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        //* CHAPTER CONTROLS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SeekChapterButton(
            //   icon: Icons.skip_previous_outlined,
            //   onPressed: () =>
            //       ref.read(playerProvider.notifier).player.seekToPrevious(),
            // ),
            // PlayChapterDropdown(book: book),
            // SeekChapterButton(
            //   icon: Icons.skip_next_outlined,
            //   onPressed: () =>
            //       ref.read(playerProvider.notifier).player.seekToNext(),
            // ),
          ],
        ),

        //* PLAYBACK CONTROLLS
        // PlayProgressBar(book: book),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // SeekButton(
            //   icon: Icons.fast_rewind_outlined,
            //   onPressed: () async => await ref
            //       .read(playerProvider.notifier)
            //       .seekByOffset(-60, book),
            // ),
            // SeekButton(
            //   icon: Icons.replay_30_outlined,
            //   onPressed: () async => await ref
            //       .read(playerProvider.notifier)
            //       .seekByOffset(-10, book),
            // ),
            // PlayButton(),
            // SeekButton(
            //   icon: Icons.forward_30_outlined,
            //   onPressed: () async => await ref
            //       .read(playerProvider.notifier)
            //       .seekByOffset(10, book),
            // ),
            // SeekButton(
            //   icon: Icons.fast_forward_outlined,
            //   onPressed: () async => await ref
            //       .read(playerProvider.notifier)
            //       .seekByOffset(60, book),
            // ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
