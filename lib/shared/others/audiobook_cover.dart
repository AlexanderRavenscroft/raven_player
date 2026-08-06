import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/loading/app_circular_progress_indicator.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AudiobookCover extends StatelessWidget {
  static const _playerCoverLoadingPadding = 148.0;
  static const _tileBorderRadius = 12.0;
  final Audiobook book;
  final bool isOnTile;
  final bool showLoadingSkeleton;

  const AudiobookCover({
    super.key,
    required this.book,
    required this.isOnTile,
    this.showLoadingSkeleton = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final coverWidth = isOnTile
        ? mediaSize.width * 0.24
        : math.min(mediaSize.width * 0.92, mediaSize.height * 0.5);
    final coverHeight = coverWidth;

    final iconSize = coverWidth * 0.8;
    final blur = isOnTile ? 0.0 : 4.0;

    final Widget cover;
    if (showLoadingSkeleton && !isOnTile) {
      cover = DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(_tileBorderRadius),
        ),
      );
    } else if (book.coverPath == null) {
      cover = _buildDefaultCover(context, iconSize, blur);
    } else {
      cover = Image.file(
        File(book.coverPath!),
        fit: isOnTile ? BoxFit.contain : BoxFit.cover,
        frameBuilder: (_, child, frame, _) {
          if (frame == null) {
            return _buildPlaceholder(
              context,
              blur,
              child: Padding(
                padding: EdgeInsets.all(
                  isOnTile ? AppSpacing.xxl : _playerCoverLoadingPadding,
                ),
                child: const AppCircularProgressIndicator(),
              ),
            );
          }
          return child;
        },
        errorBuilder: (_, _, _) => _buildDefaultCover(context, iconSize, blur),
      );
    }

    return SizedBox(
      width: coverWidth,
      height: coverHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_tileBorderRadius),
        child: cover,
      ),
    );
  }

  Widget _buildDefaultCover(
    BuildContext context,
    double iconSize,
    double blur,
  ) {
    final colors = Theme.of(context).colorScheme;
    return _buildPlaceholder(
      context,
      blur,
      child: Center(
        child: Skeleton.replace(
          height: iconSize,
          width: iconSize,
          replacement: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.onSurfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Icon(
            AppIcons.fallbackBook,
            size: iconSize,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(
    BuildContext context,
    double blur, {
    required Widget child,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          enabled: blur > 0,
          imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
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
        ),
        child,
      ],
    );
  }
}
