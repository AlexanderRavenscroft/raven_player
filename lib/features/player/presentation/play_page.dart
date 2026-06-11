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
import 'package:raven_player/features/player/presentation/player_icon_button.dart';
import 'package:raven_player/features/player/presentation/action_toolbar.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/others/audiobook_cover.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlayPage extends ConsumerStatefulWidget {
  final Audiobook book;
  const PlayPage({super.key, required this.book});

  @override
  ConsumerState<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends ConsumerState<PlayPage> {
  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await ref.read(playerProvider.notifier).load(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    //* Keep shake detection while playing
    ref.watch(sleepTimerShakeProvider);

    final chapterInitialization = ref.watch(
      chapterInitializationProvider(widget.book.id),
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
        appBar: PlayAppBar(book: widget.book),
        body: chapterInitialization.when(
          loading: () => _buildPlayPageContent(context, ref, widget.book, true),
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
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Skeletonizer(
          enabled: isLoading,
          child: Column(
            children: [
              const ActionToolbar(),
              const SizedBox(height: AppSpacing.md),
              AudiobookLengthDisplay(book: initializedBook),
              const SizedBox(height: AppSpacing.md),

              PlayButton.cover(
                coverWidget: AudiobookCover(
                  book: initializedBook,
                  isOnTile: false,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.06,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!isPlayerLockEnabled)
                      PlayerIconButton.chapter(
                        icon: AppIcons.skipPrevious,
                        onPressed: () async {
                          await ref
                              .read(playerProvider.notifier)
                              .seekToPrevious();
                          ref
                              .read(sleepTimerProvider.notifier)
                              .resetFromListeningActivity();
                        },
                      ),
                    const ChapterDropdown(),
                    if (!isPlayerLockEnabled)
                      PlayerIconButton.chapter(
                        icon: AppIcons.skipNext,
                        onPressed: () async {
                          await ref.read(playerProvider.notifier).seekToNext();
                          ref
                              .read(sleepTimerProvider.notifier)
                              .resetFromListeningActivity();
                        },
                      ),
                  ],
                ),
              ),
              const PlayProgressBar(),

              if (!isPlayerLockEnabled)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PlayerIconButton.seek(
                      icon: AppIcons.fastRewind,
                      onPressed: () async {
                        await ref
                            .read(playerProvider.notifier)
                            .seekByOffset(-60);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    PlayerIconButton.seek(
                      icon: AppIcons.replay10,
                      onPressed: () async {
                        await ref
                            .read(playerProvider.notifier)
                            .seekByOffset(-10);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    const PlayButton(),
                    PlayerIconButton.seek(
                      icon: AppIcons.forward10,
                      onPressed: () async {
                        await ref
                            .read(playerProvider.notifier)
                            .seekByOffset(10);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    PlayerIconButton.seek(
                      icon: AppIcons.fastForward,
                      onPressed: () async {
                        await ref
                            .read(playerProvider.notifier)
                            .seekByOffset(60);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
