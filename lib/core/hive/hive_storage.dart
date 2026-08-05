import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raven_player/core/hive/adapters/theme_mode_adapter.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';
import 'package:raven_player/models/user_settings.dart';

abstract final class HiveStorage {
  static const _audiobooksBoxName = 'audiobooks';
  static const _userSettingsBoxName = 'userSettings';

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(AudiobookAdapter());
    Hive.registerAdapter(ChapterAdapter());
  }

  static Future<Box<Audiobook>> audiobooks() =>
      _openBox<Audiobook>(_audiobooksBoxName);

  static Future<Box<UserSettings>> userSettings() =>
      _openBox<UserSettings>(_userSettingsBoxName);

  static Future<Box<T>> _openBox<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return Hive.box<T>(name);
    }

    return Hive.openBox<T>(name);
  }
}
