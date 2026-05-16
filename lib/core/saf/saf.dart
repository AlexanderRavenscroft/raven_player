import 'package:flutter/services.dart';

class SafEntry {
  final String uri;
  final String? name;
  final bool isDir;
  final String? mime;

  SafEntry({required this.uri, this.name, required this.isDir, this.mime});

  factory SafEntry.fromMap(Map m) => SafEntry(
    uri: m['uri'] as String,
    name: m['name'] as String?,
    isDir: m['isDir'] as bool,
    mime: m['mime'] as String?,
  );
}

class Saf {
  static const _ch = MethodChannel('raven/saf');

  static Future<String?> pickTree() async =>
      await _ch.invokeMethod<String>('pickTree');

  static Future<List<SafEntry>> listDir(String uri) async {
    final res = await _ch.invokeMethod<List<dynamic>>('listDir', {'uri': uri});
    return (res ?? []).map((e) => SafEntry.fromMap(e as Map)).toList();
  }
}
