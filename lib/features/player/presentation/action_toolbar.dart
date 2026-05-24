import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';

import 'package:raven_player/features/player/presentation/toolbar_button.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/shared/pop_ups/app_slider_dialog.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';

class ActionToolbar extends ConsumerWidget {
  const ActionToolbar({super.key});

  void _applyPlaybackSpeed(
    WidgetRef ref, {
    required double newSpeed,
    required double currentSpeed,
    required bool isEnabled,
  }) {
    final rounded = double.parse(newSpeed.toStringAsFixed(1));

    if (!isEnabled && rounded != 1) {
      ref.read(settingsProvider.notifier).enablePlaybackSpeed();
    }

    if (rounded == currentSpeed) return;

    if (rounded == 1) {
      ref.read(settingsProvider.notifier).disablePlaybackSpeed();
    }

    ref.read(settingsProvider.notifier).updatePlaybackSpeed(rounded);
  }

  Future<void> _showSpeedDialog(
    BuildContext context,
    WidgetRef ref, {
    required double currentSpeed,
    required bool isEnabled,
  }) async {
    final newSpeed = await showDialog<double>(
      context: context,
      builder: (context) => AppSliderDialog(
        title: 'Adjust Playback Speed',
        minValue: 0.1,
        maxValue: 2.0,
        initialValue: currentSpeed,
        divisions: 19,
      ),
    );

    if (newSpeed != null) {
      _applyPlaybackSpeed(
        ref,
        newSpeed: newSpeed,
        currentSpeed: currentSpeed,
        isEnabled: isEnabled,
      );
    }
  }

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
          ToolbarButton(
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
          Consumer(
            builder: (context, ref, _) {
              final isPlaybackSpeedEnabled = ref.watch(
                settingsProvider.select((s) => s.isPlaybackSpeedEnabled),
              );
              final speed = ref.watch(
                settingsProvider.select((s) => s.playbackSpeed),
              );
              return ToolbarButton(
                icon: Icons.speed_outlined,
                isToggled: isPlaybackSpeedEnabled,
                onPressed: () async {
                  if (speed == 1.00) {
                    await _showSpeedDialog(
                      context,
                      ref,
                      currentSpeed: speed,
                      isEnabled: isPlaybackSpeedEnabled,
                    );
                  } else {
                    ref.read(settingsProvider.notifier).togglePlaybackSpeed();
                  }
                },
                onLongPress: () => _showSpeedDialog(
                  context,
                  ref,
                  currentSpeed: speed,
                  isEnabled: isPlaybackSpeedEnabled,
                ),
                bottomContentBuilder: (context, ref) {
                  return Text(
                    speed.toStringAsFixed(1),
                    style: context.appText.labelMedium,
                  );
                },
              );
            },
          ),

          Consumer(
            builder: (context, ref, _) {
              final isPlayerLockEnabled = ref.watch(
                settingsProvider.select((s) => s.isPlayerLockEnabled),
              );
              return ToolbarButton(
                icon: Icons.lock_clock_outlined,
                isToggled: isPlayerLockEnabled,
                onPressed: () =>
                    ref.read(settingsProvider.notifier).togglePlayerLock(),
              );
            },
          ),
          //* COMING SOON
          ToolbarButton(
            icon: Icons.auto_graph_outlined,
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
