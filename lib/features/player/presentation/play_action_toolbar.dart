import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raven_player/features/player/presentation/toolbar_toggle_button.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';

class PlayActionToolbar extends ConsumerWidget {
  const PlayActionToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //* Idle Stop
          ToolbarToggleButton(
            icon: Icons.timer_outlined,
            onPressed: () {
              //   ref.read(playerSettingsProvider.notifier).toggleIdleStop();
              // },
              // isToggled: ref.watch(playerSettingsProvider).isIdleStopEnabled,
              // bottomContentBuilder: (context, ref) {
              //   final timer = ref.watch(playerSettingsProvider).idleStopTimeLeft;
              //   return Text(
              //     _formatTime(timer),
              //     style: context.appText.labelMedium,
              //   );
            },
          ),

          //* Playback Speed
          ToolbarToggleButton(
            icon: Icons.speed_outlined,
            onPressed: () {
              //  ref.read(playerSettingsProvider.notifier).toggleCustomSpeed();
              // },
              // isToggled: ref.watch(playerSettingsProvider).isCustomSpeedEnabled,
              // bottomContentBuilder: (context, ref) {
              //   final speed = ref.watch(playerSettingsProvider).customSpeed;
              //   return Text(
              //     speed.toStringAsFixed(1),
              //     style: context.appText.labelMedium,
              //   );
            },
          ),

          //* COMING SOON
          ToolbarToggleButton(
            icon: Icons.auto_graph_outlined,
            onPressed: () {
              AppSnackBar.showSnackBar(
                context,
                'This feature is planned to be added in the next release',
              );
            },
          ),

          //* COMING SOON
          ToolbarToggleButton(
            icon: Icons.lock_clock_outlined,
            onPressed: () {
              AppSnackBar.showSnackBar(
                context,
                'This feature is planned to be added in the next release',
              );
            },
          ),
        ],
      ),
    );
  }

  // String _formatTime(int seconds) {
  //   if (seconds < 60) return '$seconds';
  //   final minutes = seconds ~/ 60;
  //   final remainingSeconds = seconds % 60;
  //   return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  // }
}
