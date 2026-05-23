import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

class PlayButton extends ConsumerWidget {
  final bool asStandaloneButton;
  final Widget? coverWidget;

  const PlayButton({
    super.key,
    this.asStandaloneButton = true,
    this.coverWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerStateAsync = ref.watch(playerStateStreamProvider);

    final playerState = playerStateAsync.value;
    final processing = playerState?.processingState;
    final playing = playerState?.playing ?? false;

    IconData iconData;
    VoidCallback? onPressed;

    if (processing == ProcessingState.loading ||
        processing == ProcessingState.buffering) {
      iconData = Icons.hourglass_empty_rounded;
      onPressed = null;
    } else if (processing == ProcessingState.completed) {
      iconData = Icons.replay_rounded;
      onPressed = () => ref.read(playerProvider.notifier).seekToStart();
    } else if (playing) {
      iconData = Icons.pause_rounded;
      onPressed = () => ref.read(playerProvider.notifier).pause();
    } else {
      iconData = Icons.play_arrow_rounded;
      onPressed = () => ref.read(playerProvider.notifier).play();
    }

    if (asStandaloneButton) {
      return IconButton(
        icon: Icon(iconData, size: context.headlineMedium),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.all(context.labelSmall),
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed,
      );
    }
    final isCoverPlayEnabled = ref.watch(
      settingsProvider.select((s) => s.isCoverPlayEnabled),
    );
    return GestureDetector(
      onTap: isCoverPlayEnabled ? onPressed : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (coverWidget != null) Positioned.fill(child: coverWidget!),
          // if (isCoverPlayEnabled)
          //   Icon(
          //     iconData,
          //     color: Theme.of(context).colorScheme.onPrimary,
          //     size: context.headlineMedium,
          //   ),
        ],
      ),
    );
  }
}
