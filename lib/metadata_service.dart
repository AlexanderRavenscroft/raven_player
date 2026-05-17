import 'package:flutter/services.dart';
import 'package:raven_player/utils/app_loger.dart';

class AudioMetadata {
  final String? title;
  final String? artist;
  final int? durationMs;
  final Uint8List? coverBytes;

  const AudioMetadata({
    this.title,
    this.artist,
    this.durationMs,
    this.coverBytes,
  });
}

class MetadataService {
  static const _channel = MethodChannel('raven/saf');

  Future<AudioMetadata?> getMetadata(String uri) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'getMetadata',
        {'uri': uri},
      );
      if (result == null) return null;

      return AudioMetadata(
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
