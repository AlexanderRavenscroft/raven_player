import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/models/user_settings.dart';

class UserSettingsRepository {
  static const String _settingsKey = 'user_settings';

  Future<UserSettings?> load() async {
    final box = await HiveBoxes.userSettings();
    return box.get(_settingsKey);
  }

  Future<void> save(UserSettings settings) async {
    final box = await HiveBoxes.userSettings();
    await box.put(_settingsKey, settings);
  }
}

final userSettingsRepositoryProvider = Provider<UserSettingsRepository>(
  (ref) => UserSettingsRepository(),
);
