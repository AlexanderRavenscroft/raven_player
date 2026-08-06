import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/chapter_initialization_provider.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
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
  late final ProviderSubscription<AsyncValue<Audiobook>>
  _chapterInitializationSub;

  @override
  void initState() {
    super.initState();
    _chapterInitializationSub = ref.listenManual<AsyncValue<Audiobook>>(
      chapterInitializationProvider(widget.book.id),
      (previous, next) {
        next.whenData(_loadInitializedBook);
      },
      fireImmediately: true,
    );
  }

  void _loadInitializedBook(Audiobook initializedBook) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(playerProvider.notifier).load(initializedBook));
    });
  }

  @override
  void dispose() {
    _chapterInitializationSub.close();
    super.dispose();
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
                  showLoadingSkeleton: isLoading,
                ),
              ),

              SizedBox(
                height: math.max(
                  MediaQuery.of(context).size.height * 0.06,
                  kMinInteractiveDimension,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !isPlayerLockEnabled,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: PlayerIconButton.chapter(
                        icon: AppIcons.skipPrevious,
                        tooltip: context.l10n.playerPreviousChapterAction,
                        onPressed: () async {
                          await ref.read(audioHandlerProvider).skipToPrevious();
                          ref
                              .read(sleepTimerProvider.notifier)
                              .resetFromListeningActivity();
                        },
                      ),
                    ),
                    ChapterDropdown(book: widget.book),
                    Visibility(
                      visible: !isPlayerLockEnabled,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: PlayerIconButton.chapter(
                        icon: AppIcons.skipNext,
                        tooltip: context.l10n.playerNextChapterAction,
                        onPressed: () async {
                          await ref.read(audioHandlerProvider).skipToNext();
                          ref
                              .read(sleepTimerProvider.notifier)
                              .resetFromListeningActivity();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const PlayProgressBar(),

              Visibility(
                visible: !isPlayerLockEnabled,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PlayerIconButton.seek(
                      icon: AppIcons.fastRewind,
                      tooltip: context.l10n.playerRewindSecondsAction(
                        AppAudioHandler.longSeekOffset.inSeconds,
                      ),
                      onPressed: () async {
                        await ref
                            .read(audioHandlerProvider)
                            .rewind(AppAudioHandler.longSeekOffset);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    PlayerIconButton.seek(
                      icon: AppIcons.replay10,
                      tooltip: context.l10n.playerRewindSecondsAction(
                        AppAudioHandler.defaultSeekOffset.inSeconds,
                      ),
                      onPressed: () async {
                        await ref.read(audioHandlerProvider).rewind();
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    const PlayButton(),
                    PlayerIconButton.seek(
                      icon: AppIcons.forward10,
                      tooltip: context.l10n.playerForwardSecondsAction(
                        AppAudioHandler.defaultSeekOffset.inSeconds,
                      ),
                      onPressed: () async {
                        await ref.read(audioHandlerProvider).fastForward();
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                    PlayerIconButton.seek(
                      icon: AppIcons.fastForward,
                      tooltip: context.l10n.playerForwardSecondsAction(
                        AppAudioHandler.longSeekOffset.inSeconds,
                      ),
                      onPressed: () async {
                        await ref
                            .read(audioHandlerProvider)
                            .fastForward(AppAudioHandler.longSeekOffset);
                        ref
                            .read(sleepTimerProvider.notifier)
                            .resetFromListeningActivity();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
