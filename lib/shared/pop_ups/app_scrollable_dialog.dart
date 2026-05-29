import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/utils/app_docs.dart';

class AppScrollableDialog extends StatelessWidget {
  final IconData headingIcon;
  final String headingText;
  final TextFiles textFile;
  final String buttonText;

  const AppScrollableDialog({
    super.key,
    required this.headingIcon,
    required this.headingText,
    required this.textFile,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            headingIcon,
            size: context.bodyMedium,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(
            headingText,
            style: context.appText.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      content: Text(
        AppDocs.getText(textFile),
        textAlign: TextAlign.justify,
        style: context.appText.labelLarge,
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            fixedSize: Size(
              double.maxFinite,
              MediaQuery.of(context).size.height * 0.06,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            buttonText,
            style: context.appText.labelLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
