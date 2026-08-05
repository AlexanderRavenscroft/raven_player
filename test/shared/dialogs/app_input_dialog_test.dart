import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/l10n/app_localizations.dart';
import 'package:raven_player/shared/dialogs/app_input_dialog.dart';

void main() {
  testWidgets('returns the edited value when confirmed', (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDialog<String>(
                context: context,
                builder: (context) => const AppInputDialog(
                  title: 'Rename audiobook',
                  hintText: 'Audiobook title',
                  confirmText: 'Rename',
                  initialValue: 'Original title',
                ),
              );
            },
            child: const Text('Open dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Original title'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Edited title');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(result, 'Edited title');
  });
}
