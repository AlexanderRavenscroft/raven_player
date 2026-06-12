import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/loading/app_circular_progress_indicator.dart';

class AudiobookCover extends StatelessWidget {
  static const _playerCoverLoadingPadding = 140.0;
  final Audiobook book;
  final bool isOnTile;

  const AudiobookCover({super.key, required this.book, required this.isOnTile});

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final coverWidth = isOnTile
        ? mediaSize.width * 0.24
        : math.min(mediaSize.width * 0.92, mediaSize.height * 0.5);
    final coverHeight = coverWidth;

    final iconSize = coverWidth * 0.8;
    final blur = isOnTile ? 0.0 : 4.0;

    final Widget cover = (book.coverPath == null)
        ? _buildDefaultCover(context, iconSize, blur)
        : Image.file(
            File(book.coverPath!),
            fit: isOnTile ? BoxFit.contain : BoxFit.cover,
            frameBuilder: (_, child, frame, _) {
              if (frame == null) {
                return Padding(
                  padding: EdgeInsets.all(
                    isOnTile ? AppSpacing.xxl : _playerCoverLoadingPadding,
                  ), //TODO: Think about frame builder
                  child: const AppCircularProgressIndicator(),
                );
              }
              return child;
            },
            errorBuilder: (_, _, _) =>
                _buildDefaultCover(context, iconSize, blur),
          );

    return SizedBox(
      width: coverWidth,
      height: coverHeight,
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: cover),
    );
  }

  Widget _buildDefaultCover(
    BuildContext context,
    double iconSize,
    double blur,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainer,
                colors.surfaceContainer.withAlpha((0.85 * 255).toInt()),
              ],
              stops: const [0.3, 0.9],
            ),
          ),
        ),
        if (blur > 0)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(color: Colors.transparent),
          ),
        Center(
          child: Icon(
            AppIcons.fallbackBook,
            size: iconSize,
            color: colors.surface.withAlpha(255),
          ),
        ),
      ],
    );
  }
}
