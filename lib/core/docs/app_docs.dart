import 'package:flutter/services.dart';
import 'package:raven_player/core/localization/app_languages.dart';

abstract final class AppDocs {
  static const String _docsFolder = 'assets/docs';

  static final Map<String, String> _textFileContents = {
    'en/legal.txt': '',
    'en/creator.txt': '',
    'pl/legal.txt': '',
    'pl/creator.txt': '',
  };

  static Future<void> loadTextFiles() async {
    await Future.wait(
      _textFileContents.keys.map((path) async {
        _textFileContents[path] = await rootBundle.loadString(
          '$_docsFolder/$path',
        );
      }),
    );
  }

  static String getText(TextFiles file, {required String languageCode}) {
    final safeLanguageCode = AppLanguages.sanitize(languageCode);

    final path = '$safeLanguageCode/${file.fileName}';
    final fallbackPath = '${AppLanguages.english}/${file.fileName}';

    return _textFileContents[path] ??
        _textFileContents[fallbackPath] ??
        'No file found!';
  }
}

enum TextFiles { legal, creator }

extension TextFilesExtension on TextFiles {
  String get fileName => switch (this) {
    TextFiles.creator => 'creator.txt',
    TextFiles.legal => 'legal.txt',
  };
}
