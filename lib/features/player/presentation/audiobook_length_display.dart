import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
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
    // final chapterInfo = ref.watch(
    //    audiobookProgressProvider(book).select(
    //      (progress) => (
    //        currentChapter: progress.currentChapterIndex,
    //        totalChapters: progress.chapterCount,
    //      ),
    //    ),
    // );

    return Text(
      'Chapter XXX',
      // 'Chapter ${chapterInfo.currentChapter + 1} of ${chapterInfo.totalChapters}',
      style: context.appText.labelLarge,
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  final Audiobook book;
  const _ProgressBar({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final progressValue = ref.watch(
    //   audiobookProgressProvider(book).select(
    //     (progress) =>
    //         progress.readMinutes /
    //         (progress.totalMinutes == 0 ? 1 : progress.totalMinutes),
    //   ),
    // );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.02,
      child: LinearProgressIndicator(
        // value: progressValue,
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

  String formatMinutes(int minutes) {
    final duration = Duration(minutes: minutes);
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;
    return '$hours:${mins.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final timeInfo = ref.watch(
    //   audiobookProgressProvider(book).select(
    //     (progress) => (
    //       read: progress.readMinutes,
    //       total: progress.totalMinutes,
    //       left: progress.leftMinutes,
    //       percentage: progress.percentage,
    //     ),
    //   ),
    // );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Text(
        //   'Read ${formatMinutes(timeInfo.read)} of ${formatMinutes(timeInfo.total)}  (${timeInfo.percentage.toStringAsFixed(0)}%)',
        //   style: context.appText.labelLarge,
        // ),
        // Text(
        //   'Left: ${formatMinutes(timeInfo.left)}',
        //   style: context.appText.labelLarge,
        // ),
      ],
    );
  }
}
