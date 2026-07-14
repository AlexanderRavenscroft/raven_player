import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

class PlayerNotifier extends Notifier<Audiobook?> {
  AppAudioHandler get _handler => ref.read(audioHandlerProvider);
  final Lock _lock = Lock();

  StreamSubscription<Duration>? _progressSub;
  StreamSubscription<int>? _indexSub;
  StreamSubscription<ProcessingState>? _processingSub;
  StreamSubscription<void>? _seekSub;
  StreamSubscription<PlayerException>? _errorSub;

  @override
  Audiobook? build() {
    ref.onDispose(() async {
      await _saveProgress();
      await _cancelSubs();
      await _handler.dispose();
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
    await _handler.stop();
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
              duration: chapter.duration,
            ),
          ),
        )
        .toList();

    final mediaItems = sources.map((s) => s.tag as MediaItem).toList();

    try {
      await _handler.setAudioSources(
        sources,
        mediaItems: mediaItems,
        initialIndex: book.currentChapterIndex,
        initialPosition: book.currentPosition,
      );
    } catch (e) {
      log.e('Failed to load from saved position, resetting: $e');

      final reset = book.copyWith(currentChapterIndex: 0, currentPositionMs: 0);

      await ref.read(audiobookRepositoryProvider).save(reset);
      state = reset;
      await _handler.setAudioSources(
        sources,
        mediaItems: mediaItems,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
    }
  }

  Future<void> _attachListeners() async {
    log.d('Attaching player listeners');
    await _cancelSubs();

    _progressSub = _handler.positionStream
        .throttleTime(
          const Duration(seconds: 5),
          trailing: true,
          leading: false,
        )
        .listen((position) async {
          log.d('Saving progress from periodic secs');
          await _saveProgress();
        });

    _indexSub = _handler.currentIndexStream.whereType<int>().distinct().listen((
      index,
    ) async {
      if (state != null) {
        state = state!.copyWith(currentChapterIndex: index);
      }
      log.d('Saving progress from index change');
      await _saveProgress();
    });

    _processingSub = _handler.processingStateStream.listen((s) async {
      if (s != ProcessingState.completed) return;
      final book = state;
      if (book == null) return;
      log.i('WHOLE ${book.title} finished');
      await ref.read(libraryProvider.notifier).markAsRead(book);
    });

    _seekSub = _handler.seekCompletedStream.listen((_) async {
      log.d('Saving progress from seek');
      await _saveProgress();
    });

    _errorSub = _handler.errorStream.listen((error) async {
      log.e('Error message:${error.message ?? 'Unknown playback error'}');
      log.e('Error code: ${error.code.toString()}');

      await _handler.forceDismissNotificationAfterError();
      ref.read(appIssueProvider.notifier).reportPlayerException(error);
    });
  }

  Future<void> _applyPlaybackSettings() async {
    final settings = ref.read(settingsProvider);

    if (settings.isPlaybackSpeedEnabled) {
      await _handler.setSpeed(settings.playbackSpeed);
    }

    await _handler.setSkipSilenceEnabled(settings.isSkipSilenceEnabled);
    _handler.setNotificationSeekEnabled(settings.enableNotificationSlider);
  }

  Future<void> clear() async {
    log.d('Saving progress from clear player');
    await _saveProgress();
    await _cancelSubs();
    await _handler.clearSession();
    state = null;
  }

  Future<void> stopForFolderChange() async {
    log.d('Saving progress from stopForFolderChange');
    await _saveProgress();
    await _cancelSubs();
    await _handler.clearSession();
    // Keep state so reopening the same book reuses the retained just_audio session.
  }

  Future<void> seekToChapter(int chapterIndex) async {
    if (state == null) return;
    await _handler.seek(Duration.zero, index: chapterIndex);
  }

  Future<void> _cancelSubs() async {
    await _progressSub?.cancel();
    _progressSub = null;
    await _indexSub?.cancel();
    _indexSub = null;
    await _processingSub?.cancel();
    _processingSub = null;
    await _seekSub?.cancel();
    _seekSub = null;
    await _errorSub?.cancel();
    _errorSub = null;
  }

  Future<void> _saveProgress() async {
    final book = state;
    if (book == null) return;

    final repo = ref.read(audiobookRepositoryProvider);
    final latest = await repo.getById(book.id) ?? book;

    final positionMs = _handler.position.inMilliseconds;
    final chapterIndex = _handler.currentIndex ?? 0;

    final updated = latest.copyWith(
      currentPositionMs: positionMs,
      currentChapterIndex: chapterIndex,
    );

    state = updated;
    await repo.save(updated);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, Audiobook?>(
  PlayerNotifier.new,
);
