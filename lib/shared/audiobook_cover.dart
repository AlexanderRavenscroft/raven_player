import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookCover extends ConsumerWidget {
  final Audiobook book;
  final bool isOnTile;

  const AudiobookCover({super.key, required this.book, required this.isOnTile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final mediaHeight = MediaQuery.of(context).size.height;
    final coverWidth = mediaWidth * (isOnTile ? 0.24 : 0.46);
    final coverHeight = mediaHeight * (isOnTile ? 0.1 : 0.46);

    final iconSize = mediaHeight * (isOnTile ? 0.1 : 0.4);
    final blur = isOnTile ? 0.0 : 4.0;
    Widget cover = (book.coverPath == null)
        ? _buildDefaultCover(context, iconSize, blur)
        : Image.file(
            File(book.coverPath!),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _buildDefaultCover(context, iconSize, blur),
          );

    return SizedBox(
      width: coverWidth,
      height: coverHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // child: isOnTile
        //     ? cover
        //     : PlayButton(
        //       asStandaloneButton: false,
        //       coverWidget: cover,
        //       ),
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
            Icons.menu_book_rounded,
            size: iconSize,
            color: colors.surface.withAlpha(255),
          ),
        ),
      ],
    );
  }
}
