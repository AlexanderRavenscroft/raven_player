bool isSafDocumentInTree({
  required String documentUri,
  required String treeUri,
}) {
  final document = Uri.tryParse(documentUri);
  final tree = Uri.tryParse(treeUri);

  if (document == null ||
      tree == null ||
      document.scheme != 'content' ||
      tree.scheme != 'content' ||
      document.authority != tree.authority) {
    return false;
  }

  final documentTreeId = _treeDocumentId(document);
  final expectedTreeId = _treeDocumentId(tree);

  return expectedTreeId != null && documentTreeId == expectedTreeId;
}

String? _treeDocumentId(Uri uri) {
  final segments = uri.pathSegments;
  final treeIndex = segments.indexOf('tree');
  if (treeIndex == -1 || treeIndex + 1 >= segments.length) return null;

  final treeId = segments[treeIndex + 1];
  return treeId.isEmpty ? null : treeId;
}
