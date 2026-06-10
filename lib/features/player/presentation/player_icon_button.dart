import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';

class PlayerIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const PlayerIconButton({
    super.key,
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  const PlayerIconButton.chapter({
    super.key,
    required this.icon,
    required this.onPressed,
  }) : size = AppIconSizes.large;

  const PlayerIconButton.seek({
    super.key,
    required this.icon,
    required this.onPressed,
  }) : size = AppIconSizes.xLarge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: size,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onPressed,
    );
  }
}
