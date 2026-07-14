import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';

void main() {
  test('classifies and clears player exceptions', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(appIssueProvider.notifier)
        .reportPlayerException(PlayerException(0, 'source failed', null));

    expect(container.read(appIssueProvider)?.type, AppIssueType.playbackSource);
    expect(container.read(appIssueProvider)?.code, 0);

    container.read(appIssueProvider.notifier).clear();

    expect(container.read(appIssueProvider), isNull);
  });

  test('reports an unavailable audiobook', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(appIssueProvider.notifier).reportAudiobookUnavailable();

    expect(
      container.read(appIssueProvider)?.type,
      AppIssueType.audiobookUnavailable,
    );
  });
}
