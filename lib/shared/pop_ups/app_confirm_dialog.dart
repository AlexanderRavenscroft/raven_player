import 'package:flutter/material.dart';
import 'dart:async';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

enum AppConfirmDialogLevel { info, warning }

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final AppConfirmDialogLevel level;
  final String? denialText;
  final String? acceptText;
  final FutureOr<void> Function()? onAccept;
  final FutureOr<void> Function()? onDenial;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.level = AppConfirmDialogLevel.info,
    this.denialText,
    this.acceptText,
    this.onAccept,
    this.onDenial,
  });

  IconData get _icon {
    return switch (level) {
      AppConfirmDialogLevel.info => AppIcons.info,
      AppConfirmDialogLevel.warning => AppIcons.warning,
    };
  }

  Color _accentColor(BuildContext context) {
    return switch (level) {
      AppConfirmDialogLevel.info => Theme.of(context).colorScheme.onSurface,
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
          Icon(_icon, size: AppIconSizes.medium, color: accentColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: accentColor),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      content: Text(
        content,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
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
          child: Text(
            denialText ?? context.l10n.dialogCancel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () => _handleDenial(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            acceptText ?? context.l10n.dialogOk,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () => _handleAccept(context),
        ),
      ],
    );
  }
}
