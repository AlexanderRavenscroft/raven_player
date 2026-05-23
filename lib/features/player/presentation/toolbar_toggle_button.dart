import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class ToolbarToggleButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Widget Function(BuildContext, WidgetRef)? bottomContentBuilder;
  final bool isToggled;

  const ToolbarToggleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.bottomContentBuilder,
    this.isToggled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: isToggled
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.onSurface,
            size: context.bodyMedium,
          ),
          onPressed: onPressed,
        ),
        if (bottomContentBuilder != null && isToggled)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            child: bottomContentBuilder!(context, ref),
          ),
      ],
    );
  }
}
