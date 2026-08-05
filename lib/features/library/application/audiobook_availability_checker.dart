import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/saf/saf.dart';
import 'package:raven_player/models/audiobook.dart';

class AudiobookUnavailableException implements Exception {
  final SafAvailabilityStatus status;
  final String? uri;

  const AudiobookUnavailableException({required this.status, this.uri});

  @override
  String toString() => 'AudiobookUnavailableException($status)';
}

class AudiobookAvailabilityChecker {
  Future<void> ensureAvailable(Audiobook book) async {
    if (book.chapters.isEmpty) {
      throw const AudiobookUnavailableException(
        status: SafAvailabilityStatus.missing,
      );
    }

    try {
      // Keep tap-to-open cheap: folder existence catches deleted/renamed books.
      final result = await Saf.checkAvailability(book.folderUri);

      if (!result.isAvailable) {
        throw AudiobookUnavailableException(
          status: result.status,
          uri: result.uri,
        );
      }
    } on PlatformException {
      throw const AudiobookUnavailableException(
        status: SafAvailabilityStatus.inaccessible,
      );
    } on MissingPluginException {
      throw const AudiobookUnavailableException(
        status: SafAvailabilityStatus.inaccessible,
      );
    }
  }
}

final audiobookAvailabilityCheckerProvider =
    Provider<AudiobookAvailabilityChecker>((ref) {
      return AudiobookAvailabilityChecker();
    });
