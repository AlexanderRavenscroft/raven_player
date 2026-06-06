import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/core/saf/saf_metadata_service.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/utils/app_logger.dart';

class AudiobookEnricher {
  final AudiobookRepository _repo;
  final SafMetadataService _metadata;

  AudiobookEnricher(this._repo, this._metadata);

  /// Enrich a list of books. Each book uses its first chapter's URI as source.
  Future<void> enrichAll(List<Audiobook> books) async {
    final watch = Stopwatch()..start();
    final coversDir = await _coversDirectory();
    var skippedAlreadyEnriched = 0;
    var skippedEmpty = 0;
    var missingMetadata = 0;
    var savedCovers = 0;
    var updatedBooks = 0;

    for (final book in books) {
      if (!book.needsMetadataScan) {
        skippedAlreadyEnriched++;
        continue;
      }
      if (book.chapters.isEmpty) {
        skippedEmpty++;
        await _repo.save(book.copyWith(isMetadataScanned: true));
        updatedBooks++;
        continue;
      }

      final firstUri = book.chapters.first.uri;
      final meta = await _metadata.getMetadata(firstUri);
      if (meta == null) {
        missingMetadata++;
        await _repo.save(book.copyWith(isMetadataScanned: true));
        updatedBooks++;
        continue;
      }

      final hadCover = book.coverPath != null;
      final coverPath = await _saveCover(
        coversDir,
        bookId: book.id,
        bytes: meta.coverBytes,
        existing: book.coverPath,
      );
      if (!hadCover && coverPath != null) {
        savedCovers++;
      }

      final enriched = book.copyWith(
        author: meta.artist,
        coverPath: coverPath,
        isMetadataScanned: true,
      );

      await _repo.save(enriched);
      updatedBooks++;
    }

    watch.stop();
    log.d(
      '[LibraryEnrich] Checked ${books.length} books, updated $updatedBooks, '
      'saved $savedCovers covers, $missingMetadata missing metadata, '
      '$skippedAlreadyEnriched already enriched, $skippedEmpty empty '
      'in ${watch.elapsedMilliseconds}ms',
    );
  }

  Future<Directory> _coversDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/covers');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<String?> _saveCover(
    Directory dir, {
    required String bookId,
    required Uint8List? bytes,
    required String? existing,
  }) async {
    if (bytes == null) return existing;
    if (existing != null) return existing;

    // Use the stable book id to avoid leaking folder names into cover filenames.
    final hash = md5.convert(utf8.encode(bookId)).toString();
    final file = File('${dir.path}/$hash.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

final metadataServiceProvider = Provider<SafMetadataService>(
  (_) => SafMetadataService(),
);

final audiobookEnricherProvider = Provider<AudiobookEnricher>((ref) {
  return AudiobookEnricher(
    ref.read(audiobookRepositoryProvider),
    ref.read(metadataServiceProvider),
  );
});
