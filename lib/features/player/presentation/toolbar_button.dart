import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';

class ToolbarButton extends StatelessWidget {
  static const double _labelTopOffset = 34;

  final IconData icon;
  final bool isToggled;
  final bool hasToggleState;
  final bool includeLongPressSemantics;
  final String semanticLabel;
  final String? semanticHint;
  final String? semanticTapHint;
  final String? semanticLongPressHint;
  final String? semanticValue;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final WidgetBuilder? bottomContentBuilder;

  const ToolbarButton({
    super.key,
    required this.icon,
    this.isToggled = false,
    this.hasToggleState = true,
    this.includeLongPressSemantics = true,
    required this.semanticLabel,
    this.semanticHint,
    this.semanticTapHint,
    this.semanticLongPressHint,
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
            container: true,
            excludeSemantics: true,
            label: semanticLabel,
            hint: semanticHint,
            onTapHint: semanticTapHint,
            onLongPressHint: includeLongPressSemantics
                ? semanticLongPressHint
                : null,
            value: semanticValue,
            button: true,
            enabled: true,
            toggled: hasToggleState ? isToggled : null,
            onTap: onPressed,
            onLongPress: includeLongPressSemantics ? onLongPress : null,
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
