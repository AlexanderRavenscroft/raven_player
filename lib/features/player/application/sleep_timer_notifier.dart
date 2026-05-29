import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

//TODO: Fix a bug where chaning the duration of the sleep timer, when its off does not enable it by deafult.
class SleepTimerState {
  final Duration remaining;
  final bool isRunning;

  const SleepTimerState({
    this.remaining = Duration.zero,
    this.isRunning = false,
  });

  SleepTimerState copyWith({Duration? remaining, bool? isRunning}) {
    return SleepTimerState(
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class SleepTimerNotifier extends Notifier<SleepTimerState> {
  Timer? _timer;
  DateTime? _deadline;

  @override
  SleepTimerState build() {
    ref.listen(playerStateStreamProvider, (_, next) {
      final isPlaying = next.value?.playing ?? false;

      if (isPlaying) {
        _startFullCountdownIfEnabled();
      } else {
        _cancelRuntimeCountdown();
      }
    });

    ref.listen(settingsProvider.select((s) => s.isSleepTimerEnabled), (
      _,
      isEnabled,
    ) {
      if (!isEnabled) {
        _cancelRuntimeCountdown(clearRemaining: true);
        return;
      }

      if (ref.read(playerProvider.notifier).isPlaying) {
        _startFullCountdownIfEnabled();
      }
    });

    ref.listen(settingsProvider.select((s) => s.sleepTimerDurationMinutes), (
      _,
      _,
    ) {
      if (state.isRunning || ref.read(playerProvider.notifier).isPlaying) {
        _startFullCountdownIfEnabled();
      }
    });

    ref.onDispose(_cancelRuntimeCountdown);

    return const SleepTimerState();
  }

  void resetFromListeningActivity() {
    if (!state.isRunning) return;
    _startFullCountdownIfEnabled();
  }

  void _startFullCountdownIfEnabled() {
    final settings = ref.read(settingsProvider);
    if (!settings.isSleepTimerEnabled) return;

    final duration = Duration(minutes: settings.sleepTimerDurationMinutes);
    _deadline = DateTime.now().add(duration);
    _timer?.cancel();
    state = SleepTimerState(remaining: duration, isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final deadline = _deadline;
      if (deadline == null) return;

      final remaining = deadline.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        _expire();
        return;
      }

      state = state.copyWith(remaining: remaining);
    });
  }

  void _expire() {
    _cancelRuntimeCountdown(clearRemaining: true);
    ref.read(playerProvider.notifier).pause();
  }

  void _cancelRuntimeCountdown({bool clearRemaining = false}) {
    _timer?.cancel();
    _timer = null;
    _deadline = null;

    state = SleepTimerState(
      remaining: clearRemaining ? Duration.zero : state.remaining,
      isRunning: false,
    );
  }
}

final sleepTimerProvider =
    NotifierProvider<SleepTimerNotifier, SleepTimerState>(
      SleepTimerNotifier.new,
    );
