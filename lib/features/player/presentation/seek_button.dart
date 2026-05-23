import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class SeekButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const SeekButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        icon,
        size: context.headlineSmall,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        onPressed();
        // final bool isPlaying = ref.read(playerProvider.notifier).player.playing;
        // final bool isLockedControls = ref.read(settingsProvider).isLockedControls;
        // if(!isPlaying && isLockedControls) {
        //   AppSnackBar.showSnackBar(
        //     context,
        //     'Buttons are locked during pause.\nYou can enable them in settings',
        //   );
        // } else {
        //   onPressed();
        // }
      },
    );
  }
}
