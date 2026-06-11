import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/loading/app_linear_progress_indicator.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class PlayProgressBar extends ConsumerWidget {
  static const double _progressBarHeightRatio = 0.05;
  static const double _progressBarWidthRatio = 0.92;
  static const double _barHeightRatio = 0.01;
  static const double _thumbRadiusRatio = 0.012;

  const PlayProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasBook = ref.watch(playerProvider.select((book) => book != null));
    final positionAsync = ref.watch(playbackPositionStreamProvider);

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    final showRemainingTime = ref.watch(
      settingsProvider.select((s) => s.showRemainingTime),
    );

    final showBufferedProgress = ref.watch(
      settingsProvider.select((s) => s.showBufferedProgress),
    );
    final screenSize = MediaQuery.sizeOf(context);

    if (!hasBook) return const _LoadingProgressBar();

    return positionAsync.when(
      loading: () => const _LoadingProgressBar(),
      error: (_, _) => const _LoadingProgressBar(),
      data: (positionData) {
        if (positionData.duration == Duration.zero) {
          return const _LoadingProgressBar();
        }
        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isPlayerLockEnabled,
              child: SizedBox(
                height: screenSize.height * _progressBarHeightRatio,
                width: screenSize.width * _progressBarWidthRatio,
                child: ProgressBar(
                  thumbCanPaintOutsideBar: false,
                  barHeight: screenSize.height * _barHeightRatio,
                  timeLabelType: showRemainingTime
                      ? TimeLabelType.remainingTime
                      : TimeLabelType.totalTime,
                  timeLabelLocation: TimeLabelLocation.below,
                  timeLabelTextStyle: Theme.of(context).textTheme.labelLarge,
                  thumbRadius: screenSize.height * _thumbRadiusRatio,
                  thumbGlowColor: Colors.transparent,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  baseBarColor: Theme.of(context).colorScheme.surfaceContainer,
                  bufferedBarColor: showBufferedProgress
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.transparent,
                  progressBarColor: Theme.of(context).colorScheme.primary,
                  progress: positionData.position,
                  buffered: positionData.bufferedPosition,
                  total: positionData.duration,
                  onSeek: (duration) async {
                    await ref.read(playerProvider.notifier).seek(duration);
                    ref
                        .read(sleepTimerProvider.notifier)
                        .resetFromListeningActivity();
                  },
                ),
              ),
            ),
            if (isPlayerLockEnabled)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    AppSnackBar.showSnackBar(
                      context,
                      context.l10n.playerLockedMessage,
                    );
                  },
                  onHorizontalDragEnd: (_) {
                    AppSnackBar.showSnackBar(
                      context,
                      context.l10n.playerLockedMessage,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LoadingProgressBar extends StatelessWidget {
  const _LoadingProgressBar();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return SizedBox(
      height: screenSize.height * PlayProgressBar._progressBarHeightRatio,
      width: screenSize.width * PlayProgressBar._progressBarWidthRatio,
      child: Align(
        alignment: Alignment.center,
        child: AppLinearProgressIndicator(
          width: screenSize.width * PlayProgressBar._progressBarWidthRatio,
          height: screenSize.height * PlayProgressBar._barHeightRatio,
        ),
      ),
    );
  }
}
