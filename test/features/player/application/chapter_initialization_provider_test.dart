import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf_metadata_service.dart';
import 'package:raven_player/features/library/application/audiobook_enricher.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/player/application/chapter_initialization_provider.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';

void main() {
  test('does not save zero durations when native extraction fails', () async {
    const book = Audiobook(
      id: 'book-1',
      title: 'Book',
      folderUri: 'folder-uri',
      chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
    );
    final repo = FakeAudiobookRepository(book);
    final metadata = FakeSafMetadataService(failingUris: {'chapter-uri'});
    final container = _container(repo, metadata);
    addTearDown(container.dispose);

    final result = await container.read(
      chapterInitializationProvider(book.id).future,
    );

    expect(result.chapters.single.durationMs, isNull);
    expect(result.totalDurationMs, isNull);
    expect(repo.saved.single.chapters.single.durationMs, isNull);
  });

  test('keeps an unavailable duration unresolved instead of storing zero', () async {
    const book = Audiobook(
      id: 'book-1',
      title: 'Book',
      folderUri: 'folder-uri',
      chapters: [Chapter(name: 'Chapter 1', uri: 'chapter-uri')],
    );
    final repo = FakeAudiobookRepository(book);
    final metadata = FakeSafMetadataService(
      responses: const {'chapter-uri': null},
    );
    final container = _container(repo, metadata);
    addTearDown(container.dispose);

    final result = await container.read(
      chapterInitializationProvider(book.id).future,
    );

    expect(result.chapters.single.durationMs, isNull);
    expect(result.totalDurationMs, isNull);
    expect(repo.saved.single.chapters.single.durationMs, isNull);
  });

  test('calculates the total only after every duration is resolved', () async {
    const book = Audiobook(
      id: 'book-1',
      title: 'Book',
      folderUri: 'folder-uri',
      chapters: [
        Chapter(name: 'Chapter 1', uri: 'chapter-1', durationMs: 1000),
        Chapter(name: 'Chapter 2', uri: 'chapter-2'),
      ],
    );
    final repo = FakeAudiobookRepository(book);
    final metadata = FakeSafMetadataService(
      responses: const {'chapter-2': 2000},
    );
    final container = _container(repo, metadata);
    addTearDown(container.dispose);

    final result = await container.read(
      chapterInitializationProvider(book.id).future,
    );

    expect(result.chapters.map((chapter) => chapter.durationMs), [1000, 2000]);
    expect(result.totalDurationMs, 3000);
    expect(repo.saved.single.totalDurationMs, 3000);
  });
}

ProviderContainer _container(
  AudiobookRepository repo,
  SafMetadataService metadata,
) {
  return ProviderContainer(
    overrides: [
      audiobookRepositoryProvider.overrideWithValue(repo),
      metadataServiceProvider.overrideWithValue(metadata),
    ],
  );
}

class FakeAudiobookRepository extends AudiobookRepository {
  final Audiobook book;
  final List<Audiobook> saved = [];

  FakeAudiobookRepository(this.book);

  @override
  Future<Audiobook?> getById(String id) async => id == book.id ? book : null;

  @override
  Future<void> save(Audiobook book) async {
    saved.add(book);
  }
}

class FakeSafMetadataService extends SafMetadataService {
  final Map<String, int?> responses;
  final Set<String> failingUris;

  FakeSafMetadataService({
    this.responses = const {},
    this.failingUris = const {},
  });

  @override
  Future<int?> getDurationMs(String uri) async {
    if (failingUris.contains(uri)) {
      throw PlatformException(
        code: 'DURATION_ERROR',
        message: 'Cannot read $uri',
      );
    }
    return responses[uri];
  }
}
