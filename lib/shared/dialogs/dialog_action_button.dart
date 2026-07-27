import 'package:flutter/material.dart';

class DialogActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Size? fixedSize;
  final FontWeight? fontWeight;

  const DialogActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.fixedSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    return TextButton(
      style:
          TextButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.surfaceContainer,
            fixedSize: fixedSize,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
              effectiveForegroundColor.withValues(alpha: 0.10),
            ),
          ),
      onPressed: onPressed,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(
          color: effectiveForegroundColor,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
