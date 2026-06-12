import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_elevated_button.dart';
import 'package:raven_player/features/onboarding/presentation/onboarding_lottie_animation.dart';

class OnboardingPage extends ConsumerWidget {
  static const _lottieFile = 'assets/animations/search_files.json';
  static const _lottieLayoutHeightFactor = 0.8;
  static const _lottieHeightFactor = 0.6;
  static const _minLottieHeight = 240.0;
  static const _maxLottieHeight = 420.0;

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final lottieHeight = (constraints.maxHeight * _lottieHeightFactor)
                .clamp(_minLottieHeight, _maxLottieHeight)
                .toDouble();

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        l10n.onboardingTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Align(
                      heightFactor: _lottieLayoutHeightFactor,
                      child: OnboardingLottieAnimation(
                        height: lottieHeight,
                        assetPath: _lottieFile,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        l10n.onboardingDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        l10n.onboardingFooter,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(180),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
