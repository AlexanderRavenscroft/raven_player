import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/raven_player_app.dart';

void main() {
  test('starts from the gate without a restored audiobook', () {
    expect(RavenPlayerApp.initialRouteName(null), '/');
  });

  test('uses the player initial route for a restored audiobook', () {
    const audiobook = Audiobook(
      id: 'book-1',
      title: 'Book One',
      folderUri: 'book-1',
      chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-1')],
    );

    expect(RavenPlayerApp.initialRouteName(audiobook), '/player');
  });

  testWidgets('builds with home and default initial route generation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSettingsProvider.overrideWithValue(const UserSettings()),
        ],
        child: const RavenPlayerApp(),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an unavailable audiobook issue from cold startup', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSettingsProvider.overrideWithValue(const UserSettings()),
        ],
        child: const RavenPlayerApp(
          initialIssue: AppIssue.audiobookUnavailable,
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text(
        'Audiobook files are no longer available. Updating the library...',
      ),
      findsOneWidget,
    );
  });
}
