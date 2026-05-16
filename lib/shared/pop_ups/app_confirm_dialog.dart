import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: context.bodySmall,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(
            title,
            style: context.appText.bodySmall!.withStyle(
              color: Theme.of(context).colorScheme.error,
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
          child: Text('Cancel', style: context.appText.labelLarge),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text('Delate', style: context.appText.labelLarge),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
