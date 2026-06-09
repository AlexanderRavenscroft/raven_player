import 'package:flutter/material.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

class AppInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String confirmText;
  final TextEditingController textEditingController;

  const AppInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: TextSelectionTheme(
          data: TextSelectionTheme.of(context).copyWith(
            selectionHandleColor: Colors.transparent,
            selectionColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.20),
            cursorColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: TextField(
            controller: textEditingController,
            autofocus: true,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              hintMaxLines: 1,
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        DialogActionButton(
          text: context.l10n.dialogCancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          text: confirmText,
          onPressed: () => Navigator.pop(context, textEditingController.text),
        ),
      ],
    );
  }
}
