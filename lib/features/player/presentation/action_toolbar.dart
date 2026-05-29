import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';

import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/player/presentation/toolbar_button.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
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
        title: context.l10n.playerAdjustPlaybackSpeed,
        minValue: 0.5,
        maxValue: 3.0,
        initialValue: currentSpeed,
        divisions: 25,
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

  Future<void> _showSleepTimerDialog(
    BuildContext context,
    WidgetRef ref, {
    required int currentMinutes,
  }) async {
    final newMinutes = await showDialog<double>(
      context: context,
      builder: (context) => AppSliderDialog(
        title: context.l10n.playerAdjustSleepTimer,
        minValue: 5,
        maxValue: 90,
        initialValue: currentMinutes.toDouble(),
        divisions: 17,
        confirmLabel: context.l10n.playerSet,
      ),
    );

    if (newMinutes != null) {
      await ref
          .read(settingsProvider.notifier)
          .updateSleepTimerDuration(newMinutes.round());
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
          Consumer(
            builder: (context, ref, _) {
              final isSleepTimerEnabled = ref.watch(
                settingsProvider.select((s) => s.isSleepTimerEnabled),
              );
              final sleepTimerDuration = ref.watch(
                settingsProvider.select((s) => s.sleepTimerDurationMinutes),
              );
              final sleepTimer = ref.watch(sleepTimerProvider);

              return ToolbarButton(
                icon: Icons.timer_outlined,
                isToggled: isSleepTimerEnabled,
                onPressed: () =>
                    ref.read(settingsProvider.notifier).toggleSleepTimer(),
                onLongPress: () => _showSleepTimerDialog(
                  context,
                  ref,
                  currentMinutes: sleepTimerDuration,
                ),
                bottomContentBuilder: (context, ref) {
                  final text = sleepTimer.isRunning
                      ? _formatDuration(sleepTimer.remaining)
                      : '${sleepTimerDuration}m';

                  return Text(text, style: context.appText.labelMedium);
                },
              );
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
              final isSkipSilenceEnabled = ref.watch(
                settingsProvider.select((s) => s.isSkipSilenceEnabled),
              );
              return ToolbarButton(
                icon: Icons.graphic_eq,
                isToggled: isSkipSilenceEnabled,
                onPressed: () => ref
                    .read(settingsProvider.notifier)
                    .toggleIsSkipSilenceEnabled(),
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
                onPressed: () {
                  if (isPlayerLockEnabled) {
                    AppSnackBar.showSnackBar(
                      context,
                      context.l10n.playerLockedMessage,
                    );
                    return;
                  }
                  ref.read(settingsProvider.notifier).enablePlayerLock();
                },
                onLongPress: () {
                  if (!isPlayerLockEnabled) {
                    ref.read(settingsProvider.notifier).enablePlayerLock();
                    return;
                  }
                  ref.read(settingsProvider.notifier).disablePlayerLock();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
