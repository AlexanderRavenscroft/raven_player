import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum PlaybackIssueType { sourceError, unknown }

class PlaybackIssue {
  final PlaybackIssueType type;
  final int code;
  final String? technicalMessage;

  const PlaybackIssue({
    required this.type,
    required this.code,
    this.technicalMessage,
  });
}

class PlaybackIssueNotifier extends Notifier<PlaybackIssue?> {
  static const int _sourceErrorCode = 0;

  @override
  PlaybackIssue? build() => null;

  void reportPlayerException(PlayerException error) {
    state = PlaybackIssue(
      type: _classify(error),
      code: error.code,
      technicalMessage: error.message,
    );
  }

  void clear() {
    state = null;
  }

  PlaybackIssueType _classify(PlayerException error) {
    return switch (error.code) {
      _sourceErrorCode => PlaybackIssueType.sourceError,
      _ => PlaybackIssueType.unknown,
    };
  }
}

final playbackIssueProvider =
    NotifierProvider<PlaybackIssueNotifier, PlaybackIssue?>(
      PlaybackIssueNotifier.new,
    );
