import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';

enum SnackBarType { error, info, success }

class AppSnackBar {
  static bool _isSnackBarShowing = false;

  static void showSnackBar(
    BuildContext context,
    String message, {
    int durationSec = 3,
    SnackBarType type = SnackBarType.info,
    bool replacePrevious = false,
  }) {
    if (_isSnackBarShowing && !replacePrevious) return;

    if (replacePrevious) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    _isSnackBarShowing = true;

    ScaffoldMessenger.of(context)
        .showSnackBar(
          create(
            context: context,
            message: message,
            durationSec: durationSec,
            type: type,
          ),
        )
        .closed
        .then((_) {
          _isSnackBarShowing = false;
        });
  }

  static SnackBar create({
    required BuildContext context,
    required String message,
    int durationSec = 3,
    SnackBarType type = SnackBarType.info,
  }) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final showIcon = textScale < 1.4;

    final style = _getStyle(context, type);

    return SnackBar(
      backgroundColor: style.backgroundColor,
      content: Row(
        children: [
          if (showIcon) ...[
            Icon(
              style.icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: AppIconSizes.medium,
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      dismissDirection: DismissDirection.none,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationSec),
    );
  }

  static ({IconData icon, Color backgroundColor}) _getStyle(
    BuildContext context,
    SnackBarType type,
  ) {
    final scheme = Theme.of(context).colorScheme;
    switch (type) {
      case SnackBarType.info:
        return (icon: AppIcons.info, backgroundColor: scheme.primary);
      case SnackBarType.error:
        return (icon: AppIcons.error, backgroundColor: scheme.error);
      case SnackBarType.success:
        return (icon: AppIcons.success, backgroundColor: AppColors.success);
    }
  }
}
