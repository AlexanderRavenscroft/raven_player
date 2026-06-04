String prettifyTreeUri(String uri) {
  try {
    // Example input:
    // content://com.android.externalstorage.documents/tree/primary%3AAudiobooks%2FMyBooks
    final decoded = Uri.decodeFull(uri);
    // → content://.../tree/primary:Audiobooks/MyBooks

    final treeIndex = decoded.indexOf('/tree/');
    if (treeIndex == -1) return decoded;

    var path = decoded.substring(treeIndex + '/tree/'.length);

    // "primary:Audiobooks/MyBooks" → "Audiobooks/MyBooks"
    final colon = path.indexOf(':');
    if (colon != -1) path = path.substring(colon + 1);

    return path.isEmpty ? 'Internal storage' : path;
  } catch (_) {
    return uri;
  }
}
