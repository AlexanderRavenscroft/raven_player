import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
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
    final coversDir = await _coversDirectory();

    for (final book in books) {
      if (!book.needsMetadataScan) {
        continue;
      }

      if (book.chapters.isEmpty) {
        await _repo.updateById(
          book.id,
          (current) => current.copyWith(isMetadataScanned: true),
        );
        continue;
      }

      final firstUri = book.chapters.first.uri;
      final SafAudioMetadata meta;

      try {
        meta = await _metadata.getMetadata(firstUri);
      } on PlatformException catch (error) {
        log.e('Metadata scan failed: ${error.code}.');
        continue;
      } on MissingPluginException {
        log.e('Metadata scan failed: native SAF plugin is unavailable.');
        continue;
      }

      final coverPath = await _saveCover(
        coversDir,
        bookId: book.id,
        bytes: meta.coverBytes,
        existing: book.coverPath,
      );

      await _repo.updateById(
        book.id,
        (current) => current.copyWith(
          author: current.author ?? meta.artist,
          coverPath: current.coverPath ?? coverPath,
          isMetadataScanned: true,
        ),
      );
    }
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
