import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class PlayButton extends ConsumerStatefulWidget {
  final Widget? coverWidget;

  const PlayButton({super.key}) : coverWidget = null;

  const PlayButton.cover({super.key, required this.coverWidget});

  @override
  ConsumerState<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends ConsumerState<PlayButton> {
  static const _bufferingGrace = Duration(milliseconds: 250);
  static const _coverControlBackground = Color(0xb3000000);
  static const _coverControlBorder = Color(0x66ffffff);

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
    String semanticLabel;
    VoidCallback? onPressed;

    if (isBuffering && _showBuffering) {
      iconData = AppIcons.loading;
      semanticLabel = context.l10n.playerPlaybackLoadingLabel;
      onPressed = null;
    } else if (processing == ProcessingState.completed) {
      iconData = AppIcons.replay;
      semanticLabel = context.l10n.playerReplayAction;
      onPressed = () => ref.read(audioHandlerProvider).replay();
    } else if (playing) {
      iconData = AppIcons.pause;
      semanticLabel = context.l10n.playerPauseAction;
      onPressed = () => ref.read(audioHandlerProvider).pause();
    } else {
      iconData = AppIcons.play;
      semanticLabel = context.l10n.playerPlayAction;
      onPressed = () => ref.read(audioHandlerProvider).play();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBuffering(isBuffering);
    });

    if (coverWidget == null) {
      return IconButton(
        tooltip: semanticLabel,
        icon: Icon(iconData, size: AppIconSizes.hero),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(AppSpacing.lg),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          disabledBackgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainer,
          disabledForegroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 8,
          shadowColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
        onPressed: onPressed,
      );
    }

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            coverWidget,
            if (isPlayerLockEnabled)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _coverControlBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: _coverControlBorder),
                ),
                child: Icon(
                  iconData,
                  color: Colors.white,
                  size: AppIconSizes.hero,
                ),
              ),
          ],
        ),
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
