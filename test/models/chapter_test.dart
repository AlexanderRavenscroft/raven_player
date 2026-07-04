import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/models/chapter.dart';

void main() {
  group('Chapter duration helper', () {
    test('duration returns null when durationMs is null', () {
      const chapter = Chapter(name: 'Chapter 1', uri: 'chapter-uri');

      expect(chapter.duration, isNull);
    });

    test('duration converts milliseconds to Duration', () {
      const chapter = Chapter(
        name: 'Chapter 1',
        uri: 'chapter-uri',
        durationMs: 61000,
      );

      expect(chapter.duration, const Duration(seconds: 61));
    });
  });

  group('Chapter.copyWith', () {
    test('changes selected fields and preserves the rest', () {
      const chapter = Chapter(
        name: 'Old Name',
        uri: 'chapter-uri',
        mime: 'audio/mpeg',
        durationMs: 1000,
      );

      final updated = chapter.copyWith(name: 'New Name', durationMs: 2000);

      expect(updated.name, 'New Name');
      expect(updated.uri, 'chapter-uri');
      expect(updated.mime, 'audio/mpeg');
      expect(updated.durationMs, 2000);
    });
  });
}
