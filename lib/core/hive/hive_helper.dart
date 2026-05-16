import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/core/hive/adapters/theme_mode_adapter.dart';

class HiveHelper {
  //* INIT HIVE
  static Future<void> initHive() async {
    final dir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(dir.path);
    // Hive.registerAdapter(AudiobookAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(ThemeModeAdapter());
  }

  //* GET BOX

  static Future<Box<T>> getBox<T>(HiveBox box) async {
    if (Hive.isBoxOpen(box.name)) {
      return Hive.box<T>(box.name);
    }
    return Hive.openBox<T>(box.name);
  }

  //* REMOVE ITEM
  static Future<void> remove<T>(HiveBox box, dynamic key) async {
    final b = await getBox<T>(box);
    await b.delete(key);
  }
}
