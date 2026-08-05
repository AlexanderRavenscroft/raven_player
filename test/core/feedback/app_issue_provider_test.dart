import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';

void main() {
  test('classifies Android source errors and clears them', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(appIssueProvider.notifier)
        .reportPlayerException(PlayerException(0, 'source failed', null));

    expect(container.read(appIssueProvider), AppIssue.playbackSource);

    container.read(appIssueProvider.notifier).clear();

    expect(container.read(appIssueProvider), isNull);
  });

  test('uses generic playback feedback for iOS player errors', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(appIssueProvider.notifier)
        .reportPlayerException(PlayerException(0, 'playback failed', null));

    expect(container.read(appIssueProvider), AppIssue.playbackUnknown);
  });

  test('uses generic playback feedback for non-source Android errors', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(appIssueProvider.notifier)
        .reportPlayerException(PlayerException(1, 'renderer failed', null));

    expect(container.read(appIssueProvider), AppIssue.playbackUnknown);
  });

  test('reports an unavailable audiobook', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(appIssueProvider.notifier).reportAudiobookUnavailable();

    expect(container.read(appIssueProvider), AppIssue.audiobookUnavailable);
  });
}
