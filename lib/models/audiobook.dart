class Audiobook {
  final String id; // stable id (folder uri)
  final String title; // folder name
  final String folderUri; // SAF tree/document uri
  final List<Chapter> chapters;

  const Audiobook({
    required this.id,
    required this.title,
    required this.folderUri,
    required this.chapters,
  });
}

class Chapter {
  final String name;
  final String uri;
  final String? mime;

  const Chapter({required this.name, required this.uri, this.mime});
}
