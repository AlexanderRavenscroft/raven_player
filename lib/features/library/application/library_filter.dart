import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/models/audiobook.dart';

enum LibraryFilter { reading, read }

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => LibraryFilter.reading;

  void setFilter(LibraryFilter filter) => state = filter;
}

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilter>(
      LibraryFilterNotifier.new,
    );

final filteredLibraryProvider = Provider<List<Audiobook>>((ref) {
  final books = ref.watch(libraryProvider).requireValue;
  final filter = ref.watch(libraryFilterProvider);

  return books
      .where(
        (book) => filter == LibraryFilter.read ? book.isRead : !book.isRead,
      )
      .toList();
});
