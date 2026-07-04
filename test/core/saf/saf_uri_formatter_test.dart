import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf_uri_formatter.dart';

void main() {
  group('prettifyTreeUri', () {
    test('formats primary storage subfolder tree uri', () {
      const uri =
          'content://com.android.externalstorage.documents/tree/primary%3AAudiobooks%2FFantasy';

      expect(prettifyTreeUri(uri), 'Audiobooks/Fantasy');
    });

    test('formats primary storage root as internal storage', () {
      const uri =
          'content://com.android.externalstorage.documents/tree/primary%3A';

      expect(prettifyTreeUri(uri), 'Internal storage');
    });

    test('decodes uri without tree marker and returns decoded value', () {
      const uri = 'content://provider/document/Audiobooks%2FBook';

      expect(
        prettifyTreeUri(uri),
        'content://provider/document/Audiobooks/Book',
      );
    });

    test('returns original uri when decoding fails', () {
      const uri = '%';

      expect(prettifyTreeUri(uri), uri);
    });
  });
}
