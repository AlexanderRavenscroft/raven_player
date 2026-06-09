import 'package:flutter/material.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/chapter_initialization_provider.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_shake_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/player/presentation/audiobook_length_display.dart';
import 'package:raven_player/features/player/presentation/chapter_dropdown.dart';
import 'package:raven_player/features/player/presentation/play_app_bar.dart';
import 'package:raven_player/features/player/presentation/play_button.dart';
import 'package:raven_player/features/player/presentation/play_progress_bar.dart';
import 'package:raven_player/features/player/presentation/seek_button.dart';
import 'package:raven_player/features/player/presentation/seek_chapter_button.dart';
import 'package:raven_player/features/player/presentation/action_toolbar.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/others/audiobook_cover.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
    ref.watch(sleepTimerShakeProvider);

    final chapterInitialization = ref.watch(
      chapterInitializationProvider(widget.enrichedBook.id),
    );

    final backArrowBacksToLibrary = ref.watch(
      settingsProvider.select((s) => s.backArrowBacksToLibrary),
    );

    return PopScope(
      canPop: backArrowBacksToLibrary,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        FlutterAppMinimizerPlus.minimizeApp();
      },
      child: Scaffold(
        appBar: PlayAppBar(book: widget.enrichedBook),
        body: chapterInitialization.when(
          loading: () =>
              _buildPlayPageContent(context, ref, widget.enrichedBook, true),
          error: (error, stackTrace) => Center(
            child: Text(context.l10n.playerLoadingError(error.toString())),
          ),
          data: (initializedBook) =>
              _buildPlayPageContent(context, ref, initializedBook, false),
        ),
      ),
    );
  }

  Widget _buildPlayPageContent(
    BuildContext context,
    WidgetRef ref,
    Audiobook initializedBook,
    bool isLoading,
  ) {
    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );
    return Skeletonizer(
      enabled: isLoading,
      child: Column(
        children: [
          //* BAR && DISPLAY
          const ActionToolbar(),
          const SizedBox(height: AppSpacing.md),
          AudiobookLengthDisplay(book: initializedBook),
          const SizedBox(height: AppSpacing.md),

          //* COVER
          PlayButton(
            asStandaloneButton: false,
            coverWidget: AudiobookCover(book: initializedBook, isOnTile: false),
          ),

          //* CHAPTER CONTROLS
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isPlayerLockEnabled)
                  SeekChapterButton(
                    icon: AppIcons.skipPrevious,
                    onPressed: () {
                      ref.read(playerProvider.notifier).seekToPrevious();
                      ref
                          .read(sleepTimerProvider.notifier)
                          .resetFromListeningActivity();
                    },
                  ),
                ChapterDropdown(book: initializedBook),
                if (!isPlayerLockEnabled)
                  SeekChapterButton(
                    icon: AppIcons.skipNext,
                    onPressed: () {
                      ref.read(playerProvider.notifier).seekToNext();
                      ref
                          .read(sleepTimerProvider.notifier)
                          .resetFromListeningActivity();
                    },
                  ),
              ],
            ),
          ),
          //* PLAYBACK CONTROLLS
          const PlayProgressBar(),

          if (!isPlayerLockEnabled)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SeekButton(
                  icon: AppIcons.fastRewind,
                  onPressed: () async {
                    await ref.read(playerProvider.notifier).seekByOffset(-60);
                    ref
                        .read(sleepTimerProvider.notifier)
                        .resetFromListeningActivity();
                  },
                ),
                SeekButton(
                  icon: AppIcons.replay10,
                  onPressed: () async {
                    await ref.read(playerProvider.notifier).seekByOffset(-10);
                    ref
                        .read(sleepTimerProvider.notifier)
                        .resetFromListeningActivity();
                  },
                ),
                const PlayButton(),
                SeekButton(
                  icon: AppIcons.forward10,
                  onPressed: () async {
                    await ref.read(playerProvider.notifier).seekByOffset(10);
                    ref
                        .read(sleepTimerProvider.notifier)
                        .resetFromListeningActivity();
                  },
                ),
                SeekButton(
                  icon: AppIcons.fastForward,
                  onPressed: () async {
                    await ref.read(playerProvider.notifier).seekByOffset(60);
                    ref
                        .read(sleepTimerProvider.notifier)
                        .resetFromListeningActivity();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
