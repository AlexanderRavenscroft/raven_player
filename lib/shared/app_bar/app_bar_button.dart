import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';

class AppBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const AppBarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: AppIconSizes.medium,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
