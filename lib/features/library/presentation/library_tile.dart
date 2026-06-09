import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/library/application/audiobook_availability_checker.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/presentation/play_page.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/others/audiobook_cover.dart';
import 'package:raven_player/shared/dialogs/app_input_dialog.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class LibraryTile extends ConsumerWidget {
  static const double _actionPaneExtentRatio = 0.2;
  static const double _toggleDismissThreshold = 0.4;
  static const double _renameDismissThreshold = 0.01;
  static const double _tileHeightFactor = 0.1;

  final Audiobook book;

  const LibraryTile({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For read books the panes are swapped: rename on the right, toggle on the left
    final startPane = book.isRead
        ? _buildRenamePane(context, ref)
        : _buildToggleStatusPane(
            context,
            ref,
            AppIcons.toggleReadStatusToRight,
          );
    final endPane = book.isRead
        ? _buildToggleStatusPane(context, ref, AppIcons.toggleReadStatusToLeft)
        : _buildRenamePane(context, ref);

    final tileHeight = MediaQuery.sizeOf(context).height * _tileHeightFactor;

    return Column(
      children: [
        Slidable(
          key: ValueKey('library_tile_${book.id}'),
          startActionPane: startPane,
          endActionPane: endPane,
          child: GestureDetector(
            onTap: () => _openAudiobook(context, ref),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: tileHeight),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AudiobookCover(book: book, isOnTile: true),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: tileHeight),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              book.author ?? context.l10n.libraryUnknownAuthor,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceContainer,
          thickness: 1,
        ),
      ],
    );
  }

  ActionPane _buildToggleStatusPane(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
  ) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: _actionPaneExtentRatio,
      dismissible: DismissiblePane(
        dismissThreshold: _toggleDismissThreshold,
        closeOnCancel: true,
        onDismissed: () {
          _toggleReadStatus(ref);
        },
      ),
      children: [
        CustomSlidableAction(
          onPressed: (_) {
            _toggleReadStatus(ref);
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(
            icon,
            size: AppIconSizes.xLarge,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }

  ActionPane _buildRenamePane(BuildContext context, WidgetRef ref) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: _actionPaneExtentRatio,
      dismissible: DismissiblePane(
        dismissThreshold: _renameDismissThreshold,
        closeOnCancel: true,
        onDismissed: () {},
        confirmDismiss: () => _renameAudiobook(context, ref),
      ),
      children: [
        CustomSlidableAction(
          onPressed: (_) async {
            await _renameAudiobook(context, ref);
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          child: Icon(
            AppIcons.rename,
            size: AppIconSizes.xLarge,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _toggleReadStatus(WidgetRef ref) {
    ref.read(libraryProvider.notifier).toggleReadStatus(book);
  }

  Future<bool> _renameAudiobook(BuildContext context, WidgetRef ref) async {
    final renameController = TextEditingController(text: book.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AppInputDialog(
        title: context.l10n.libraryRenameTitle,
        hintText: context.l10n.libraryRenameHint,
        confirmText: context.l10n.dialogRename,
        textEditingController: renameController,
      ),
    );
    final trimmedTitle = newTitle?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      await ref
          .read(libraryProvider.notifier)
          .renameAudiobook(book, trimmedTitle);
    }

    return false;
  }

  Future<void> _openAudiobook(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(audiobookAvailabilityCheckerProvider)
          .ensureAvailable(book);
    } on AudiobookUnavailableException {
      if (!context.mounted) return;

      AppSnackBar.showSnackBar(
        context,
        context.l10n.libraryAudiobookUnavailable,
        type: SnackBarType.error,
        replacePrevious: true,
      );
      await ref.read(libraryProvider.notifier).rescan();
      await ref.read(playerProvider.notifier).clear();
      return;
    }

    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => PlayPage(enrichedBook: book),
      ),
    );
  }
}
