import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/player/presentation/toolbar_button.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/app_slider_dialog.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class ActionToolbar extends StatelessWidget {
  static const double _minPlaybackSpeed = 0.5;
  static const double _maxPlaybackSpeed = 3.0;
  static const int _playbackSpeedDivisions = 25;
  static const double _minSleepTimerMinutes = 5;
  static const double _maxSleepTimerMinutes = 90;
  static const int _sleepTimerDivisions = 17;

  const ActionToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
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
                icon: AppIcons.sleepTimer,
                isToggled: isSleepTimerEnabled,
                onPressed: () =>
                    ref.read(settingsProvider.notifier).toggleSleepTimer(),
                onLongPress: () => _showSleepTimerDialog(
                  context,
                  ref,
                  currentMinutes: sleepTimerDuration,
                ),
                bottomContentBuilder: (context) {
                  final text = sleepTimer.isRunning
                      ? _formatDuration(sleepTimer.remaining)
                      : '${sleepTimerDuration}m';

                  return Text(
                    text,
                    style: Theme.of(context).textTheme.labelMedium,
                  );
                },
              );
            },
          ),
          Consumer(
            builder: (context, ref, _) {
              final isPlaybackSpeedEnabled = ref.watch(
                settingsProvider.select((s) => s.isPlaybackSpeedEnabled),
              );
              final speed = ref.watch(
                settingsProvider.select((s) => s.playbackSpeed),
              );
              return ToolbarButton(
                icon: AppIcons.playbackSpeed,
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
                    await ref
                        .read(settingsProvider.notifier)
                        .togglePlaybackSpeed();
                  }
                },
                onLongPress: () => _showSpeedDialog(
                  context,
                  ref,
                  currentSpeed: speed,
                  isEnabled: isPlaybackSpeedEnabled,
                ),
                bottomContentBuilder: (context) {
                  return Text(
                    speed.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelMedium,
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
                icon: AppIcons.skipSilence,
                isToggled: isSkipSilenceEnabled,
                onPressed: () async {
                  await ref.read(settingsProvider.notifier).toggleSkipSilence();

                  if (!context.mounted) return;

                  final isEnabled = ref
                      .read(settingsProvider)
                      .isSkipSilenceEnabled;

                  AppSnackBar.showSnackBar(
                    context,
                    isEnabled
                        ? context.l10n.playerSkipSilenceOnMessage
                        : context.l10n.playerSkipSilenceOffMessage,
                    replacePrevious: true,
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
                icon: AppIcons.playerLock,
                isToggled: isPlayerLockEnabled,
                onPressed: () async {
                  if (isPlayerLockEnabled) {
                    AppSnackBar.showSnackBar(
                      context,
                      context.l10n.playerLockedMessage,
                    );
                    return;
                  }
                  await ref.read(settingsProvider.notifier).enablePlayerLock();
                },
                onLongPress: () async {
                  if (!isPlayerLockEnabled) {
                    await ref
                        .read(settingsProvider.notifier)
                        .enablePlayerLock();
                    return;
                  }
                  ScaffoldMessenger.of(context).clearSnackBars();
                  await ref.read(settingsProvider.notifier).disablePlayerLock();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _applyPlaybackSpeed(
    WidgetRef ref, {
    required double newSpeed,
    required double currentSpeed,
    required bool isEnabled,
  }) async {
    final rounded = double.parse(newSpeed.toStringAsFixed(1));

    if (!isEnabled && rounded != 1) {
      await ref.read(settingsProvider.notifier).enablePlaybackSpeed();
    }

    if (rounded == currentSpeed && isEnabled) return;

    if (rounded == 1) {
      await ref.read(settingsProvider.notifier).disablePlaybackSpeed();
    }

    await ref.read(settingsProvider.notifier).updatePlaybackSpeed(rounded);
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
        minValue: _minPlaybackSpeed,
        maxValue: _maxPlaybackSpeed,
        initialValue: currentSpeed,
        divisions: _playbackSpeedDivisions,
      ),
    );

    if (!context.mounted) return;

    if (newSpeed != null) {
      await _applyPlaybackSpeed(
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
        minValue: _minSleepTimerMinutes,
        maxValue: _maxSleepTimerMinutes,
        initialValue: currentMinutes.toDouble(),
        divisions: _sleepTimerDivisions,
      ),
    );

    if (!context.mounted) return;

    if (newMinutes != null) {
      await ref
          .read(settingsProvider.notifier)
          .updateSleepTimerDuration(newMinutes.round());
      await ref.read(settingsProvider.notifier).enableSleepTimer();
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds ~/ 60) % 60;
    final seconds = totalSeconds % 60;
    final secondsText = seconds.toString().padLeft(2, '0');

    if (hours > 0) {
      final minutesText = minutes.toString().padLeft(2, '0');
      return '$hours:$minutesText:$secondsText';
    }

    return '${totalSeconds ~/ 60}:$secondsText';
  }
}
