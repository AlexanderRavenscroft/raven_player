import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings {
  @HiveField(0)
  final String? homeFolderUri;

  @HiveField(1)
  final ThemeMode themeMode;

  @HiveField(2)
  final bool isCoverPlayEnabled;

  @HiveField(3)
  final bool isPauseLockEnabled;

  @HiveField(4)
  final bool showRemainingTime;

  @HiveField(5)
  final bool showBufferedProgress;

  @HiveField(6)
  final bool isPlayerLockEnabled;

  @HiveField(7)
  final bool isPlaybackSpeedEnabled;

  @HiveField(8)
  final double playbackSpeed;

  const UserSettings({
    this.homeFolderUri,
    this.themeMode = ThemeMode.system,
    this.isCoverPlayEnabled = true,
    this.isPauseLockEnabled = false,
    this.showRemainingTime = false,
    this.showBufferedProgress = false,
    this.isPlayerLockEnabled = false,
    this.isPlaybackSpeedEnabled = false,
    this.playbackSpeed = 1.0,
  });

  UserSettings copyWith({
    String? homeFolderUri,
    ThemeMode? themeMode,
    bool? isCoverPlayEnabled,
    bool? isPauseLockEnabled,
    bool? showRemainingTime,
    bool? showBufferedProgress,
    bool? isPlayerLockEnabled,
    bool? isPlaybackSpeedEnabled,
    double? playbackSpeed,
  }) {
    return UserSettings(
      homeFolderUri: homeFolderUri ?? this.homeFolderUri,
      themeMode: themeMode ?? this.themeMode,
      isCoverPlayEnabled: isCoverPlayEnabled ?? this.isCoverPlayEnabled,
      isPauseLockEnabled: isPauseLockEnabled ?? this.isPauseLockEnabled,
      showRemainingTime: showRemainingTime ?? this.showRemainingTime,
      showBufferedProgress: showBufferedProgress ?? this.showBufferedProgress,
      isPlayerLockEnabled: isPlayerLockEnabled ?? this.isPlayerLockEnabled,
      isPlaybackSpeedEnabled:
          isPlaybackSpeedEnabled ?? this.isPlaybackSpeedEnabled,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}
