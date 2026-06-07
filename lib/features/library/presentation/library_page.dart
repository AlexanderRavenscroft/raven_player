import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/library/application/library_filter.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/library/presentation/library_app_bar.dart';
import 'package:raven_player/features/library/presentation/library_filter_toggle.dart';
import 'package:raven_player/features/library/presentation/library_tile.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';

class LibraryPage extends ConsumerWidget {
  static final List<Audiobook> _skeletonBooks = List.unmodifiable(
    List.generate(
      6,
      (i) => Audiobook(
        folderUri: '',
        chapters: const [],
        id: 'skeleton_$i',
        title: 'Loading title ${'x' * (i % 3 * 5 + 4)}',
        author: 'Author name ${'x' * (i % 3 * 5)}',
      ),
    ),
  );

  const LibraryPage({super.key});

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
              loading: () => _buildList(_skeletonBooks, isLoading: true),
              error: (error, _) => _buildMessage(
                context,
                context.l10n.libraryLoadingError(error.toString()),
              ),
              data: (_) {
                final books = ref.watch(filteredLibraryProvider);
                if (books.isEmpty) {
                  return _buildMessage(context, context.l10n.libraryEmpty);
                }
                return _buildList(books, isLoading: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Audiobook> books, {required bool isLoading}) {
    return Skeletonizer(
      enabled: isLoading,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          message,
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
