import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/position_data.dart';
import 'package:raven_player/utils/app_loger.dart';
import 'package:rxdart/rxdart.dart';

class PlayerNotifier extends Notifier<Audiobook?> {
  late final AudioPlayer _player;
  AudioPlayer get player => _player;

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
    log.d('Loading player');
    // Same book already loaded — no-op
    if (state?.id == book.id) return;

    // Different book: persist old, tear down
    if (state != null) {
      await _saveProgress();
      await _cancelSubs();
      await _player.stop();
    }

    final saved = await ref.read(audiobookRepositoryProvider).getById(book.id);
    final resume = saved ?? book;
    state = resume;

    final sources = resume.chapters
        .map((c) => AudioSource.uri(Uri.parse(c.uri)))
        .toList();

    await _player.setAudioSources(
      sources,
      initialIndex: resume.currentChapterIndex,
      initialPosition: resume.currentPosition,
    );

    _attachListeners();
  }

  void _attachListeners() {
    log.d('Attaching player listeners');
    // Save every 10s while position changes (i.e., while playing)
    _progressSub = _player.positionStream
        .throttleTime(Duration(seconds: 5))
        .listen((position) async {
          await _saveProgress();
        });

    // Save immediately on chapter change
    _indexSub = _player.currentIndexStream
        .whereType<int>() // drop nulls
        .distinct() // only emit on real index change
        .listen((index) {
          if (state != null) {
            state = state!.copyWith(currentChapterIndex: index);
          }
          _saveProgress();
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
    final pos = _player.position.inMilliseconds;
    final idx = _player.currentIndex ?? 0;

    // Skip if nothing changed (avoids redundant writes & rebuilds)
    if (book.currentPositionMs == pos && book.currentChapterIndex == idx) {
      return;
    }

    final updated = book.copyWith(
      currentPositionMs: pos,
      currentChapterIndex: idx,
    );
    log.d('Saving progress: chapter $idx at ${Duration(milliseconds: pos)}');
    await ref.read(audiobookRepositoryProvider).save(updated);
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (state == null) return;
    await _player.seek(Duration.zero, index: chapterIndex);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seekToStart() => _player.seek(Duration.zero);
  Future<void> seek(Duration position) => _player.seek(position);

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

// final currentChapterIndexProvider = StreamProvider<int>((ref) {
//   return ref.watch(playerProvider.notifier).currentChapterIndexStream;
// });
