import 'package:flutter/services.dart';
import 'package:raven_player/utils/app_logger.dart';

class SafAudioMetadata {
  final String? title;
  final String? artist;
  final int? durationMs;
  final Uint8List? coverBytes;

  const SafAudioMetadata({
    this.title,
    this.artist,
    this.durationMs,
    this.coverBytes,
  });
}

class SafMetadataService {
  static const _channel = MethodChannel('raven/saf');

  Future<int?> getDurationMs(String uri) async {
    try {
      final result = await _channel.invokeMethod<int>('getDuration', {
        'uri': uri,
      });
      return result;
    } on PlatformException catch (e) {
      log.e('MetadataService duration error: ${e.message}');
      return null;
    }
  }

  Future<SafAudioMetadata?> getMetadata(String uri) async {
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'getMetadata',
        {'uri': uri},
      );
      if (result == null) return null;

      return SafAudioMetadata(
        title: result['title'] as String?,
        artist: result['artist'] as String?,
        durationMs: (result['duration'] as num?)?.toInt(),
        coverBytes: result['cover'] as Uint8List?,
      );
    } on PlatformException catch (e) {
      log.e('MetadataService error: ${e.message}');
      return null;
    }
  }
}
