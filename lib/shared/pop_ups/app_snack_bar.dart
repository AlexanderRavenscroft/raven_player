import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

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
            size: context.bodyMedium,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Expanded(
            child: Text(
              message,
              style: context.appText.labelLarge!.withStyle(
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
          'icon': Icons.info_outline,
          'backgroundColor': Theme.of(context).colorScheme.primary,
        };
      case SnackBarType.error:
        return {
          'icon': Icons.error_outline,
          'backgroundColor': Theme.of(context).colorScheme.error,
        };
      case SnackBarType.success:
        return {
          'icon': Icons.check_circle_outline,
          'backgroundColor': Theme.of(context).colorScheme.tertiary,
        };
    }
  }
}
