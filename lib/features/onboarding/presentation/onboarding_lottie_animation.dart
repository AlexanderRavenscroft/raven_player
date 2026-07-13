import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/loading/app_circular_progress_indicator.dart';

class OnboardingLottieAnimation extends StatelessWidget {
  const OnboardingLottieAnimation({
    super.key,
    required this.assetPath,
    required this.height,
    this.width = double.infinity,
    this.repeat = true,
    this.reverse = true,
  });

  final String assetPath;
  final double height;
  final double width;
  final bool repeat;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      height: height,
      width: double.infinity,
      filterQuality: FilterQuality.high,
      frameRate: FrameRate.max,
      repeat: repeat,
      reverse: reverse,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        height: height,
        width: double.infinity,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              context.l10n.lottieError(error.toString()),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
      ),
      frameBuilder: (context, child, composition) {
        if (composition == null) {
          return SizedBox(
            height: height,
            width: double.infinity,
            child: const Center(
              child: AppCircularProgressIndicator(size: 75, strokeWidth: 5),
            ),
          );
        }
        return child;
      },
    );
  }
}
