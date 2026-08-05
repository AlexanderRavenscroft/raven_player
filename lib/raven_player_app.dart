import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/theme/app_theme.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_gate.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/presentation/play_page.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/feedback/app_issue_feedback_listener.dart';

class RavenPlayerApp extends ConsumerStatefulWidget {
  static const _restoredPlayerRoute = '/player';

  final Audiobook? initialAudiobook;
  final AppIssue? initialIssue;

  const RavenPlayerApp({super.key, this.initialAudiobook, this.initialIssue});

  static String initialRouteName(Audiobook? initialAudiobook) =>
      initialAudiobook == null
      ? Navigator.defaultRouteName
      : _restoredPlayerRoute;

  @override
  ConsumerState<RavenPlayerApp> createState() => _RavenPlayerAppState();
}

class _RavenPlayerAppState extends ConsumerState<RavenPlayerApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onDetach: () async {
        await ref.read(playerProvider.notifier).clear();
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final languageCode = ref.watch(
      settingsProvider.select((s) => s.languageCode),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      title: 'Raven Player',
      locale: Locale(AppLanguages.sanitize(languageCode)),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      builder: (context, child) {
        return AppIssueFeedbackListener(
          initialIssue: widget.initialIssue,
          child: child ?? const SizedBox.shrink(),
        );
      },
      initialRoute: RavenPlayerApp.initialRouteName(widget.initialAudiobook),
      routes: {
        if (widget.initialAudiobook != null)
          RavenPlayerApp._restoredPlayerRoute: (context) =>
              PlayPage(book: widget.initialAudiobook!),
      },
      home: const OnboardingGate(),
    );
  }
}
