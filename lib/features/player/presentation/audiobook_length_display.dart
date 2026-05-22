import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookLengthDisplay extends StatelessWidget {
  final Audiobook book;
  const AudiobookLengthDisplay({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChapterInfoText(book: book),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        _ProgressBar(book: book),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        _TimeInfoText(book: book),
      ],
    );
  }
}

class _ChapterInfoText extends ConsumerWidget {
  final Audiobook book;
  const _ChapterInfoText({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChapter = ref.watch(
      playerProvider.select((b) => b?.currentChapterIndex ?? 0),
    );

    return Text('Chapter ${currentChapter + 1} of ${book.chapters.length}');
  }
}

class _ProgressBar extends ConsumerWidget {
  final Audiobook book;
  const _ProgressBar({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionData = ref.watch(positionDataStreamProvider).value;
    final currentChapter = ref.watch(
      playerProvider.select((b) => b?.currentChapterIndex ?? 0),
    );

    final totalMs = book.totalDurationMs ?? 1;
    final pastMs = _sumPastChapters(book, currentChapter);
    final currentMs = positionData?.position.inMilliseconds ?? 0;
    final progressValue = (pastMs + currentMs) / totalMs;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.02,
      child: LinearProgressIndicator(
        value: progressValue.clamp(0.0, 1.0),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}

class _TimeInfoText extends ConsumerWidget {
  final Audiobook book;
  const _TimeInfoText({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionData = ref.watch(positionDataStreamProvider).value;
    final currentChapter = ref.watch(
      playerProvider.select((b) => b?.currentChapterIndex ?? 0),
    );

    final totalMs = book.totalDurationMs ?? 0;
    final pastMs = _sumPastChapters(book, currentChapter);
    final currentMs = positionData?.position.inMilliseconds ?? 0;
    final readMs = pastMs + currentMs;
    final leftMs = (totalMs - readMs).clamp(0, totalMs);

    final read = Duration(milliseconds: readMs);
    final total = Duration(milliseconds: totalMs);
    final left = Duration(milliseconds: leftMs);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Read ${_format(read)} of ${_format(total)} (${(readMs / (totalMs == 0 ? 1 : totalMs) * 100).toStringAsFixed(0)}%)',
        ),
        Text('Left: ${_format(left)}'),
      ],
    );
  }
}

int _sumPastChapters(Audiobook book, int currentChapterIndex) {
  final safeIndex = currentChapterIndex.clamp(0, book.chapters.length - 1);
  int sum = 0;
  for (int i = 0; i < safeIndex; i++) {
    sum += book.chapters[i].durationMs ?? 0;
  }
  return sum;
}

String _format(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  return '$h:$m';
}
