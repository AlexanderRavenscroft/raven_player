import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

enum AppConfirmDialogLevel { info, warning }

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final AppConfirmDialogLevel level;
  final String denialText;
  final String acceptText;
  final FutureOr<void> Function()? onAccept;
  final FutureOr<void> Function()? onDenial;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.level = AppConfirmDialogLevel.info,
    this.denialText = 'Cancel',
    this.acceptText = 'Ok',
    this.onAccept,
    this.onDenial,
  });

  IconData get _icon {
    return switch (level) {
      AppConfirmDialogLevel.info => Icons.info_outline,
      AppConfirmDialogLevel.warning => Icons.warning_amber_outlined,
    };
  }

  Color _accentColor(BuildContext context) {
    return switch (level) {
      AppConfirmDialogLevel.info => Theme.of(context).colorScheme.primary,
      AppConfirmDialogLevel.warning => Theme.of(context).colorScheme.error,
    };
  }

  Future<void> _handleDenial(BuildContext context) async {
    Navigator.pop(context, false);
    await onDenial?.call();
  }

  Future<void> _handleAccept(BuildContext context) async {
    Navigator.pop(context, true);
    await onAccept?.call();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(context);

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _icon,
            size: context.bodySmall,
            color: accentColor,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(
            title,
            style: context.appText.bodySmall!.withStyle(
              color: accentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        content,
        style: context.appText.labelLarge!.withStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(denialText, style: context.appText.labelLarge),
          onPressed: () => _handleDenial(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(acceptText, style: context.appText.labelLarge),
          onPressed: () => _handleAccept(context),
        ),
      ],
    );
  }
}
