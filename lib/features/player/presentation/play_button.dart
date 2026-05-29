import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';

class PlayButton extends ConsumerStatefulWidget {
  final bool asStandaloneButton;
  final Widget? coverWidget;

  const PlayButton({
    super.key,
    this.asStandaloneButton = true,
    this.coverWidget,
  });

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

  @override
  Widget build(BuildContext context) {
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final playerState = playerStateAsync.value;
    final processing = playerState?.processingState;
    final playing = playerState?.playing ?? false;

    final isBuffering =
        processing == ProcessingState.loading ||
        processing == ProcessingState.buffering;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBuffering(isBuffering);
    });

    IconData iconData;
    VoidCallback? onPressed;

    if (isBuffering && _showBuffering) {
      iconData = AppIcons.loading;
      onPressed = null;
    } else if (processing == ProcessingState.completed) {
      iconData = AppIcons.replay;
      onPressed = () => ref.read(playerProvider.notifier).seekToStart();
    } else if (playing) {
      iconData = AppIcons.pause;
      onPressed = () => ref.read(playerProvider.notifier).pause();
    } else {
      iconData = AppIcons.play;
      onPressed = () => ref.read(playerProvider.notifier).play();
    }

    if (widget.asStandaloneButton) {
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

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.coverWidget != null)
            Positioned.fill(child: widget.coverWidget!),
          if (isPlayerLockEnabled)
            Icon(
              iconData,
              color: Theme.of(context).colorScheme.onPrimary,
              size: context.headlineMedium,
            ),
        ],
      ),
    );
  }
}
