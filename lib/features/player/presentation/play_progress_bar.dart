import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';

class PlayProgressBar extends ConsumerWidget {
  const PlayProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(playerProvider);
    final positionAsync = ref.watch(positionDataStreamProvider);

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    final showRemainingTime = ref.watch(
      settingsProvider.select((s) => s.showRemainingTime),
    );

    final showBufferedProgress = ref.watch(
      settingsProvider.select((s) => s.showBufferedProgress),
    );

    if (book == null) return const LinearProgressIndicator();
    return positionAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const LinearProgressIndicator(),
      data: (positionData) {
        if (positionData.duration == Duration.zero) {
          return const LinearProgressIndicator();
        }
        return Stack(
          children: [
            AbsorbPointer(
              absorbing: isPlayerLockEnabled,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.92,
                child: ProgressBar(
                  thumbCanPaintOutsideBar: false,
                  timeLabelType: showRemainingTime
                      ? TimeLabelType.remainingTime
                      : TimeLabelType.totalTime,
                  barHeight: MediaQuery.of(context).size.height * 0.01,
                  thumbGlowColor: Colors.transparent,
                  thumbRadius: MediaQuery.of(context).size.height * 0.012,
                  timeLabelLocation: TimeLabelLocation.below,
                  timeLabelTextStyle: context.appText.labelLarge,
                  thumbColor: Theme.of(context).colorScheme.primary,
                  baseBarColor: Theme.of(context).colorScheme.surfaceContainer,
                  bufferedBarColor: showBufferedProgress
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : Colors.transparent,
                  progressBarColor: Theme.of(context).colorScheme.primary,
                  progress: positionData.position,
                  buffered: positionData.bufferedPosition,
                  total: positionData.duration,
                  onSeek: (d) {
                    ref.read(playerProvider.notifier).seek(d);
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
                      context.l10n.playerSliderLocked,
                    );
                  },
                  onHorizontalDragEnd: (_) {
                    AppSnackBar.showSnackBar(
                      context,
                      context.l10n.playerSliderLocked,
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
