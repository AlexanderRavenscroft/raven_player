import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/core/theme/app_icons.dart';

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
    final style = _getStyle(context, type);

    return SnackBar(
      backgroundColor: style['backgroundColor'],
      content: Row(
        children: [
          Icon(
            style['icon'],
            color: Theme.of(context).colorScheme.onPrimary,
            size: AppIconSizes.medium,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      dismissDirection: DismissDirection.none,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: durationSec),
    );
  }

  static Map<String, dynamic> _getStyle(
    BuildContext context,
    SnackBarType type,
  ) {
    switch (type) {
      case SnackBarType.info:
        return {
          'icon': AppIcons.info,
          'backgroundColor': Theme.of(context).colorScheme.primary,
        };
      case SnackBarType.error:
        return {
          'icon': AppIcons.error,
          'backgroundColor': Theme.of(context).colorScheme.error,
        };
      case SnackBarType.success:
        return {'icon': AppIcons.success, 'backgroundColor': AppColors.success};
    }
  }
}
