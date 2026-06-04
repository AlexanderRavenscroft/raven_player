import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppVersion {
  static String version = '';
  static String buildNumber = '';

  static Future<void> setAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
