import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AudiobookTitleDisplay extends StatelessWidget {
  static const _titleSpeed = 30.0;

  final String text;

  const AudiobookTitleDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = Theme.of(context).textTheme.titleMedium!;
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          ellipsis: '...',
        )..layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Text(
            text,
            style: style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          );
        }

        return SizedBox(
          height: style.fontSize! * 1.5,
          child: Marquee(
            text: text,
            style: style,
            scrollAxis: Axis.horizontal,
            blankSpace: constraints.maxWidth / 2,
            velocity: _titleSpeed,
          ),
        );
      },
    );
  }
}
