import 'dart:async';
import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

enum AppConfirmDialogLevel { info, warning, danger }

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final AppConfirmDialogLevel level;

  final String? denialText;
  final String? acceptText;
  final FutureOr<void> Function()? onAccept;
  final FutureOr<void> Function()? onDenial;

  final bool showOnlyAccept;
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.level = AppConfirmDialogLevel.info,
    this.denialText,
    this.acceptText,
    this.onAccept,
    this.onDenial,
    this.showOnlyAccept = false,
  });

  IconData get _icon {
    return switch (level) {
      AppConfirmDialogLevel.info => AppIcons.info,
      AppConfirmDialogLevel.warning => AppIcons.warning,
      AppConfirmDialogLevel.danger => AppIcons.error,
    };
  }

  Color _accentColor(BuildContext context) {
    return switch (level) {
      AppConfirmDialogLevel.info => Theme.of(context).colorScheme.onSurface,
      AppConfirmDialogLevel.warning => Theme.of(context).colorScheme.secondary,
      AppConfirmDialogLevel.danger => Theme.of(context).colorScheme.error,
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final showIcon = textScale < 1.4;

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.sm,
        children: [
          if (showIcon)
            Icon(_icon, size: AppIconSizes.medium, color: accentColor),
          Flexible(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: accentColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        if (!showOnlyAccept)
          DialogActionButton(
            text: denialText ?? context.l10n.dialogCancel,
            onPressed: () => _handleDenial(context),
          ),
        DialogActionButton(
          text: acceptText ?? context.l10n.dialogOk,
          fixedSize: showOnlyAccept
              ? const Size.fromWidth(double.maxFinite)
              : null,
          onPressed: () => _handleAccept(context),
        ),
      ],
    );
  }
}
