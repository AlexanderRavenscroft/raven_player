import 'package:flutter/services.dart';

class AppDocs {
  static const String docsFolder = 'assets/docs';
  static final Map<String, String> txtFilesPaths = {
    'en/legal.txt': '',
    'en/creator.txt': '',
    'pl/legal.txt': '',
    'pl/creator.txt': '',
  };

  static Future<void> loadTextFiles() async {
    await Future.wait(
      txtFilesPaths.keys.map((path) async {
        txtFilesPaths[path] = await rootBundle.loadString('$docsFolder/$path');
      }),
    );
  }

  static String getText(TextFiles file, {String language = 'en'}) {
    final path = '$language/${file.fileName}';
    return txtFilesPaths[path] ?? 'No file found!';
  }
}

enum TextFiles { legal, creator }

extension TxtFilesExtension on TextFiles {
  String get fileName => switch (this) {
    TextFiles.creator => 'creator.txt',
    TextFiles.legal => 'legal.txt',
  };
}
