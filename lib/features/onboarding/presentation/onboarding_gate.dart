import 'package:flutter/material.dart';
import 'package:flutter_app_minimizer_plus/flutter_app_minimizer_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/presentation/library_page.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_page.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPath = ref.watch(
      settingsProvider.select((s) => s.homeFolderUri?.isNotEmpty ?? false),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        FlutterAppMinimizerPlus.minimizeApp();
      },
      child: hasPath ? const LibraryPage() : const OnboardingPage(),
    );
  }
}
