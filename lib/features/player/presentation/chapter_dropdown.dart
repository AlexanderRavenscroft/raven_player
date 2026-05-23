import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';

class ChapterDropdown extends ConsumerWidget {
  final Audiobook book;
  const ChapterDropdown({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(playerProvider);
    if (currentBook == null) return const SizedBox.shrink();

    final chapterList = currentBook.chapters.map((c) => c.name).toList();
    final currentChapterIndex = currentBook.currentChapterIndex;

    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final playerState = playerStateAsync.value;
    final isPlaying = playerState?.playing ?? false;

    final isPauseLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPauseLockEnabled),
    );

    final isLocked = !isPlaying && isPauseLockEnabled;

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (isLocked) {
              AppSnackBar.showSnackBar(
                context,
                'Dropdown is locked during pause.\nYou can enable it in settings',
              );
            }
          },
          child: AbsorbPointer(
            absorbing: isLocked,
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
              onTap: () {
                if (!isPlaying && isPauseLockEnabled) {
                  AppSnackBar.showSnackBar(
                    context,
                    'Dropdown is locked during pause.\nYou can enable it in settings',
                  );
                }
              },
              onChanged: (value) {
                if (value != null && value != currentChapterIndex) {
                  ref.read(playerProvider.notifier).seekToChapter(value);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
