import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_gate.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

class RavenPlayerApp extends ConsumerStatefulWidget {
  const RavenPlayerApp({super.key});

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raven Player',
      themeMode: themeMode,
      theme: lightMode,
      darkTheme: darkMode,
      home: const OnboardingGate(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    );
  }
}
