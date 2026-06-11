import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart' show AppIconSizes;

class SettingsButton extends StatelessWidget {
  static const _width = 64.0;
  static const _height = 48.0;

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
        fixedSize: const Size(_width, _height),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      icon: Icon(
        icon,
        color: Theme.of(context).colorScheme.onSurface,
        size: AppIconSizes.large,
      ),
      onPressed: onPressed,
    );
  }
}
