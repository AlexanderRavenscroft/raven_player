import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_elevated_button.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_lottie_animation.dart';

class OnboardingPage extends ConsumerWidget {
  static const _lottieFile = 'assets/animations/search_files.json';
  static const _heightFactor = 0.9;

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.xxxl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.onboardingTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Align(
            heightFactor: _heightFactor,
            child: OnboardingLottieAnimation(
              height: size.height * 0.5,
              assetPath: _lottieFile,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.onboardingDescription,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          OnboardingElevatedButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).updateHomeFolderUri();
            },
            text: l10n.onboardingChooseFolder,
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l10n.onboardingFooter,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
