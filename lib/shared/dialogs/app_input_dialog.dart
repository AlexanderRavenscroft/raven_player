import 'package:flutter/material.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

class AppInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final String confirmText;
  final String initialValue;

  const AppInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.confirmText,
    this.initialValue = '',
  });

  @override
  State<AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<AppInputDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
      content: TextSelectionTheme(
        data: TextSelectionTheme.of(context).copyWith(
          selectionHandleColor: Colors.transparent,
          selectionColor: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.20),
          cursorColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 1,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hintText,
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
          text: widget.confirmText,
          onPressed: () => Navigator.pop(context, _controller.text),
        ),
      ],
    );
  }
}
