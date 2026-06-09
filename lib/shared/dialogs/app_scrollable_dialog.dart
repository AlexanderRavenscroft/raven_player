import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

class AppScrollableDialog extends StatelessWidget {
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
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            headingIcon,
            size: AppIconSizes.medium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            headingText,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          fixedSize: Size(
            double.maxFinite,
            MediaQuery.of(context).size.height * 0.06,
          ),
          fontWeight: FontWeight.bold,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
