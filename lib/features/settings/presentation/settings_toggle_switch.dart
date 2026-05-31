import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsToggleSwitch extends ConsumerWidget {
  final bool value;
  final void Function(bool) onChanged;
  const SettingsToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.9,
      child: Switch(
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(context).colorScheme.surface,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
