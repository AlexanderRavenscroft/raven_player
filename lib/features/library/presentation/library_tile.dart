import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/player/presentation/play_page.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/audiobook_cover.dart';
import 'package:raven_player/shared/pop_ups/app_input_dialog.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class LibraryTile extends ConsumerWidget {
  final Audiobook book;
  const LibraryTile({super.key, required this.book});

  ActionPane _buildToggleStatusPane(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
  ) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: 0.2,
      // openThreshold: 0.99,
      // closeThreshold: 0.01,
      dismissible: DismissiblePane(
        dismissThreshold: 0.4,
        closeOnCancel: true,
        onDismissed: () {
          ref.read(libraryProvider.notifier).toggleReadStatus(book);
        },
      ),
      children: [
        CustomSlidableAction(
          onPressed: (_) {
            ref.read(libraryProvider.notifier).toggleReadStatus(book);
          },
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(
            icon,
            size: context.headlineSmall,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }

  ActionPane _buildRenamePane(BuildContext context, WidgetRef ref) {
    return ActionPane(
      motion: const BehindMotion(),
      extentRatio: 0.2,
      // openThreshold: 0.99,
      // closeThreshold: 0.01,
      dismissible: DismissiblePane(
        dismissThreshold: 0.01,
        closeOnCancel: true,
        onDismissed: () {
          ref.read(libraryProvider.notifier).toggleReadStatus(book);
        },
        confirmDismiss: () async {
          final renameController = TextEditingController(text: book.title);
          final newName = await showDialog<String>(
            context: context,
            builder: (context) => AppInputDialog(
              title: context.l10n.libraryRenameTitle,
              hintText: context.l10n.libraryRenameHint,
              textEditingController: renameController,
            ),
          );
          if (newName != null && newName.isNotEmpty) {
            ref.read(libraryProvider.notifier).renameAudiobook(book, newName);
          }
          return false;
        },
      ),
      children: [
        CustomSlidableAction(
          onPressed: (_) async {
            final renameController = TextEditingController(text: book.title);
            final newName = await showDialog<String>(
              context: context,
              builder: (context) => AppInputDialog(
                title: context.l10n.libraryRenameTitle,
                hintText: context.l10n.libraryRenameHint,
                textEditingController: renameController,
              ),
            );
            if (newName != null && newName.isNotEmpty) {
              ref.read(libraryProvider.notifier).renameAudiobook(book, newName);
            }
          },
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          child: Icon(
            AppIcons.rename,
            size: context.headlineSmall,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

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

    return Column(
      children: [
        Slidable(
          key: ValueKey(book.title),
          startActionPane: startPane,
          endActionPane: endPane,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayPage(enrichedBook: book),
                ),
              );
            },
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.008,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AudiobookCover(book: book, isOnTile: true),
                    SizedBox(width: MediaQuery.of(context).size.height * 0.012),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: context.appText.labelLarge!.withStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.004,
                          ),
                          Text(
                            book.author ?? context.l10n.libraryUnknownAuthor,
                            style: context.appText.labelMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
}
