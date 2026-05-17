import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings {
  @HiveField(0)
  final String? homeFolderUri;

  @HiveField(1)
  final ThemeMode themeMode;

  const UserSettings({this.homeFolderUri, this.themeMode = ThemeMode.system});

  UserSettings copyWith({String? homeFolderUri, ThemeMode? themeMode}) {
    return UserSettings(
      homeFolderUri: homeFolderUri ?? this.homeFolderUri,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
