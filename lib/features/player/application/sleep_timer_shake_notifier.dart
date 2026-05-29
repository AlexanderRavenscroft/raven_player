import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:shake/shake.dart';

class SleepTimerShakeNotifier extends Notifier<void> {
  ShakeDetector? _detector;

  @override
  void build() {
    ref.listen(settingsProvider.select((s) => s.isSleepTimerEnabled), (
      _,
      isEnabled,
    ) {
      if (isEnabled) {
        _startListening();
      } else {
        _stopListening();
      }
    });

    if (ref.read(settingsProvider).isSleepTimerEnabled) {
      _startListening();
    }

    ref.onDispose(_stopListening);
  }

  void _startListening() {
    if (_detector != null) return;

    _detector = ShakeDetector.waitForStart(
      onPhoneShake: (_) {
        ref.read(sleepTimerProvider.notifier).resetFromListeningActivity();
        log.d('SHAKED');
      },
      shakeSlopTimeMS: 2000,
      shakeCountResetTime: 3000,
      minimumShakeCount: 1,
      shakeThresholdGravity: 1.4,
      useFilter: true,
    )..startListening();
  }

  void _stopListening() {
    _detector?.stopListening();
    _detector = null;
  }
}

final sleepTimerShakeProvider = NotifierProvider<SleepTimerShakeNotifier, void>(
  SleepTimerShakeNotifier.new,
);
