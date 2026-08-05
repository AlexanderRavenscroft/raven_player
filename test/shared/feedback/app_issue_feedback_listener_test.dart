import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/l10n/app_localizations.dart';
import 'package:raven_player/shared/feedback/app_issue_feedback_listener.dart';

void main() {
  testWidgets('shows unavailable audiobook feedback', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AppIssueFeedbackListener(
            child: Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );

    container.read(appIssueProvider.notifier).reportAudiobookUnavailable();
    await tester.pump();

    expect(
      find.text(
        'Audiobook files are no longer available. Updating the library...',
      ),
      findsOneWidget,
    );
    expect(container.read(appIssueProvider), isNull);
  });

  testWidgets('shows an initial issue after the first frame', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: AppIssueFeedbackListener(
            initialIssue: AppIssue.audiobookUnavailable,
            child: Scaffold(body: SizedBox.expand()),
          ),
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
