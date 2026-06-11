import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/shared/dialogs/app_scrollable_dialog.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? trailing;

  static const double _tileHeight = 90;
  static const double _leadingWidth = 40;
  static const double _trailingMinWidth = 56;
  static const double _titleLineHeight = 1.2;
  static const double _descriptionLineHeight = 1.25;

  const SettingsTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final textScaler = MediaQuery.textScalerOf(context);
    final titleStyle = textTheme.titleSmall!.copyWith(height: _titleLineHeight);
    final descriptionStyle = textTheme.bodySmall!.copyWith(
      height: _descriptionLineHeight,
    );
    final titleHeight = _scaledLineHeight(
      style: titleStyle,
      textScaler: textScaler,
      fallbackFontSize: 16,
      height: _titleLineHeight,
    );
    final descriptionHeight = _scaledLineHeight(
      style: descriptionStyle,
      textScaler: textScaler,
      fallbackFontSize: 13,
      height: _descriptionLineHeight,
    );

    return Column(
      children: [
        SizedBox(
          height: _tileHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onLongPress: () => _showDetailsDialog(context),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _leadingWidth,
                          child: Center(
                            child: Icon(
                              icon,
                              size: AppIconSizes.large,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: titleHeight,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    title,
                                    style: titleStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              SizedBox(
                                height: descriptionHeight * 2,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    description,
                                    style: descriptionStyle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: _trailingMinWidth,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      widthFactor: 1,
                      child: trailing,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Divider(
          color: colorScheme.surfaceContainer,
          thickness: 1,
          height: AppSpacing.sm,
        ),
      ],
    );
  }

  double _scaledLineHeight({
    required TextStyle style,
    required TextScaler textScaler,
    required double fallbackFontSize,
    required double height,
  }) {
    return textScaler.scale(style.fontSize ?? fallbackFontSize) * height;
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AppScrollableDialog(
        headingIcon: icon,
        headingText: title,
        content: description,
      ),
    );
  }
}
