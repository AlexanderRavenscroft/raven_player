import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/position_data.dart';
import 'package:raven_player/utils/app_loger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class PlayerNotifier extends Notifier<Audiobook?> {
  late final AudioPlayer _player;
  final _lock = Lock();

  StreamSubscription? _progressSub;
  StreamSubscription? _indexSub;

  @override
  Audiobook? build() {
    _player = AudioPlayer();

    ref.onDispose(() async {
      await _saveProgress();
      await _progressSub?.cancel();
      await _indexSub?.cancel();
      await _player.dispose();
    });
    return null;
  }

  Future<void> load(Audiobook book) async {
    await _lock.synchronized(() async {
      log.d('Loading player');
      if (state?.id == book.id) return;

      if (state != null) {
        await _saveProgress();
        await _cancelSubs();
        await _player.stop();
      }

      final saved = await ref
          .read(audiobookRepositoryProvider)
          .getById(book.id);
      final resume = saved ?? book;
      state = resume;

      log.i(resume.coverPath);
      final sources = resume.chapters
          .map(
            (c) => AudioSource.uri(
              Uri.parse(c.uri),
              tag: MediaItem(
                id: c.uri,
                album: resume.title,
                artist: resume.author,
                title: c.name,
                artUri: resume.coverPath != null
                    ? Uri.file(resume.coverPath!)
                    : null,
              ),
            ),
          )
          .toList();
      try {
        await _player.setAudioSources(
          sources,
          initialIndex: resume.currentChapterIndex,
          initialPosition: resume.currentPosition,
        );
      } catch (e) {
        log.e('Failed to load from saved position, resetting: $e');
        // Reset corrupted progress and retry from beginning
        final reset = resume.copyWith(
          currentChapterIndex: 0,
          currentPositionMs: 0,
        );
        await ref.read(audiobookRepositoryProvider).save(reset);
        state = reset;
        await _player.setAudioSources(sources, initialIndex: 0);
      }

      _attachListeners();
    });
  }

  void _attachListeners() {
    log.d('Attaching player listeners');
    // Save every eg. 5s while position changes (i.e., while playing)
    _progressSub = _player.positionStream
        .throttleTime(Duration(seconds: 5), trailing: true)
        .listen((position) async {
          await _saveProgress();
        });

    // Save immediately on chapter change
    _indexSub = _player.currentIndexStream
        .whereType<int>() // drop nulls
        .distinct() // only emit on real index change
        .listen((index) async {
          if (state != null) {
            state = state!.copyWith(currentChapterIndex: index);
          }

          await _saveProgress();
        });
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
  }

  Future<void> _saveProgress() async {
    final book = state;
    if (book == null) return;

    final repo = ref.read(audiobookRepositoryProvider);
    final latest = await repo.getById(book.id) ?? book;

    final pos = _player.position.inMilliseconds;
    final idx = _player.currentIndex ?? 0;

    final updated = latest.copyWith(
      currentPositionMs: pos,
      currentChapterIndex: idx,
    );

    state = updated;
    await repo.save(updated);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seekToStart() => _player.seek(Duration.zero);
  Future<void> seek(Duration position) => _player.seek(position);
  Future<void> seekToPrevious() => _player.seekToPrevious();
  Future<void> seekToNext() => _player.seekToNext();

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

  Stream<int> get currentChapterIndexStream =>
      _player.currentIndexStream.map((index) => index ?? 0);

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (pos, buf, dur) => PositionData(pos, buf, dur ?? Duration.zero),
      );
}

final playerProvider = NotifierProvider<PlayerNotifier, Audiobook?>(
  PlayerNotifier.new,
);

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(playerProvider.notifier).playerStateStream;
});

final positionDataStreamProvider = StreamProvider<PositionData>((ref) {
  return ref.watch(playerProvider.notifier).positionDataStream;
});
