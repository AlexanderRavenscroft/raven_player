import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

class AppScrollableDialog extends StatelessWidget {
  static const _actionButtonHeight = 52.0;
  final IconData headingIcon;
  final String headingText;
  final String content;

  const AppScrollableDialog({
    super.key,
    required this.headingIcon,
    required this.headingText,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final showIcon = textScale < 1.4;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          if (showIcon)
            Icon(
              headingIcon,
              size: AppIconSizes.medium,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          Flexible(
            child: Text(
              headingText,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      content: Text(
        content,
        textAlign: TextAlign.start,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.5),
      ),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      actions: [
        DialogActionButton(
          text: context.l10n.dialogClose,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          fixedSize: const Size(double.maxFinite, _actionButtonHeight),
          fontWeight: FontWeight.bold,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
