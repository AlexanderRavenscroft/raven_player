import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const _lottieFile = 'assets/animations/search_files.json';
  static const _lottieOffset = 0.092;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.08),
            Text(
              'Let\'s get started',
              style: context.appText.bodySmall!.withStyle(
                fontWeight: FontWeight.w500,
              ),
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
                        'Lottie error: $error',
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
                'Pick a folder with subfolders, each holding MP3s of one audiobook.',
                style: context.appText.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.all(context.bodySmall),
                elevation: 6,
                shadowColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                await ref.read(settingsProvider.notifier).updateHomeFolderUri();
              },
              child: Text(
                'Choose default folder',
                style: context.appText.bodySmall!.withStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.06),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
              child: Text(
                'This can be changed later in the settings.\n'
                'More files formats will be supported in the future.',
                style: context.appText.labelMedium!.withStyle(
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
