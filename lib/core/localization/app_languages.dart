abstract final class AppLanguages {
  static const english = 'en';
  static const polish = 'pl';

  static const supportedCodes = {english, polish};

  static String sanitize(String code) {
    return supportedCodes.contains(code) ? code : english;
  }
}
