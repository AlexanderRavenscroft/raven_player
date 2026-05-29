import 'package:flutter/services.dart';
import 'package:raven_player/core/localization/app_languages.dart';

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

  static String getText(TextFiles file, {required String languageCode}) {
    final safeLanguageCode = AppLanguages.sanitize(languageCode);

    final path = '$safeLanguageCode/${file.fileName}';
    final fallbackPath = '${AppLanguages.english}/${file.fileName}';

    return txtFilesPaths[path] ??
        txtFilesPaths[fallbackPath] ??
        'No file found!';
  }
}

enum TextFiles { legal, creator }

extension TxtFilesExtension on TextFiles {
  String get fileName => switch (this) {
    TextFiles.creator => 'creator.txt',
    TextFiles.legal => 'legal.txt',
  };
}
