import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

void main() {
  const audiobookBoxName = 'audiobooks';
  late Directory hiveDir;
  late AudiobookRepository repo;

  setUpAll(() {
    hiveDir = Directory.systemTemp.createTempSync(
      'raven_player_repository_test_',
    );
    Hive.init(hiveDir.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AudiobookAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChapterAdapter());
    }
  });

  setUp(() async {
    repo = AudiobookRepository();
    final box = await Hive.openBox<Audiobook>(audiobookBoxName);
    await box.clear();
  });

  tearDown(() async {
    if (Hive.isBoxOpen(audiobookBoxName)) {
      await Hive.box<Audiobook>(audiobookBoxName).clear();
    }
  });

  tearDownAll(() async {
    await Hive.close();

    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  group('AudiobookRepository', () {
    test('saves and loads audiobook by id', () async {
      final book = _book(id: 'book-1', title: 'Book One');

      await repo.save(book);

      expect(await repo.getById('book-1'), isNotNull);
      expect((await repo.getById('book-1'))!.title, 'Book One');
      expect(await repo.getAll(), hasLength(1));
    });

    test('mergeScanResults inserts new scanned books', () async {
      final scanned = _book(
        id: 'book-1',
        title: 'Scanned Book',
        chapters: [_chapter(name: '01.mp3', uri: 'chapter-1')],
      );

      await repo.mergeScanResults([scanned]);

      final stored = await repo.getById('book-1');
      expect(stored, isNotNull);
      expect(stored!.title, 'Scanned Book');
      expect(stored.chapters, hasLength(1));
      expect(stored.chapters.single.uri, 'chapter-1');
    });

    test(
      'mergeScanResults preserves user-owned state for existing books',
      () async {
        final existing = _book(
          id: 'book-1',
          title: 'User Title',
          folderUri: 'old-folder-uri',
          author: 'Existing Author',
          coverPath: 'cover.jpg',
          totalDurationMs: 3000,
          currentChapterIndex: 1,
          currentPositionMs: 123456,
          isRead: true,
          isMetadataScanned: true,
          chapters: [
            _chapter(name: 'Old 1', uri: 'chapter-1', durationMs: 1000),
            _chapter(name: 'Old 2', uri: 'chapter-2', durationMs: 2000),
          ],
        );
        final scanned = _book(
          id: 'book-1',
          title: 'Scanned Title',
          folderUri: 'new-folder-uri',
          chapters: [
            _chapter(name: 'New 1', uri: 'chapter-1'),
            _chapter(name: 'New 3', uri: 'chapter-3'),
          ],
        );

        await repo.save(existing);
        await repo.mergeScanResults([scanned]);

        final stored = (await repo.getById('book-1'))!;
        expect(stored.title, 'User Title');
        expect(stored.folderUri, 'new-folder-uri');
        expect(stored.author, 'Existing Author');
        expect(stored.coverPath, 'cover.jpg');
        expect(stored.totalDurationMs, 3000);
        expect(stored.currentChapterIndex, 1);
        expect(stored.currentPositionMs, 123456);
        expect(stored.isRead, isTrue);
        expect(stored.isMetadataScanned, isTrue);

        expect(stored.chapters.map((chapter) => chapter.name), [
          'New 1',
          'New 3',
        ]);
        expect(stored.chapters[0].durationMs, 1000);
        expect(stored.chapters[1].durationMs, isNull);
      },
    );

    test(
      'mergeScanResults retries metadata when first chapter changes and book has no metadata',
      () async {
        final existing = _book(
          id: 'book-1',
          isMetadataScanned: true,
          chapters: [_chapter(name: 'Old First', uri: 'old-first')],
        );
        final scanned = _book(
          id: 'book-1',
          chapters: [_chapter(name: 'New First', uri: 'new-first')],
        );

        await repo.save(existing);
        await repo.mergeScanResults([scanned]);

        final stored = (await repo.getById('book-1'))!;
        expect(stored.isMetadataScanned, isFalse);
      },
    );

    test(
      'mergeScanResults keeps metadata scan result when first chapter changes but metadata exists',
      () async {
        final existing = _book(
          id: 'book-1',
          author: 'Existing Author',
          isMetadataScanned: true,
          chapters: [_chapter(name: 'Old First', uri: 'old-first')],
        );
        final scanned = _book(
          id: 'book-1',
          chapters: [_chapter(name: 'New First', uri: 'new-first')],
        );

        await repo.save(existing);
        await repo.mergeScanResults([scanned]);

        final stored = (await repo.getById('book-1'))!;
        expect(stored.author, 'Existing Author');
        expect(stored.isMetadataScanned, isTrue);
      },
    );

    test(
      'mergeScanResults deletes books missing from the latest scan',
      () async {
        await repo.save(_book(id: 'kept-book'));
        await repo.save(_book(id: 'removed-book'));

        await repo.mergeScanResults([_book(id: 'kept-book')]);

        expect(await repo.getById('kept-book'), isNotNull);
        expect(await repo.getById('removed-book'), isNull);
        expect(await repo.getAll(), hasLength(1));
      },
    );

    test('clearAll removes persisted library', () async {
      await repo.save(_book(id: 'book-1'));
      await repo.save(_book(id: 'book-2'));

      await repo.clearAll();

      expect(await repo.getAll(), isEmpty);
    });
  });
}

Audiobook _book({
  required String id,
  String title = 'Book',
  String folderUri = 'folder-uri',
  String? author,
  String? coverPath,
  int? totalDurationMs,
  int currentChapterIndex = 0,
  int currentPositionMs = 0,
  bool isRead = false,
  bool isMetadataScanned = false,
  List<Chapter> chapters = const [],
}) {
  return Audiobook(
    id: id,
    title: title,
    folderUri: folderUri,
    chapters: chapters,
    author: author,
    coverPath: coverPath,
    totalDurationMs: totalDurationMs,
    currentChapterIndex: currentChapterIndex,
    currentPositionMs: currentPositionMs,
    isRead: isRead,
    isMetadataScanned: isMetadataScanned,
  );
}

Chapter _chapter({
  required String name,
  required String uri,
  String? mime,
  int? durationMs,
}) {
  return Chapter(name: name, uri: uri, mime: mime, durationMs: durationMs);
}
