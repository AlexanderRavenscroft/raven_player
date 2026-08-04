import 'package:flutter/material.dart';

class SettingsToggleSwitch extends StatelessWidget {
  final String semanticLabel;
  final bool value;
  final void Function(bool) onChanged;

  const SettingsToggleSwitch({
    super.key,
    required this.semanticLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Switch(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(context).colorScheme.surface,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
