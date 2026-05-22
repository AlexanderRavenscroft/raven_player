import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/chapter_initialization_provider.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/presentation/audiobook_length_display.dart';
import 'package:raven_player/features/player/presentation/chapter_dropdown.dart';
import 'package:raven_player/features/player/presentation/play_app_bar.dart';
import 'package:raven_player/features/player/presentation/play_button.dart';
import 'package:raven_player/features/player/presentation/play_progress_bar.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/audiobook_cover.dart';

class PlayPage extends ConsumerStatefulWidget {
  final Audiobook enrichedBook;
  const PlayPage({super.key, required this.enrichedBook});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlayer();
    });
  }

  Future<void> _initializePlayer() async {
    await ref.read(playerProvider.notifier).load(widget.enrichedBook);
  }

  @override
  Widget build(BuildContext context) {
    final chapterInitialization = ref.watch(
      chapterInitializationProvider(widget.enrichedBook),
    );

    return Scaffold(
      appBar: PlayAppBar(book: widget.enrichedBook),
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
    return Column(
      children: [
        //* BAR && DISPLAY
        // PlayActionToolbar(),
        AudiobookLengthDisplay(book: initializedBook),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        //* COVER
        AudiobookCover(book: initializedBook, isOnTile: false),

        //* CHAPTER CONTROLS
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SeekChapterButton(
            //   icon: Icons.skip_previous_outlined,
            //   onPressed: () =>
            //       ref.read(playerProvider.notifier).player.seekToPrevious(),
            // ),
            ChapterDropdown(book: initializedBook),
            // SeekChapterButton(
            //   icon: Icons.skip_next_outlined,
            //   onPressed: () =>
            //       ref.read(playerProvider.notifier).player.seekToNext(),
            // ),
          ],
        ),

        //* PLAYBACK CONTROLLS
        PlayProgressBar(),
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
            PlayButton(),
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
}
