import 'package:flutter/material.dart';

class SettingsToggleSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;

  const SettingsToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      activeTrackColor: Theme.of(context).colorScheme.primary,
      inactiveTrackColor: Theme.of(context).colorScheme.surface,
      value: value,
      onChanged: onChanged,
    );
  }
}
