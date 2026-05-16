import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class AppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const AppBarButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: context.bodyMedium,
      ),
      onPressed: onPressed,
    );
  }
}
