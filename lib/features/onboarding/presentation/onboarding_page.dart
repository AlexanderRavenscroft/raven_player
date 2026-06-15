import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_elevated_button.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_lottie_animation.dart';

class OnboardingPage extends ConsumerWidget {
  static const _lottieFile = 'assets/animations/search_files.json';
  static const _lottieHeightRatio = 0.5;

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lottieHeight = MediaQuery.sizeOf(context).height * _lottieHeightRatio;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.onboardingTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                OnboardingLottieAnimation(
                  assetPath: _lottieFile,
                  height: lottieHeight,
                ),
                Text(
                  l10n.onboardingDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                OnboardingElevatedButton(
                  onPressed: () async {
                    await ref
                        .read(settingsProvider.notifier)
                        .updateHomeFolderUri();
                  },
                  text: l10n.onboardingChooseFolder,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.onboardingFooter,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
