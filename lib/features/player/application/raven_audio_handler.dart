import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/features/player/application/playback_position.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:rxdart/rxdart.dart';

class AppAudioHandler extends BaseAudioHandler {
  static const double _minVolume = 0.0;
  static const double _maxVolume = 1.0;

  static const Duration defaultSeekOffset = Duration(seconds: 10);
  static const Duration longSeekOffset = Duration(seconds: 60);

  final _seekCompletedController = StreamController<void>.broadcast();
  final AudioPlayer _player = AudioPlayer();

  late final StreamSubscription<PlaybackEvent> _playbackEventSub;
  late final StreamSubscription<int> _currentIndexSub;

  bool _notificationSeekEnabled = true;
  bool _notificationRefreshToggle = false;

  AppAudioHandler() {
    _playbackEventSub = _player.playbackEventStream.listen((event) {
      playbackState.add(_transformEvent(event));
    });

    _currentIndexSub = _player.currentIndexStream
        .whereType<int>()
        .distinct()
        .listen((index) {
          if (index >= queue.value.length) return;
          mediaItem.add(queue.value[index]);
        });
  }

  Future<void> dispose() async {
    await _playbackEventSub.cancel();
    await _currentIndexSub.cancel();
    await _seekCompletedController.close();
    await _player.dispose();
  }

  Future<void> setAudioSources(
    List<AudioSource> sources, {
    required List<MediaItem> mediaItems,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    queue.add(mediaItems);
    mediaItem.add(mediaItems[initialIndex ?? 0]);

    await _player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
  }

  Future<void> clearSession() async {
    log.d('Clearing session');
    await _player.pause();
    await _player.stop();
  }

  Future<void> forceDismissNotificationAfterError() async {
    try {
      await _player.stop();
    } catch (e) {
      log.e('Failed to stop player after error: $e');
    }

    final current = playbackState.value;

    if (current.processingState == AudioProcessingState.idle) {
      playbackState.add(
        current.copyWith(
          processingState: AudioProcessingState.ready,
          playing: false,
          controls: const [],
          systemActions: const {},
          androidCompactActionIndices: const [],
        ),
      );
    }

    playbackState.add(
      (playbackState.value).copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
        controls: const [],
        systemActions: const {},
        androidCompactActionIndices: const [],
        bufferedPosition: Duration.zero,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await clearSession();
  }

  @override
  Future<void> fastForward([Duration offset = defaultSeekOffset]) {
    return _seekByOffset(offset);
  }

  @override
  Future<void> rewind([Duration offset = defaultSeekOffset]) {
    return _seekByOffset(-offset);
  }

  @override
  Future<void> seek(Duration position, {int? index}) async {
    //? Refresh notification, when seeking on pause
    if (!_player.playing) {
      _notificationRefreshToggle = !_notificationRefreshToggle;
    }

    await _player.seek(position, index: index);
    _seekCompletedController.add(null);
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
    _seekCompletedController.add(null);
  }

  @override
  Future<void> skipToNext() async {
    await _player.seekToNext();
    _seekCompletedController.add(null);
  }

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Future<void> replay() async {
    await seek(Duration.zero, index: 0);
    await play();
  }

  Future<void> setSkipSilenceEnabled(bool enabled) =>
      _player.setSkipSilenceEnabled(enabled);

  Future<void> setVolume(double volume) {
    final clampedVolume = volume.clamp(_minVolume, _maxVolume).toDouble();
    return _player.setVolume(clampedVolume);
  }

  Future<void> restoreVolume() => setVolume(_maxVolume);

  void setNotificationSeekEnabled(bool enabled) {
    if (_notificationSeekEnabled == enabled) return;

    _notificationSeekEnabled = enabled;
    playbackState.add(_transformEvent(_player.playbackEvent));
  }

  Future<void> _seekByOffset(Duration offset) async {
    final currentIndex = _player.currentIndex;
    final chapters = queue.value;

    if (currentIndex == null ||
        currentIndex < 0 ||
        currentIndex >= chapters.length) {
      await _seekWithinCurrentSource(offset);
      return;
    }
    var targetIndex = currentIndex;
    var targetPosition = _player.position + offset;

    if (offset < Duration.zero) {
      while (targetPosition < Duration.zero && targetIndex > 0) {
        targetIndex--;

        final previousDuration = _durationForQueueIndex(targetIndex);
        if (previousDuration == null || previousDuration <= Duration.zero) {
          await seek(Duration.zero, index: targetIndex);
          return;
        }

        targetPosition += previousDuration;
      }

      if (targetPosition < Duration.zero) {
        targetPosition = Duration.zero;
      }

      await seek(targetPosition, index: targetIndex);
      return;
    }

    while (targetIndex < chapters.length - 1) {
      final currentDuration = _durationForQueueIndex(targetIndex);
      if (currentDuration == null || currentDuration <= Duration.zero) break;
      if (targetPosition < currentDuration) break;

      targetPosition -= currentDuration;
      targetIndex++;
    }

    final targetDuration = _durationForQueueIndex(targetIndex);
    if (targetDuration != null &&
        targetDuration > Duration.zero &&
        targetPosition > targetDuration) {
      targetPosition = targetDuration;
    }

    await seek(targetPosition, index: targetIndex);
  }

  Future<void> _seekWithinCurrentSource(Duration offset) {
    final duration = _player.duration;
    var targetPosition = _player.position + offset;

    if (targetPosition < Duration.zero) {
      targetPosition = Duration.zero;
    } else if (duration != null && targetPosition > duration) {
      targetPosition = duration;
    }

    return seek(targetPosition);
  }

  Duration? _durationForQueueIndex(int index) {
    final chapters = queue.value;
    if (index < 0 || index >= chapters.length) return null;

    if (index == _player.currentIndex) {
      return _player.duration ?? chapters[index].duration;
    }

    return chapters[index].duration;
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        MediaControl.fastForward,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      //? Force a notification refresh, when seeking on pause
      androidCompactActionIndices:
          !_player.playing && _notificationRefreshToggle ? const [] : null,
      systemActions: _notificationSeekEnabled
          ? const {MediaAction.seek}
          : const {},
      processingState: _mapProcessingState(event),
      playing: _player.playing,
      updatePosition: event.updatePosition,
      bufferedPosition: event.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  AudioProcessingState _mapProcessingState(PlaybackEvent event) {
    if (event.processingState == ProcessingState.buffering &&
        !_player.playing) {
      return AudioProcessingState.ready;
    }

    return switch (event.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  // Emitted after app or system seek commands so session state can persist progress.
  Stream<void> get seekCompletedStream => _seekCompletedController.stream;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<PlaybackPosition> get playbackPositionStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PlaybackPosition>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (pos, buf, dur) => PlaybackPosition(
          position: pos,
          bufferedPosition: buf,
          duration: dur ?? Duration.zero,
        ),
      );

  Stream<PlayerException> get errorStream => _player.errorStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  int? get currentIndex => _player.currentIndex;
}

final audioHandlerProvider = Provider<AppAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main');
});

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioHandlerProvider).playerStateStream;
});

final playbackPositionStreamProvider = StreamProvider<PlaybackPosition>((ref) {
  return ref.watch(audioHandlerProvider).playbackPositionStream;
});
