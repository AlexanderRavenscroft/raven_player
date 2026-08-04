import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';

class ToolbarButton extends StatelessWidget {
  static const double _labelTopOffset = 34;

  final IconData icon;
  final bool isToggled;
  final String semanticLabel;
  final String? semanticHint;
  final String? semanticValue;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final WidgetBuilder? bottomContentBuilder;

  const ToolbarButton({
    super.key,
    required this.icon,
    this.isToggled = false,
    required this.semanticLabel,
    this.semanticHint,
    this.semanticValue,
    required this.onPressed,
    this.onLongPress,
    this.bottomContentBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Semantics(
            label: semanticLabel,
            hint: semanticHint,
            value: semanticValue,
            toggled: isToggled,
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
        ),
        if (bottomContentBuilder != null && isToggled)
          Positioned(
            top: _labelTopOffset,
            child: ExcludeSemantics(child: bottomContentBuilder!(context)),
          ),
      ],
    );
  }
}
