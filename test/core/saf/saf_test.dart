import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf.dart';

void main() {
  group('SafEntry.fromMap', () {
    test('maps native file entry payload', () {
      final entry = SafEntry.fromMap({
        'uri': 'content://chapter-1',
        'name': 'Chapter 1.mp3',
        'isDir': false,
        'mime': 'audio/mpeg',
      });

      expect(entry.uri, 'content://chapter-1');
      expect(entry.name, 'Chapter 1.mp3');
      expect(entry.isDir, isFalse);
      expect(entry.mime, 'audio/mpeg');
    });

    test('maps native directory entry payload', () {
      final entry = SafEntry.fromMap({
        'uri': 'content://book-folder',
        'name': 'Book Folder',
        'isDir': true,
        'mime': null,
      });

      expect(entry.uri, 'content://book-folder');
      expect(entry.name, 'Book Folder');
      expect(entry.isDir, isTrue);
      expect(entry.mime, isNull);
    });
  });

  group('SafAvailabilityResult.fromMap', () {
    test('maps available status', () {
      final result = SafAvailabilityResult.fromMap({
        'status': 'available',
        'uri': null,
      });

      expect(result.status, SafAvailabilityStatus.available);
      expect(result.isAvailable, isTrue);
      expect(result.uri, isNull);
    });

    test('maps missing status with failing uri', () {
      final result = SafAvailabilityResult.fromMap({
        'status': 'missing',
        'uri': 'content://missing',
      });

      expect(result.status, SafAvailabilityStatus.missing);
      expect(result.isAvailable, isFalse);
      expect(result.uri, 'content://missing');
    });

    test('treats unknown status as inaccessible', () {
      final result = SafAvailabilityResult.fromMap({
        'status': 'unexpected',
        'uri': 'content://unknown',
      });

      expect(result.status, SafAvailabilityStatus.inaccessible);
      expect(result.isAvailable, isFalse);
      expect(result.uri, 'content://unknown');
    });
  });
}
