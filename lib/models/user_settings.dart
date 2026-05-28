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
  final bool showRemainingTime;

  @HiveField(3)
  final bool showBufferedProgress;

  @HiveField(4)
  final bool isPlaybackSpeedEnabled;

  @HiveField(5)
  final double playbackSpeed;

  @HiveField(6)
  final bool isSkipSilenceEnabled;

  @HiveField(7)
  final bool isPlayerLockEnabled;

  @HiveField(8)
  final bool backArrowBacksToLibrary;

  const UserSettings({
    this.homeFolderUri,
    this.themeMode = ThemeMode.system,
    this.showRemainingTime = false,
    this.showBufferedProgress = false,
    this.isPlayerLockEnabled = false,
    this.isPlaybackSpeedEnabled = false,
    this.isSkipSilenceEnabled = false,
    this.backArrowBacksToLibrary = false,
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
    bool? isSkipSilenceEnabled,
    bool? backArrowBacksToLibrary,
    double? playbackSpeed,
  }) {
    return UserSettings(
      homeFolderUri: homeFolderUri ?? this.homeFolderUri,
      themeMode: themeMode ?? this.themeMode,
      showRemainingTime: showRemainingTime ?? this.showRemainingTime,
      showBufferedProgress: showBufferedProgress ?? this.showBufferedProgress,
      isPlayerLockEnabled: isPlayerLockEnabled ?? this.isPlayerLockEnabled,
      isSkipSilenceEnabled: isSkipSilenceEnabled ?? this.isSkipSilenceEnabled,
      isPlaybackSpeedEnabled:
          isPlaybackSpeedEnabled ?? this.isPlaybackSpeedEnabled,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      backArrowBacksToLibrary:
          backArrowBacksToLibrary ?? this.backArrowBacksToLibrary,
    );
  }
}
