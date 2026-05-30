import 'package:flutter/material.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class AppInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController textEditingController;
  const AppInputDialog({
    super.key,
    required this.textEditingController,
    required this.title,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: TextField(
          controller: textEditingController,
          autofocus: true,
          maxLines: 1,
          cursorColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium,
            hintMaxLines: 1,
            focusColor: Theme.of(context).colorScheme.primary,
            hoverColor: Theme.of(context).colorScheme.primary,
          ),
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
          child: Text(
            context.l10n.dialogCancel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            context.l10n.dialogRename,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () => Navigator.pop(context, textEditingController.text),
        ),
      ],
    );
  }
}
