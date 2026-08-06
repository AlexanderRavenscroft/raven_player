import 'package:flutter/services.dart';

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
    return _channel.invokeMethod<int>('getDuration', {'uri': uri});
  }

  Future<SafAudioMetadata> getMetadata(String uri) async {
    final result = await _channel.invokeMapMethod<String, Object?>(
      'getMetadata',
      {'uri': uri},
    );

    if (result == null) {
      throw PlatformException(
        code: 'INVALID_METADATA_RESULT',
        message: 'Native metadata response was null.',
      );
    }

    return SafAudioMetadata(
      title: result['title'] as String?,
      artist: result['artist'] as String?,
      durationMs: (result['duration'] as num?)?.toInt(),
      coverBytes: result['cover'] as Uint8List?,
    );
  }
}
