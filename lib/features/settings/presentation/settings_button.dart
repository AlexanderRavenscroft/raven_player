import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class SettingsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const SettingsButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        fixedSize: Size(
          MediaQuery.of(context).size.width * 0.16,
          MediaQuery.of(context).size.height * 0.06,
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onPrimary,
        size: context.bodyLarge,
      ),
      onPressed: onPressed,
    );
  }
}
