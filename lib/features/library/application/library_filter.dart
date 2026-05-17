import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/models/audiobook.dart';

enum LibraryFilter { reading, read }

final libraryFilterProvider =
    NotifierProvider<LibraryFilterNotifier, LibraryFilter>(
      LibraryFilterNotifier.new,
    );

class LibraryFilterNotifier extends Notifier<LibraryFilter> {
  @override
  LibraryFilter build() => LibraryFilter.reading;

  void setFilter(LibraryFilter filter) => state = filter;
}

final filteredLibraryProvider = Provider<List<Audiobook>>((ref) {
  final books = ref.watch(libraryProvider).requireValue;
  final filter = ref.watch(libraryFilterProvider);

  return books
      .where((b) => filter == LibraryFilter.read ? b.isRead : !b.isRead)
      .toList();
});
