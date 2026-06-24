import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:rxdart/rxdart.dart';

class RavenAudioHandler extends BaseAudioHandler {
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
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> fastForward() async {
    final next = player.position + const Duration(seconds: 10);
    final end = player.duration ?? Duration.zero;
    await player.seek(next > end ? end : next);
  }

  @override
  Future<void> rewind() async {
    final next = player.position - const Duration(seconds: 10);
    await player.seek(next < Duration.zero ? Duration.zero : next);
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
}

final audioHandlerProvider = Provider<RavenAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in main');
});
