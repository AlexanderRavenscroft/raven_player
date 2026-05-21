import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_provider.dart';
import 'package:raven_player/models/audiobook.dart';

class PlayChapterDropdown extends ConsumerWidget {
  final Audiobook book;
  const PlayChapterDropdown({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(playerProvider);
    if (currentBook == null) return const SizedBox.shrink();

    final chapterList = currentBook.chapters.map((c) => c.name).toList();

    final currentChapterIndex =
        ref.watch(currentChapterIndexProvider).value ?? 0;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Center(
        child: DropdownButton<int>(
          elevation: 8,
          autofocus: false,
          alignment: Alignment.center,
          menuWidth: MediaQuery.of(context).size.width * 0.5,
          menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
          focusColor: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          style: context.appText.labelLarge!.withStyle(
            fontWeight: FontWeight.w600,
          ),
          items: List.generate(
            chapterList.length,
            (index) => DropdownMenuItem<int>(
              value: index,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: Center(
                  child: Text(
                    chapterList[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            growable: false,
          ),
          value: currentChapterIndex,
          onChanged: (value) {
            if (value != null && value != currentChapterIndex) {
              ref.read(playerProvider.notifier).seekToChapter(value);
            }
          },
        ),
      ),
    );
  }
}
