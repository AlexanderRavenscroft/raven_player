import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/library/application/library_filter.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/library/presentation/library_app_bar.dart';
import 'package:raven_player/features/library/presentation/library_filter_toggle.dart';
import 'package:raven_player/features/library/presentation/library_tile.dart';
import 'package:raven_player/models/audiobook.dart';

import 'package:skeletonizer/skeletonizer.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});
  static final _skeletonBooks = List.generate(
    6,
    (i) => Audiobook(
      folderUri: '',
      chapters: const [],
      id: 'skeleton_$i',
      title: 'Loading title ${'x' * (i % 3 * 5 + 4)}',
      author: 'Author name ${'x' * (i % 3 * 5)}',
    ),
  );
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(libraryProvider);

    return Scaffold(
      appBar: const LibraryAppBar(),
      body: Column(
        children: [
          const LibraryFilterToggle(),
          Expanded(
            child: booksAsync.when(
              loading: () =>
                  _buildList(context, _skeletonBooks, isLoading: true),
              error: (err, st) =>
                  _buildMessage(context, 'Error loading library:\n$err'),
              data: (_) {
                final books = ref.watch(filteredLibraryProvider);
                if (books.isEmpty) {
                  return _buildMessage(context, 'No audiobooks found');
                }
                return _buildList(context, books, isLoading: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<Audiobook> books, {
    required bool isLoading,
  }) {
    return Skeletonizer(
      enabled: isLoading,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.02,
        ),
        child: SlidableAutoCloseBehavior(
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (_, index) {
              final book = books[index];
              return LibraryTile(key: ValueKey(book.id), book: book);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
        ),
        child: Text(
          message,
          style: context.appText.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
