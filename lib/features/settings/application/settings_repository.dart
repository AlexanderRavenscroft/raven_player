import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';

class UserSettingsRepository {
  static const String _settingsKey = 'settings';

  Future<UserSettings> load() async {
    final box = await HiveBoxes.userSettings();
    final settings = box.get(_settingsKey);

    if (settings == null) {
      const defaultSettings = UserSettings();
      await box.put(_settingsKey, defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  Future<void> save(UserSettings settings) async {
    final box = await HiveBoxes.userSettings();
    await box.put(_settingsKey, settings);
  }
}

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>(
  (ref) => UserSettingsRepository(),
);
