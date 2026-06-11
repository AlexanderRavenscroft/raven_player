import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

class PlayButton extends ConsumerStatefulWidget {
  final Widget? coverWidget;

  const PlayButton({super.key}) : coverWidget = null;

  const PlayButton.cover({super.key, required this.coverWidget});

  @override
  ConsumerState<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends ConsumerState<PlayButton> {
  static const _bufferingGrace = Duration(milliseconds: 250);

  Timer? _bufferingTimer;
  bool _showBuffering = false;

  @override
  void dispose() {
    _bufferingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coverWidget = widget.coverWidget;
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final playerState = playerStateAsync.value;
    final processing = playerState?.processingState;
    final playing = playerState?.playing ?? false;

    final isBuffering =
        processing == ProcessingState.loading ||
        processing == ProcessingState.buffering;

    IconData iconData;
    VoidCallback? onPressed;

    if (isBuffering && _showBuffering) {
      iconData = AppIcons.loading;
      onPressed = null;
    } else if (processing == ProcessingState.completed) {
      iconData = AppIcons.replay;
      onPressed = () => ref.read(playerProvider.notifier).replay();
    } else if (playing) {
      iconData = AppIcons.pause;
      onPressed = () => ref.read(playerProvider.notifier).pause();
    } else {
      iconData = AppIcons.play;
      onPressed = () => ref.read(playerProvider.notifier).play();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBuffering(isBuffering);
    });

    if (coverWidget == null) {
      return IconButton(
        icon: Icon(iconData, size: AppIconSizes.hero),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(AppSpacing.lg),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onPressed,
      );
    }

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          coverWidget,
          if (isPlayerLockEnabled)
            Icon(
              iconData,
              color: Theme.of(context).colorScheme.onPrimary,
              size: AppIconSizes.hero,
            ),
        ],
      ),
    );
  }

  void _handleBuffering(bool isBuffering) {
    if (isBuffering) {
      if (_bufferingTimer == null && !_showBuffering) {
        _bufferingTimer = Timer(_bufferingGrace, () {
          if (mounted) setState(() => _showBuffering = true);
        });
      }
    } else {
      _bufferingTimer?.cancel();
      _bufferingTimer = null;
      if (_showBuffering) {
        setState(() => _showBuffering = false);
      }
    }
  }
}
