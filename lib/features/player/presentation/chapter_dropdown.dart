import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class ChapterDropdown extends ConsumerWidget {
  static const _dropdownWidthRatio = 0.5;
  static const _menuWidthRatio = 0.5;
  static const _menuWidthSafeMarginRatio = 0.4;
  const ChapterDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(playerProvider);
    if (currentBook == null) return const SizedBox.shrink();

    final chapters = currentBook.chapters;
    final currentChapterIndex = currentBook.currentChapterIndex;

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * _dropdownWidthRatio,
      child: Center(
        child: GestureDetector(
          onTap: () {
            if (isPlayerLockEnabled) {
              AppSnackBar.showSnackBar(
                context,
                context.l10n.playerLockedMessage,
              );
            }
          },
          child: AbsorbPointer(
            absorbing: isPlayerLockEnabled,
            child: DropdownButton<int>(
              elevation: 8,
              autofocus: false,
              alignment: Alignment.center,
              icon: isPlayerLockEnabled
                  ? const SizedBox.shrink()
                  : const Icon(AppIcons.dropdown),
              iconSize: AppSpacing.xl,
              menuWidth: MediaQuery.of(context).size.width * _menuWidthRatio,
              menuMaxHeight:
                  MediaQuery.of(context).size.height * _dropdownWidthRatio,
              dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
              focusColor: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w600),

              items: List.generate(
                chapters.length,
                (index) => DropdownMenuItem<int>(
                  alignment: AlignmentGeometry.centerStart,
                  value: index,
                  child: SizedBox(
                    width:
                        MediaQuery.of(context).size.width *
                        _menuWidthSafeMarginRatio,
                    child: Text(
                      chapters[index].name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                growable: false,
              ),
              value: currentChapterIndex,
              onChanged: (value) async {
                if (value != null && value != currentChapterIndex) {
                  await ref.read(playerProvider.notifier).seekToChapter(value);
                  ref
                      .read(sleepTimerProvider.notifier)
                      .resetFromListeningActivity();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
