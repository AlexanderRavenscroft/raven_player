import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/features/player/application/playback_position.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:rxdart/rxdart.dart';

class RavenAudioHandler extends BaseAudioHandler {
  static const Duration defaultSeekOffset = Duration(seconds: 10);
  static const Duration longSeekOffset = Duration(seconds: 30);
  static const Duration _chapterEndGuard = Duration(milliseconds: 200);

  final _seekCompletedController = StreamController<void>.broadcast();
  final AudioPlayer player = AudioPlayer();

  RavenAudioHandler() {
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    player.currentIndexStream.whereType<int>().distinct().listen((index) {
      if (index >= queue.value.length) return;
      mediaItem.add(queue.value[index]);
    });
  }

  Future<void> setAudioSources(
    List<AudioSource> sources, {
    required List<MediaItem> mediaItems,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    queue.add(mediaItems);
    mediaItem.add(mediaItems[initialIndex ?? 0]);

    await player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );
  }

  Future<void> clearSession() async {
    log.d('Clearing session');
    await player.pause();
    await player.stop();
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> fastForward([Duration offset = defaultSeekOffset]) {
    return _seekByOffset(offset);
  }

  @override
  Future<void> rewind([Duration offset = defaultSeekOffset]) {
    return _seekByOffset(-offset);
  }

  //TODO Think about chapter clamp
  Future<void> _seekByOffset(Duration offset) async {
    final duration = player.duration ?? Duration.zero;
    final target = player.position + offset;

    final upperBound = _safeUpperBound(duration);

    final clamped = target < Duration.zero
        ? Duration.zero
        : target > upperBound
        ? upperBound
        : target;
    await seek(clamped);
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
    _seekCompletedController.add(null);
  }

  Duration _safeUpperBound(Duration duration) {
    if (duration <= _chapterEndGuard) return Duration.zero;
    return duration - _chapterEndGuard;
  }

  @override
  Future<void> stop() async {
    await clearSession();
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        MediaControl.fastForward,
        if (player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ],
      // androidCompactActionIndices: const [0, 2, 4],
      systemActions: const {
        MediaAction.seek,
        // MediaAction.seekForward,
        // MediaAction.seekBackward,
        // MediaAction.skipToNext,
        // MediaAction.skipToPrevious,
      },
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Emitted after app or system seek commands so session state can persist progress.
  Stream<void> get seekCompletedStream => _seekCompletedController.stream;

  Stream<PlayerState> get playerStateStream => player.playerStateStream;

  bool get isPlaying => player.playing;

  Stream<PlaybackPosition> get playbackPositionStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PlaybackPosition>(
        player.positionStream,
        player.bufferedPositionStream,
        player.durationStream,
        (pos, buf, dur) => PlaybackPosition(
          position: pos,
          bufferedPosition: buf,
          duration: dur ?? Duration.zero,
        ),
      );

  Stream<Duration> get positionStream => player.positionStream;

  Stream<int?> get currentIndexStream => player.currentIndexStream;

  Stream<ProcessingState> get processingStateStream =>
      player.processingStateStream;

  Duration get position => player.position;

  int? get currentIndex => player.currentIndex;
}

final audioHandlerProvider = Provider<RavenAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main');
});

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioHandlerProvider).playerStateStream;
});

final playbackPositionStreamProvider = StreamProvider<PlaybackPosition>((ref) {
  return ref.watch(audioHandlerProvider).playbackPositionStream;
});

//TODO: Add a setting to change notification eg: disable progress seek
//TODO: Add a setting to disable clamping within a chapter on seek
