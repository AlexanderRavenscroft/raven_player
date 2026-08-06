import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/saf/saf_uri_utils.dart';

void main() {
  const authority = 'com.android.externalstorage.documents';

  group('isSafDocumentInTree', () {
    test('accepts a document created from the same SAF tree', () {
      const treeUri =
          'content://$authority/tree/primary%3AAudiobooks';
      const documentUri =
          'content://$authority/tree/primary%3AAudiobooks/'
          'document/primary%3AAudiobooks%2FBook';

      expect(
        isSafDocumentInTree(documentUri: documentUri, treeUri: treeUri),
        isTrue,
      );
    });

    test('rejects tree ids that only share a textual prefix', () {
      const treeUri = 'content://$authority/tree/primary%3AAudio';
      const documentUri =
          'content://$authority/tree/primary%3AAudiobooks/'
          'document/primary%3AAudiobooks%2FBook';

      expect(
        isSafDocumentInTree(documentUri: documentUri, treeUri: treeUri),
        isFalse,
      );
    });

    test('rejects a matching tree id from another provider', () {
      const treeUri =
          'content://$authority/tree/primary%3AAudiobooks';
      const documentUri =
          'content://other.provider/tree/primary%3AAudiobooks/'
          'document/primary%3AAudiobooks%2FBook';

      expect(
        isSafDocumentInTree(documentUri: documentUri, treeUri: treeUri),
        isFalse,
      );
    });

    test('rejects URIs without a SAF tree id', () {
      expect(
        isSafDocumentInTree(
          documentUri: 'content://provider/document/book',
          treeUri: 'content://provider/folder',
        ),
        isFalse,
      );
    });
  });
}
