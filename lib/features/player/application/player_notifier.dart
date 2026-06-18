import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/player/application/playback_position.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class PlayerNotifier extends Notifier<Audiobook?> {
  static const double _minVolume = 0.0;
  static const double _maxVolume = 1.0;

  final AudioPlayer _player = AudioPlayer();
  final Lock _lock = Lock();

  StreamSubscription<Duration>? _progressSub;
  StreamSubscription<int>? _indexSub;
  StreamSubscription<ProcessingState>? _processingSub;

  @override
  Audiobook? build() {
    ref.onDispose(() async {
      await _saveProgress();
      await _cancelSubs();
      await _player.dispose();
    });
    return null;
  }

  Future<void> load(Audiobook book) async {
    await _lock.synchronized(() async {
      log.d('Loading player');
      if (state?.id == book.id) return;

      await _stopCurrentPlaybackIfNeeded();

      final saved = await ref
          .read(audiobookRepositoryProvider)
          .getById(book.id);
      final resume = saved ?? book;
      state = resume;

      if (resume.chapters.isEmpty) {
        log.e('Cannot load audiobook without chapters.');
        return;
      }

      await _loadAudioSources(resume);

      await _attachListeners();
      await _applyPlaybackSettings();
    });
  }

  Future<void> _stopCurrentPlaybackIfNeeded() async {
    if (state == null) return;

    await _saveProgress();
    await _cancelSubs();
    await _player.stop();
  }

  Future<void> _loadAudioSources(Audiobook book) async {
    final coverPath = book.coverPath;
    final sources = book.chapters
        .map(
          (chapter) => AudioSource.uri(
            Uri.parse(chapter.uri),
            tag: MediaItem(
              id: chapter.uri,
              album: book.title,
              artist: book.author,
              title: chapter.name,
              artUri: coverPath == null ? null : Uri.file(coverPath),
            ),
          ),
        )
        .toList();

    try {
      await _player.setAudioSources(
        sources,
        initialIndex: book.currentChapterIndex,
        initialPosition: book.currentPosition,
      );
    } catch (e) {
      log.e('Failed to load from saved position, resetting: $e');

      final reset = book.copyWith(currentChapterIndex: 0, currentPositionMs: 0);

      await ref.read(audiobookRepositoryProvider).save(reset);
      state = reset;
      await _player.setAudioSources(sources, initialIndex: 0);
    }
  }

  Future<void> _attachListeners() async {
    log.d('Attaching player listeners');
    await _cancelSubs();

    _progressSub = _player.positionStream
        .throttleTime(
          const Duration(seconds: 5),
          trailing: true,
          leading: false,
        )
        .listen((position) async {
          await _saveProgress();
        });

    _indexSub = _player.currentIndexStream.whereType<int>().distinct().listen((
      index,
    ) async {
      if (state != null) {
        state = state!.copyWith(currentChapterIndex: index);
      }
      await _saveProgress();
    });

    _processingSub = _player.processingStateStream.listen((s) async {
      if (s == ProcessingState.idle) {
        log.f('Player stopped via notification/native button');
      }
      if (s != ProcessingState.completed) return;
      final book = state;
      if (book == null) return;
      log.i('WHOLE ${book.title} finished');
      await ref.read(libraryProvider.notifier).markAsRead(book);
    });
  }

  Future<void> _applyPlaybackSettings() async {
    final settings = ref.read(settingsProvider);

    if (settings.isPlaybackSpeedEnabled) {
      await _player.setSpeed(settings.playbackSpeed);
    }

    await _player.setSkipSilenceEnabled(settings.isSkipSilenceEnabled);
  }

  Future<void> clear() async {
    log.d('Clearing player');
    await _saveProgress();
    await _cancelSubs();
    await _player.stop();
    state = null;
  }

  Future<void> _cancelSubs() async {
    await _progressSub?.cancel();
    _progressSub = null;
    await _indexSub?.cancel();
    _indexSub = null;
    await _processingSub?.cancel();
    _processingSub = null;
  }

  Future<void> _saveProgress() async {
    log.i('Saving progress');
    final book = state;
    if (book == null) return;

    final repo = ref.read(audiobookRepositoryProvider);
    final latest = await repo.getById(book.id) ?? book;

    final positionMs = _player.position.inMilliseconds;
    final chapterIndex = _player.currentIndex ?? 0;

    final updated = latest.copyWith(
      currentPositionMs: positionMs,
      currentChapterIndex: chapterIndex,
    );

    state = updated;
    await repo.save(updated);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> replay() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> seekToPrevious() => _player.seekToPrevious();

  Future<void> seekToNext() => _player.seekToNext();

  Future<void> updatePlaybackSpeed(double speed) => _player.setSpeed(speed);

  Future<void> setSkipSilence(bool enabled) =>
      _player.setSkipSilenceEnabled(enabled);

  Future<void> setVolume(double volume) {
    final clampedVolume = volume.clamp(_minVolume, _maxVolume).toDouble();
    return _player.setVolume(clampedVolume);
  }

  Future<void> restoreVolume() => setVolume(_maxVolume);

  Future<void> seekByOffset(int seconds) async {
    final currentPosition = _player.position.inSeconds;
    final seekAmount = currentPosition + seconds;
    final newPosition = seekAmount.clamp(0, _player.duration?.inSeconds ?? 0);

    await _player.seek(Duration(seconds: newPosition));
    await _saveProgress();
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (state == null) return;
    await _player.seek(Duration.zero, index: chapterIndex);
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying => _player.playing;

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
}

final playerProvider = NotifierProvider<PlayerNotifier, Audiobook?>(
  PlayerNotifier.new,
);

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(playerProvider.notifier).playerStateStream;
});

final playbackPositionStreamProvider = StreamProvider<PlaybackPosition>((ref) {
  return ref.watch(playerProvider.notifier).playbackPositionStream;
});
