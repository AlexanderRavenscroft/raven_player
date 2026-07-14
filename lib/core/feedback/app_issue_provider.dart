import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum AppIssueType {
  playbackSource,
  playbackUnknown,
  audiobookUnavailable,
}

class AppIssue {
  final AppIssueType type;
  final int? code;
  final String? technicalMessage;

  const AppIssue({
    required this.type,
    this.code,
    this.technicalMessage,
  });
}

class AppIssueNotifier extends Notifier<AppIssue?> {
  static const int _sourceErrorCode = 0;

  @override
  AppIssue? build() => null;

  void report(AppIssue issue) {
    state = issue;
  }

  void reportPlayerException(PlayerException error) {
    state = AppIssue(
      type: error.code == _sourceErrorCode
          ? AppIssueType.playbackSource
          : AppIssueType.playbackUnknown,
      code: error.code,
      technicalMessage: error.message,
    );
  }

  void reportAudiobookUnavailable() {
    state = const AppIssue(type: AppIssueType.audiobookUnavailable);
  }

  void clear() {
    state = null;
  }
}

final appIssueProvider = NotifierProvider<AppIssueNotifier, AppIssue?>(
  AppIssueNotifier.new,
);
