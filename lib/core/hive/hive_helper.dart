import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/core/hive/adapters/theme_mode_adapter.dart';

class HiveHelper {
  static Future<void> initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
    Hive.registerAdapter(AudiobookAdapter());
    Hive.registerAdapter(ChapterAdapter());
  }

  static Future<Box<T>> getBox<T>(HiveBox box) async {
    if (Hive.isBoxOpen(box.name)) {
      return Hive.box<T>(box.name);
    }
    return Hive.openBox<T>(box.name);
  }
}
