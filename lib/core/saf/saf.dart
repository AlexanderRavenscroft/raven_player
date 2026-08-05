import 'package:flutter/services.dart';

enum SafAvailabilityStatus { available, missing, inaccessible }

class SafAvailabilityResult {
  final SafAvailabilityStatus status;
  final String? uri;

  const SafAvailabilityResult({required this.status, this.uri});

  bool get isAvailable => status == SafAvailabilityStatus.available;

  factory SafAvailabilityResult.fromMap(Map<Object?, Object?> map) {
    final status = switch (map['status'] as String?) {
      'available' => SafAvailabilityStatus.available,
      'missing' => SafAvailabilityStatus.missing,
      'inaccessible' => SafAvailabilityStatus.inaccessible,
      _ => SafAvailabilityStatus.inaccessible,
    };

    return SafAvailabilityResult(status: status, uri: map['uri'] as String?);
  }
}

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

  static Future<String?> pickTree() =>
      _channel.invokeMethod<String>('pickTree');

  static Future<List<SafEntry>> listDir(String uri) async {
    final result = await _channel.invokeMethod<List<Object?>>('listDir', {
      'uri': uri,
    });

    return (result ?? [])
        .map((entry) => SafEntry.fromMap(entry as Map<Object?, Object?>))
        .toList();
  }

  static Future<SafAvailabilityResult> checkAvailability(String uri) async {
    final result = await _channel.invokeMapMethod<Object?, Object?>(
      'checkAvailability',
      {'uri': uri},
    );

    if (result == null) {
      return const SafAvailabilityResult(
        status: SafAvailabilityStatus.inaccessible,
      );
    }

    return SafAvailabilityResult.fromMap(result);
  }
}
