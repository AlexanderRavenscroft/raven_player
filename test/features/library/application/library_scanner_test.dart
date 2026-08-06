import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/features/library/application/library_scanner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const safChannel = MethodChannel('raven/saf');
  late Map<String, List<Map<String, Object?>>> dirs;
  late Set<String> failingUris;

  setUp(() {
    dirs = {};
    failingUris = {};

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safChannel, (call) async {
          if (call.method != 'listDir') {
            throw PlatformException(
              code: 'UNEXPECTED_METHOD',
              message: call.method,
            );
          }

          final args = call.arguments as Map<Object?, Object?>;
          final uri = args['uri'] as String;
          if (failingUris.contains(uri)) {
            throw PlatformException(
              code: 'LIST_DIR_ERROR',
              message: 'Cannot list $uri',
            );
          }

          return dirs[uri] ?? <Map<String, Object?>>[];
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safChannel, null);
  });

  group('LibraryScanner.scan', () {
    test(
      'creates one audiobook per subfolder and sorts audio files by name',
      () async {
        dirs = {
          'home': [
            _entry(
              uri: 'top-level-track',
              name: 'ignored.mp3',
              mime: 'audio/mpeg',
            ),
            _entry(uri: 'book-1', name: 'Book One', isDir: true),
            _entry(uri: 'empty-folder', name: 'Empty Folder', isDir: true),
          ],
          'book-1': [
            _entry(uri: 'chapter-2', name: '02 Middle.MP3', mime: null),
            _entry(uri: 'cover', name: 'cover.jpg', mime: 'image/jpeg'),
            _entry(uri: 'chapter-1', name: '01 Intro.m4b', mime: null),
            _entry(uri: 'chapter-3', name: '03 End.bin', mime: 'audio/flac'),
          ],
          'empty-folder': [
            _entry(uri: 'notes', name: 'notes.txt', mime: 'text/plain'),
          ],
        };

        final books = await LibraryScanner().scan('home');

        expect(books, hasLength(1));
        expect(books.single.id, 'book-1');
        expect(books.single.title, 'Book One');
        expect(books.single.folderUri, 'book-1');
        expect(books.single.chapters.map((chapter) => chapter.name), [
          '01 Intro.m4b',
          '02 Middle.MP3',
          '03 End.bin',
        ]);
        expect(books.single.chapters.map((chapter) => chapter.uri), [
          'chapter-1',
          'chapter-2',
          'chapter-3',
        ]);
      },
    );

    test('uses fallback names for unnamed folders and files', () async {
      dirs = {
        'home': [_entry(uri: 'book-1', name: null, isDir: true)],
        'book-1': [_entry(uri: 'chapter-1', name: null, mime: 'audio/mpeg')],
      };

      final books = await LibraryScanner().scan('home');

      expect(books, hasLength(1));
      expect(books.single.title, '(unnamed)');
      expect(books.single.chapters.single.name, '(unnamed)');
    });

    test('fails the whole scan when a subfolder cannot be listed', () async {
      dirs = {
        'home': [
          _entry(uri: 'book-1', name: 'Book One', isDir: true),
          _entry(uri: 'broken-book', name: 'Broken Book', isDir: true),
        ],
        'book-1': [
          _entry(uri: 'chapter-1', name: '01.mp3', mime: 'audio/mpeg'),
        ],
      };
      failingUris = {'broken-book'};

      await expectLater(
        LibraryScanner().scan('home'),
        throwsA(
          isA<PlatformException>().having(
            (error) => error.code,
            'code',
            'LIST_DIR_ERROR',
          ),
        ),
      );
    });

    test(
      'returns empty list when home folder has no audiobook subfolders',
      () async {
        dirs = {
          'home': [
            _entry(uri: 'track', name: 'track.mp3', mime: 'audio/mpeg'),
            _entry(uri: 'image', name: 'cover.jpg', mime: 'image/jpeg'),
          ],
        };

        final books = await LibraryScanner().scan('home');

        expect(books, isEmpty);
      },
    );
  });
}

Map<String, Object?> _entry({
  required String uri,
  required String? name,
  bool isDir = false,
  String? mime,
}) {
  return {
    'uri': uri,
    'name': name,
    'isDir': isDir,
    'mime': isDir ? null : mime,
  };
}
