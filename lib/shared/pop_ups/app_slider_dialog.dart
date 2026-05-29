import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class AppSliderDialog extends StatefulWidget {
  final String title;
  final double minValue;
  final double maxValue;
  final double initialValue;
  final int? divisions;
  final String? confirmLabel;

  const AppSliderDialog({
    super.key,
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.divisions,
    this.confirmLabel,
  });

  @override
  State<AppSliderDialog> createState() => _AppSliderDialogState();
}

class _AppSliderDialogState extends State<AppSliderDialog> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.minValue, widget.maxValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrollable: false,
      title: Text(
        widget.title,
        style: context.appText.bodySmall,
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: MediaQuery.of(context).size.height * 0.01,
              ),
              child: Slider(
                value: _currentValue,
                min: widget.minValue,
                max: widget.maxValue,
                divisions: widget.divisions,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.surfaceContainer,

                onChanged: (value) => setState(() => _currentValue = value),
              ),
            ),
            Text(
              _currentValue % 1 == 0
                  ? _currentValue.toInt().toString()
                  : _currentValue.toStringAsFixed(2),
              style: context.appText.labelLarge,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(context.l10n.dialogCancel, style: context.appText.labelLarge),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            widget.confirmLabel ?? context.l10n.dialogConfirm,
            style: context.appText.labelLarge,
          ),
          onPressed: () => Navigator.pop(context, _currentValue),
        ),
      ],
    );
  }
}
