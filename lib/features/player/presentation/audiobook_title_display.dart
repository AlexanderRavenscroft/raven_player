import 'package:flutter/widgets.dart';
import 'package:marquee/marquee.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class AudiobookTitleDisplay extends StatelessWidget {
  final String text;

  const AudiobookTitleDisplay({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = context.appText.bodySmall!;
        final textSpan = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: textSpan,
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: double.infinity);

        if (tp.width <= constraints.maxWidth) {
          return Text(text, style: style, overflow: TextOverflow.ellipsis);
        } else {
          return SizedBox(
            height: style.fontSize! * 1.5,
            child: Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              blankSpace: constraints.maxWidth / 2,
              velocity: 30.0,
            ),
          );
        }
      },
    );
  }
}
