import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

enum AppIssue { playbackSource, playbackUnknown, audiobookUnavailable }

class AppIssueNotifier extends Notifier<AppIssue?> {
  static const int _androidSourceErrorCode = 0;

  @override
  AppIssue? build() => null;

  void report(AppIssue issue) {
    state = issue;
  }

  void reportPlayerException(PlayerException error) {
    final isAndroidSourceError =
        defaultTargetPlatform == TargetPlatform.android &&
        error.code == _androidSourceErrorCode;

    state = isAndroidSourceError
        ? AppIssue.playbackSource
        : AppIssue.playbackUnknown;
  }

  void reportAudiobookUnavailable() {
    state = AppIssue.audiobookUnavailable;
  }

  void clear() {
    state = null;
  }
}

final appIssueProvider = NotifierProvider<AppIssueNotifier, AppIssue?>(
  AppIssueNotifier.new,
);
