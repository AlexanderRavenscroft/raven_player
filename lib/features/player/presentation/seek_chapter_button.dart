import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';

class SeekChapterButton extends ConsumerWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const SeekChapterButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final playerState = playerStateAsync.value;
    final isPlaying = playerState?.playing ?? false;

    final isPauseLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPauseLockEnabled),
    );
    return IconButton(
      icon: Icon(
        icon,
        size: context.titleMedium,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: () {
        if (!isPlaying && isPauseLockEnabled) {
          AppSnackBar.showSnackBar(
            context,
            'Buttons are locked during pause.\nYou can enable them in settings',
          );
        } else {
          onPressed();
        }
      },
    );
  }
}
