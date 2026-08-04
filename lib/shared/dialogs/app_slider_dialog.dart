import 'package:flutter/material.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';

class AppSliderDialog extends StatefulWidget {
  final String title;
  final double minValue;
  final double maxValue;
  final double initialValue;
  final int? divisions;
  final String? confirmLabel;
  final String semanticLabel;
  final String Function(double value) semanticFormatterCallback;

  const AppSliderDialog({
    super.key,
    required this.title,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    this.divisions,
    this.confirmLabel,
    required this.semanticLabel,
    required this.semanticFormatterCallback,
  });

  @override
  State<AppSliderDialog> createState() => _AppSliderDialogState();
}

class _AppSliderDialogState extends State<AppSliderDialog> {
  static const _trackHeight = 8.0;
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
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: _trackHeight,
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Semantics(
              label: widget.semanticLabel,
              child: Slider(
                value: _currentValue,
                min: widget.minValue,
                max: widget.maxValue,
                divisions: widget.divisions,
                activeColor: Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.surfaceContainer,
                semanticFormatterCallback: widget.semanticFormatterCallback,
                onChanged: (value) => setState(() => _currentValue = value),
              ),
            ),
          ),
          Text(
            _currentValue % 1 == 0
                ? _currentValue.toInt().toString()
                : _currentValue.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        DialogActionButton(
          text: context.l10n.dialogCancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          text: widget.confirmLabel ?? context.l10n.dialogConfirm,
          onPressed: () => Navigator.pop(context, _currentValue),
        ),
      ],
    );
  }
}
