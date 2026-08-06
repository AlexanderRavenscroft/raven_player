import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf_metadata_service.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory appDocumentsDir;

  setUp(() {
    appDocumentsDir = Directory.systemTemp.createTempSync(
      'raven_player_enricher_test_',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return appDocumentsDir.path;
          }

          throw PlatformException(
            code: 'UNEXPECTED_METHOD',
            message: call.method,
          );
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);

    if (await appDocumentsDir.exists()) {
      await appDocumentsDir.delete(recursive: true);
    }
  });

  group('AudiobookEnricher.enrichAll', () {
    test('marks book as scanned when it has no chapters', () async {
      final repo = FakeAudiobookRepository();
      final metadata = FakeSafMetadataService();
      final enricher = AudiobookEnricher(repo, metadata);

      const book = Audiobook(
        id: 'book-1',
        title: 'Book',
        folderUri: 'folder-uri',
        chapters: [],
      );

      await enricher.enrichAll([book]);

      expect(metadata.requestedUris, isEmpty);
      expect(repo.saved, hasLength(1));
      expect(repo.saved.single.isMetadataScanned, isTrue);
    });

    test('leaves failed metadata retryable and continues with later books', () async {
      final repo = FakeAudiobookRepository();
      final metadata = FakeSafMetadataService(
        failingUris: {'failed-chapter'},
        responses: {
          'good-chapter': const SafAudioMetadata(artist: 'Author Name'),
        },
      );
      final enricher = AudiobookEnricher(repo, metadata);

      const failedBook = Audiobook(
        id: 'failed-book',
        title: 'Failed Book',
        folderUri: 'failed-folder',
        chapters: [Chapter(name: 'Chapter 1', uri: 'failed-chapter')],
      );
      const goodBook = Audiobook(
        id: 'good-book',
        title: 'Good Book',
        folderUri: 'good-folder',
        chapters: [Chapter(name: 'Chapter 1', uri: 'good-chapter')],
      );

      await enricher.enrichAll([failedBook, goodBook]);

      expect(metadata.requestedUris, ['failed-chapter', 'good-chapter']);
      expect(repo.saved, hasLength(1));
      expect(repo.saved.single.id, 'good-book');
      expect(repo.saved.single.author, 'Author Name');
      expect(repo.saved.single.isMetadataScanned, isTrue);
      expect(failedBook.needsMetadataScan, isTrue);
    });

    test(
      'saves author and embedded cover without leaking book id into filename',
      () async {
        final repo = FakeAudiobookRepository();
        final coverBytes = Uint8List.fromList([1, 2, 3, 4]);
        final metadata = FakeSafMetadataService(
          responses: {
            'chapter-uri': SafAudioMetadata(
              artist: 'Author Name',
              coverBytes: coverBytes,
            ),
          },
        );
        final enricher = AudiobookEnricher(repo, metadata);

        const sensitiveBookId =
            'content://provider/tree/primary%3AAudiobooks%2FPrivateBook';
        const book = Audiobook(
          id: sensitiveBookId,
          title: 'Book',
          folderUri: sensitiveBookId,
          chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
        );

        await enricher.enrichAll([book]);

        expect(repo.saved, hasLength(1));
        final saved = repo.saved.single;
        expect(saved.author, 'Author Name');
        expect(saved.coverPath, isNotNull);
        expect(saved.isMetadataScanned, isTrue);

        final coverPath = saved.coverPath!;
        expect(coverPath.contains('PrivateBook'), isFalse);
        expect(coverPath.endsWith('.jpg'), isTrue);
        expect(await File(coverPath).readAsBytes(), equals(coverBytes));
      },
    );

    test(
      'does not request metadata or save books that do not need scanning',
      () async {
        final repo = FakeAudiobookRepository();
        final metadata = FakeSafMetadataService();
        final enricher = AudiobookEnricher(repo, metadata);

        const book = Audiobook(
          id: 'book-1',
          title: 'Book',
          folderUri: 'folder-uri',
          chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
          isMetadataScanned: true,
        );

        await enricher.enrichAll([book]);

        expect(metadata.requestedUris, isEmpty);
        expect(repo.saved, isEmpty);
      },
    );
  });
}

class FakeAudiobookRepository extends AudiobookRepository {
  final List<Audiobook> saved = [];

  @override
  Future<void> save(Audiobook book) async {
    saved.add(book);
  }
}

class FakeSafMetadataService extends SafMetadataService {
  final Map<String, SafAudioMetadata> responses;
  final Set<String> failingUris;
  final List<String> requestedUris = [];

  FakeSafMetadataService({
    this.responses = const {},
    this.failingUris = const {},
  });

  @override
  Future<SafAudioMetadata> getMetadata(String uri) async {
    requestedUris.add(uri);
    if (failingUris.contains(uri)) {
      throw PlatformException(
        code: 'METADATA_ERROR',
        message: 'Cannot read $uri',
      );
    }
    return responses[uri] ?? const SafAudioMetadata();
  }
}
