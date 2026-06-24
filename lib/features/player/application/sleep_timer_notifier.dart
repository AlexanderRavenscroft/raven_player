import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

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
  static const Duration _tickInterval = Duration(milliseconds: 500);
  static const Duration _fadeOutWindow = Duration(seconds: 20);
  static const double _fullVolume = 1.0;
  static const double _mutedVolume = 0.0;

  Timer? _timer;
  DateTime? _deadline;
  bool _isFadingVolume = false;

  @override
  SleepTimerState build() {
    ref.listen(playerStateStreamProvider, (previous, next) {
      final wasPlaying = previous?.value?.playing ?? false;
      final isPlaying = next.value?.playing ?? false;

      if (isPlaying && !wasPlaying) {
        _startFullCountdownIfEnabled();
      } else if (!isPlaying && wasPlaying) {
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

      if (ref.read(audioHandlerProvider).isPlaying) {
        _startFullCountdownIfEnabled();
      }
    });

    ref.listen(settingsProvider.select((s) => s.sleepTimerDurationMinutes), (
      _,
      _,
    ) {
      if (state.isRunning || ref.read(audioHandlerProvider).isPlaying) {
        _startFullCountdownIfEnabled();
      }
    });

    ref.onDispose(() => _cancelRuntimeCountdown());

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
    if (duration <= Duration.zero) {
      _cancelRuntimeCountdown(clearRemaining: true);
      return;
    }

    _deadline = DateTime.now().add(duration);
    _timer?.cancel();
    _restorePlayerVolume();
    state = SleepTimerState(remaining: duration, isRunning: true);

    _timer = Timer.periodic(_tickInterval, (_) => _updateCountdown());
  }

  void _updateCountdown() {
    final deadline = _deadline;
    if (deadline == null) return;

    final remaining = deadline.difference(DateTime.now());
    if (remaining <= Duration.zero) {
      _expire();
      return;
    }

    _updateFadeVolume(remaining);
    state = state.copyWith(remaining: remaining);
  }

  void _updateFadeVolume(Duration remaining) {
    if (remaining > _fadeOutWindow) {
      _restorePlayerVolume();
      return;
    }

    _isFadingVolume = true;
    final fadeRatio = remaining.inMilliseconds / _fadeOutWindow.inMilliseconds;
    final volume = fadeRatio.clamp(_mutedVolume, _fullVolume).toDouble();
    unawaited(ref.read(audioHandlerProvider).setVolume(volume));
  }

  void _expire() {
    final handler = ref.read(audioHandlerProvider);

    _cancelRuntimeCountdown(clearRemaining: true, restoreVolume: false);
    unawaited(_pauseExpiredPlayer(handler));
  }

  Future<void> _pauseExpiredPlayer(RavenAudioHandler handler) async {
    await handler.setVolume(_mutedVolume);
    await handler.pause();
    await handler.restoreVolume();
  }

  void _cancelRuntimeCountdown({
    bool clearRemaining = false,
    bool restoreVolume = true,
  }) {
    _timer?.cancel();
    _timer = null;
    _deadline = null;

    if (restoreVolume) {
      _restorePlayerVolume();
    } else {
      _isFadingVolume = false;
    }

    state = SleepTimerState(
      remaining: clearRemaining ? Duration.zero : state.remaining,
      isRunning: false,
    );
  }

  void _restorePlayerVolume() {
    if (!_isFadingVolume) return;

    _isFadingVolume = false;
    unawaited(ref.read(audioHandlerProvider).restoreVolume());
  }
}

final sleepTimerProvider =
    NotifierProvider<SleepTimerNotifier, SleepTimerState>(
      SleepTimerNotifier.new,
    );
