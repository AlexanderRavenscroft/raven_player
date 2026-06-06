import 'package:flutter/services.dart';

class SafEntry {
  final String uri;
  final String? name;
  final bool isDir;
  final String? mime;

  const SafEntry({
    required this.uri,
    this.name,
    required this.isDir,
    this.mime,
  });

  factory SafEntry.fromMap(Map<Object?, Object?> map) {
    return SafEntry(
      uri: map['uri'] as String,
      name: map['name'] as String?,
      isDir: map['isDir'] as bool,
      mime: map['mime'] as String?,
    );
  }
}

abstract final class Saf {
  static const _channel = MethodChannel('raven/saf');

  static Future<String?> pickTree() => _channel.invokeMethod<String>('pickTree');

  static Future<List<SafEntry>> listDir(String uri) async {
    final result = await _channel.invokeMethod<List<Object?>>(
      'listDir',
      {'uri': uri},
    );

    return (result ?? [])
        .map((entry) => SafEntry.fromMap(entry as Map<Object?, Object?>))
        .toList();
  }
}
