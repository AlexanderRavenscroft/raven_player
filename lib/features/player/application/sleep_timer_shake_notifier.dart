import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:shake/shake.dart';

class SleepTimerShakeNotifier extends Notifier<void> {
  static const int _shakeSlopTimeMs = 2000;
  static const int _shakeCountResetTimeMs = 3000;
  static const int _minimumShakeCount = 1;
  static const double _shakeThresholdGravity = 1.4;

  ShakeDetector? _detector;

  @override
  void build() {
    ref.listen(sleepTimerProvider.select((state) => state.isRunning), (
      _,
      isRunning,
    ) {
      _syncDetector(isRunning);
    });

    _syncDetector(ref.read(sleepTimerProvider).isRunning);

    ref.onDispose(_stopListening);
  }

  void _syncDetector(bool isTimerRunning) {
    if (isTimerRunning) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  void _startListening() {
    if (_detector != null) return;

    _detector = ShakeDetector.waitForStart(
      onPhoneShake: (_) =>
          ref.read(sleepTimerProvider.notifier).resetFromListeningActivity(),
      shakeSlopTimeMS: _shakeSlopTimeMs,
      shakeCountResetTime: _shakeCountResetTimeMs,
      minimumShakeCount: _minimumShakeCount,
      shakeThresholdGravity: _shakeThresholdGravity,
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
