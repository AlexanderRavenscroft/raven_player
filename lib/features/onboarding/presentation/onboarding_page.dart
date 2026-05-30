import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const _lottieFile = 'assets/animations/search_files.json';
  static const _lottieOffset = 0.092;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.08),
            Text(
              l10n.onboardingTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: size.height * 0.04),
            ClipRRect(
              child: Container(
                color: Colors.transparent,
                height: size.height * 0.4,
                child: Transform.translate(
                  offset: Offset(0, -size.height * _lottieOffset),
                  child: Lottie.asset(
                    _lottieFile,
                    width: size.width,
                    filterQuality: FilterQuality.high,
                    frameRate: FrameRate(60),
                    repeat: true,
                    reverse: true,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        l10n.onboardingLottieError(error.toString()),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    frameBuilder: (_, child, composition) {
                      if (composition == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return child;
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Text(
                l10n.onboardingDescription,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.all(AppIconSizes.small),
                elevation: 6,
                shadowColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await ref.read(settingsProvider.notifier).updateHomeFolderUri();
              },
              child: Text(
                l10n.onboardingChooseFolder,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.06),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Text(
                l10n.onboardingFooter,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
