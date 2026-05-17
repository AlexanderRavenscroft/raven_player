import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/metadata_service.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookEnricher {
  final AudiobookRepository _repo;
  final MetadataService _metadata;

  AudiobookEnricher(this._repo, this._metadata);

  /// Enrich a list of books. Each book uses its first chapter's URI as source.
  /// Pass [force] = true to re-enrich books that already have metadata (rescan).
  Future<void> enrichAll(List<Audiobook> books, {bool force = false}) async {
    final coversDir = await _coversDirectory();

    for (final book in books) {
      if (!force && _isEnriched(book)) continue;
      if (book.chapters.isEmpty) continue;

      final firstUri = book.chapters.first.uri;
      final meta = await _metadata.getMetadata(firstUri);
      if (meta == null) continue;

      final coverPath = await _saveCover(
        coversDir,
        bookId: book.id,
        bytes: meta.coverBytes,
        existing: book.coverPath,
        force: force,
      );

      final enriched = book.copyWith(
        // Prefer metadata title/author only if the user hasn't renamed the book.
        // Title: only fill from meta if still the raw folder name (heuristic: no
        // explicit rename means title == folder name from SAF scan).
        // Simplest safe approach: only set if currently null/empty.
        author: meta.artist,
        totalDurationMs: _sumDurations(book, meta.durationMs),
        coverPath: coverPath,
      );

      await _repo.save(enriched);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  bool _isEnriched(Audiobook book) =>
      book.author != null && book.coverPath != null;

  /// Sum chapter durations — we only have the first file's duration from meta,
  /// so store it as a starting point; full sum can be done during playback scan.
  int? _sumDurations(Audiobook book, int? firstDurationMs) => firstDurationMs;

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
    required bool force,
  }) async {
    if (bytes == null) return existing; // keep whatever was there
    if (existing != null && !force) return existing; // already saved

    // Use a stable filename derived from the book id (which is the folder URI).
    final safeId = Uri.encodeComponent(bookId);
    final file = File('${dir.path}/$safeId.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

final metadataServiceProvider = Provider<MetadataService>(
  (_) => MetadataService(),
);

final audiobookEnricherProvider = Provider<AudiobookEnricher>((ref) {
  return AudiobookEnricher(
    ref.read(audiobookRepositoryProvider),
    ref.read(metadataServiceProvider),
  );
});
