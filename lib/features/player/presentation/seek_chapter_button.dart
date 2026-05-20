import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class SeekChapterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const SeekChapterButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: context.titleMedium,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onPressed,
    );
  }
}
