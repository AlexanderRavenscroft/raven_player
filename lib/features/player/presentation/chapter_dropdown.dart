import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/sleep_timer_notifier.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/dialogs/dialog_action_button.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class ChapterDropdown extends ConsumerWidget {
  static const _dropdownWidthRatio = 0.5;
  static const _dialogHeightRatio = 0.5;

  final Audiobook book;

  const ChapterDropdown({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBook = ref.watch(playerProvider) ?? book;

    final chapters = currentBook.chapters;
    final currentChapterIndex = currentBook.currentChapterIndex;
    final currentChapterName =
        currentChapterIndex >= 0 && currentChapterIndex < chapters.length
        ? chapters[currentChapterIndex].name
        : context.l10n.noChaptersFound;

    final isPlayerLockEnabled = ref.watch(
      settingsProvider.select((s) => s.isPlayerLockEnabled),
    );

    Future<void> handleTap() async {
      if (isPlayerLockEnabled) {
        AppSnackBar.showSnackBar(context, context.l10n.playerLockedMessage);
        return;
      }

      await _showChapterDialog(context, ref, currentBook);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * _dropdownWidthRatio,
      child: Semantics(
        button: true,
        label: context.l10n.playerChooseChapterAction,
        value: currentChapterName,
        excludeSemantics: true,
        onTap: handleTap,
        child: InkWell(
          enableFeedback: !isPlayerLockEnabled,
          overlayColor: isPlayerLockEnabled
              ? const WidgetStatePropertyAll(Colors.transparent)
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          onTap: handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    currentChapterName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (!isPlayerLockEnabled)
                  const Icon(AppIcons.dropdown, size: AppIconSizes.large),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChapterDialog(
    BuildContext context,
    WidgetRef ref,
    Audiobook currentBook,
  ) async {
    final chapters = currentBook.chapters;
    final currentChapterIndex = currentBook.currentChapterIndex;

    final selectedChapterIndex = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final listMaxHeight =
            MediaQuery.sizeOf(dialogContext).height * _dialogHeightRatio;

        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.md,
            0,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: listMaxHeight),
              child: chapters.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: Text(
                        dialogContext.l10n.noChaptersFound,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _ChapterList(
                      book: currentBook,
                      maxHeight: listMaxHeight,
                      selectedTextColor: colorScheme.secondary,
                      onChapterSelected: (index) =>
                          Navigator.pop(dialogContext, index),
                    ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          actions: [
            DialogActionButton(
              text: dialogContext.l10n.dialogCancel,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );

    if (!context.mounted ||
        selectedChapterIndex == null ||
        selectedChapterIndex == currentChapterIndex) {
      return;
    }

    await ref.read(playerProvider.notifier).seekToChapter(selectedChapterIndex);
    ref.read(sleepTimerProvider.notifier).resetFromListeningActivity();
  }
}

class _ChapterList extends StatefulWidget {
  static const _tileHeight = 48.0;

  final Audiobook book;
  final double maxHeight;
  final Color selectedTextColor;
  final ValueChanged<int> onChapterSelected;

  const _ChapterList({
    required this.book,
    required this.maxHeight,
    required this.selectedTextColor,
    required this.onChapterSelected,
  });

  @override
  State<_ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<_ChapterList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    final currentChapterIndex = widget.book.currentChapterIndex;
    final initialChapterIndex =
        currentChapterIndex >= 0 &&
            currentChapterIndex < widget.book.chapters.length
        ? currentChapterIndex
        : 0;
    final contentHeight =
        widget.book.chapters.length * _ChapterList._tileHeight;
    final maxScrollOffset = contentHeight > widget.maxHeight
        ? contentHeight - widget.maxHeight
        : 0.0;
    final requestedScrollOffset =
        initialChapterIndex * _ChapterList._tileHeight;
    final initialScrollOffset = requestedScrollOffset < maxScrollOffset
        ? requestedScrollOffset
        : maxScrollOffset;

    _scrollController = ScrollController(
      initialScrollOffset: initialScrollOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapters = widget.book.chapters;
    final currentChapterIndex = widget.book.currentChapterIndex;

    return Scrollbar(
      controller: _scrollController,
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemExtent: _ChapterList._tileHeight,
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final isCurrentChapter = index == currentChapterIndex;

          return ListTile(
            dense: true,
            selected: isCurrentChapter,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            title: Text(
              chapters[index].name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: isCurrentChapter ? widget.selectedTextColor : null,
                fontWeight: isCurrentChapter
                    ? FontWeight.bold
                    : FontWeight.w600,
              ),
            ),
            onTap: () => widget.onChapterSelected(index),
          );
        },
      ),
    );
  }
}
