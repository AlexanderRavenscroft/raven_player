import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/library_filter.dart';
import 'package:raven_player/features/library/presentation/library_app_bar.dart';
import 'package:raven_player/features/library/presentation/library_filter_toggle.dart';
import 'package:raven_player/features/library/presentation/library_tile.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(filteredLibraryProvider);

    return Scaffold(
      appBar: LibraryAppBar(),
      body: Column(
        children: [
          LibraryFilterToggle(),
          Expanded(
            child: booksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
              data: (books) {
                if (books.isEmpty) {
                  return const Center(child: Text('No audiobooks found'));
                }
                return Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (_, index) {
                      final book = books[index];
                      return LibraryTile(key: ValueKey(book.id), book: book);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
