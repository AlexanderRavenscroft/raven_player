import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/localization/app_languages.dart';

void main() {
  group('AppLanguages.sanitize', () {
    test('keeps English language code', () {
      expect(AppLanguages.sanitize('en'), AppLanguages.english);
    });

    test('keeps Polish language code', () {
      expect(AppLanguages.sanitize('pl'), AppLanguages.polish);
    });

    test('falls back to English for unsupported language code', () {
      expect(AppLanguages.sanitize('de'), AppLanguages.english);
    });

    test('falls back to English for empty language code', () {
      expect(AppLanguages.sanitize(''), AppLanguages.english);
    });
  });
}
