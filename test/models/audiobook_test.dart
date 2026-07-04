import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

void main() {
  group('Audiobook duration helpers', () {
    test('currentPosition converts milliseconds to Duration', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
        currentPositionMs: 90000,
      );

      expect(book.currentPosition, const Duration(seconds: 90));
    });

    test('totalDuration returns null when totalDurationMs is null', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
      );

      expect(book.totalDuration, isNull);
    });

    test('totalDuration converts milliseconds to Duration', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
        totalDurationMs: 125000,
      );

      expect(book.totalDuration, const Duration(seconds: 125));
    });
  });

  group('Audiobook metadata state', () {
    test(
      'needs metadata scan when metadata is missing and scan was not attempted',
      () {
        const book = Audiobook(
          id: 'book-1',
          title: 'Book',
          folderUri: 'folder-uri',
          chapters: [],
        );

        expect(book.hasBookMetadata, isFalse);
        expect(book.needsMetadataScan, isTrue);
      },
    );

    test('does not need metadata scan when author exists', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
        author: 'Author',
      );

      expect(book.hasBookMetadata, isTrue);
      expect(book.needsMetadataScan, isFalse);
    });

    test('does not need metadata scan when cover exists', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
        coverPath: 'cover.jpg',
      );

      expect(book.hasBookMetadata, isTrue);
      expect(book.needsMetadataScan, isFalse);
    });

    test('does not need metadata scan after scan was attempted', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
        isMetadataScanned: true,
      );

      expect(book.hasBookMetadata, isFalse);
      expect(book.needsMetadataScan, isFalse);
    });
  });

  group('Audiobook.copyWith', () {
    test('changes selected fields and preserves the rest', () {
      const book = Audiobook(
        id: 'book-1',
        title: 'Old Title',
        folderUri: 'folder-uri',
        chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
        currentChapterIndex: 1,
        currentPositionMs: 5000,
        isRead: false,
      );

      final updated = book.copyWith(title: 'New Title', isRead: true);

      expect(updated.id, 'book-1');
      expect(updated.title, 'New Title');
      expect(updated.folderUri, 'folder-uri');
      expect(updated.chapters, same(book.chapters));
      expect(updated.currentChapterIndex, 1);
      expect(updated.currentPositionMs, 5000);
      expect(updated.isRead, isTrue);
    });
  });
}
