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
  @override
  Audiobook? build() {
    _player = AudioPlayer();
    ref.onDispose(_player.dispose);
    return null;
  }

  Future<void> load(Audiobook book) async {
    if (state?.id == book.id) return;

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

    _progressSub = _player.positionStream
        .debounceTime(const Duration(seconds: 2))
        .listen((position) async {
          await _saveProgress();
        });
  }

  Future<void> clear() async {
    _progressSub?.cancel();
    await _saveProgress();
    await _player.stop();
    state = null;
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (state == null) return;
    await _player.seek(Duration.zero, index: chapterIndex);
    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    log.d('Saving progress');
    final book = state;
    if (book == null) return;
    final updated = book.copyWith(
      currentPositionMs: _player.position.inMilliseconds,
      currentChapterIndex: _player.currentIndex ?? 0,
    );
    state = updated;
    await ref.read(audiobookRepositoryProvider).save(updated);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, Audiobook?>(
  PlayerNotifier.new,
);

final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(playerProvider.notifier).player.playerStateStream;
});

final positionDataStreamProvider = StreamProvider<PositionData>((ref) {
  final player = ref.watch(playerProvider.notifier).player;
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    player.positionStream.startWith(Duration.zero),
    player.bufferedPositionStream.startWith(Duration.zero),
    player.durationStream.startWith(Duration.zero),
    (pos, buf, dur) => PositionData(pos, buf, dur ?? Duration.zero),
  );
});
final currentChapterIndexProvider = StreamProvider<int>((ref) {
  return ref
      .watch(playerProvider.notifier)
      .player
      .currentIndexStream
      .map((index) => index ?? 0);
});
