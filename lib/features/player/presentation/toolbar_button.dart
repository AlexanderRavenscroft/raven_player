import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';

class ToolbarButton extends ConsumerWidget {
  final IconData icon;
  final bool isToggled;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Widget Function(BuildContext, WidgetRef)? bottomContentBuilder;

  const ToolbarButton({
    super.key,
    required this.icon,
    this.isToggled = false,
    required this.onPressed,
    this.onLongPress,
    this.bottomContentBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            child: IconButton(
              icon: Icon(
                icon,
                color: isToggled
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurface,
                size: AppIconSizes.medium,
              ),
              onPressed: onPressed,
              onLongPress: onLongPress,
            ),
          ),
          if (bottomContentBuilder != null && isToggled)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.04,
              child: bottomContentBuilder!(context, ref),
            ),
        ],
      ),
    );
  }
}
