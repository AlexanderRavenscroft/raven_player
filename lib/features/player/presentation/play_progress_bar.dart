import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_provider.dart';

class PlayProgressBar extends ConsumerWidget {
  const PlayProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(playerProvider);
    final positionAsync = ref.watch(positionDataStreamProvider);

    if (book == null) return const LinearProgressIndicator();
    return positionAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const LinearProgressIndicator(),
      data: (positionData) {
        if (positionData.duration == Duration.zero) {
          return const LinearProgressIndicator();
        }
        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.92,
          child: ProgressBar(
            thumbCanPaintOutsideBar: false,
            barHeight: MediaQuery.of(context).size.height * 0.01,
            thumbGlowColor: Colors.transparent,
            thumbRadius: MediaQuery.of(context).size.height * 0.012,
            timeLabelLocation: TimeLabelLocation.below,
            timeLabelTextStyle: context.appText.labelLarge,
            timeLabelType: TimeLabelType.totalTime,
            thumbColor: Theme.of(context).colorScheme.primary,
            baseBarColor: Theme.of(context).colorScheme.surfaceContainer,
            bufferedBarColor: Colors.transparent,
            progressBarColor: Theme.of(context).colorScheme.primary,
            progress: positionData.position,
            buffered: positionData.bufferedPosition,
            total: positionData.duration,
            onSeek: (d) => ref.read(playerProvider.notifier).seek(d),
          ),
        );
      },
    );
  }
}
