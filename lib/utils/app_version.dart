import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String version = '';
  static String buildNumber = '';

  static Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
}
