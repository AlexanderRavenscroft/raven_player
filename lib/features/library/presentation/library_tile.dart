import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/pop_ups/app_input_dialog.dart';
import 'package:slideable/slideable.dart';

class LibraryTile extends ConsumerWidget {
  final Audiobook book;
  const LibraryTile({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
          child: Slideable(
            resetSlide: true,
            duration: Duration(milliseconds: 1),
            items: [
              //* RENAME
              ActionItems(
                backgroudColor: Theme.of(context).colorScheme.surfaceContainer,
                icon: Icon(
                  Icons.draw,
                  size: context.titleMedium,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPress: () async {
                  final renameController = TextEditingController(
                    text: book.title,
                  );
                  final newName = await showDialog(
                    context: context,
                    builder: (context) => AppInputDialog(
                      title: 'Rename Audiobook',
                      hintText: 'Enter new audiobook title',
                      textEditingController: renameController,
                    ),
                  );
                  if (newName != null && newName.isNotEmpty) {
                    ref
                        .read(libraryProvider.notifier)
                        .renameAudiobook(book, newName);
                  }
                },
              ),
              //* SWAP
              ActionItems(
                backgroudColor: Theme.of(context).colorScheme.secondary,
                icon: Icon(
                  Icons.move_up,
                  size: context.titleMedium,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPress: () {
                  ref.read(libraryProvider.notifier).toggleReadStatus(book);
                },
              ),
            ],
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AudiobookCover(book: book, isOnTile: true),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.024),
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
                        SizedBox(height: 4),
                        Text(
                          book.author ?? 'Unknown author',
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
          onTap: () {
            // final bool hasChapters = ref
            //     .read(libraryProvider.notifier)
            //     .checkIfBookHasChapters(book.directory);

            // if (hasChapters) {
            //   ScaffoldMessenger.of(context).clearSnackBars();
            //   Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(builder: (context) => PlayPage(book: book)),
            //   );
            // } else {
            //   AppSnackBar.showSnackBar(
            //     context,
            //     'No chapters found in this audiobook.\nCheck if the audiobook has chapters',
            //     durationSec: 4,
            //   );
            // }
          },
        ),

        Divider(
          color: Theme.of(context).colorScheme.surfaceContainer,
          thickness: 1,
        ),
      ],
    );
  }
}
