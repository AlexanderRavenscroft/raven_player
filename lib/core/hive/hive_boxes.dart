import 'package:hive_ce/hive.dart';
import 'package:raven_player/core/hive/hive_helper.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/user_settings.dart';

enum HiveBox { audiobooks, userSettings }

class HiveBoxes {
  static Future<Box<Audiobook>> audiobooks() =>
      HiveHelper.getBox<Audiobook>(HiveBox.audiobooks);
  static Future<Box<UserSettings>> userSettings() =>
      HiveHelper.getBox<UserSettings>(HiveBox.userSettings);
}

extension HiveBoxExtension on HiveBox {
  String get boxName => switch (this) {
    HiveBox.audiobooks => 'audiobooks',
    HiveBox.userSettings => 'userSettings',
  };
}
