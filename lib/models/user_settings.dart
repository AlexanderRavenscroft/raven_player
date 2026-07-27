import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:raven_player/core/localization/app_languages.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings {
  static const Object _unset = Object();

  //* App settings
  @HiveField(0)
  final String? homeFolderUri;

  @HiveField(1)
  final ThemeMode themeMode;

  @HiveField(2)
  final String languageCode;

  //* Player display and navigation
  @HiveField(3)
  final bool showRemainingTime;

  @HiveField(4)
  final bool showBufferedProgress;

  @HiveField(5)
  final bool backArrowBacksToLibrary;

  @HiveField(6)
  final bool enableNotificationSlider;

  //* Playback controls
  @HiveField(7)
  final bool isPlaybackSpeedEnabled;

  @HiveField(8)
  final double playbackSpeed;

  @HiveField(9)
  final bool isSkipSilenceEnabled;

  @HiveField(11)
  final bool isPlayerLockEnabled;

  @HiveField(12)
  final bool isSleepTimerEnabled;

  @HiveField(13)
  final int sleepTimerDurationMinutes;

  //* App launch
  @HiveField(14)
  final bool restoreLastAudiobookOnLaunch;

  @HiveField(15)
  final String? lastOpenedAudiobookId;

  const UserSettings({
    //* App settings
    this.homeFolderUri,
    this.themeMode = ThemeMode.system,
    this.languageCode = AppLanguages.english,

    //* Player display and navigation
    this.showRemainingTime = false,
    this.showBufferedProgress = false,
    this.backArrowBacksToLibrary = false,
    this.enableNotificationSlider = true,

    //* Playback controls
    this.isPlayerLockEnabled = false,
    this.isPlaybackSpeedEnabled = false,
    this.isSkipSilenceEnabled = false,
    this.playbackSpeed = 1.0,
    this.isSleepTimerEnabled = false,
    this.sleepTimerDurationMinutes = 10,

    //* App launch
    this.restoreLastAudiobookOnLaunch = true,
    this.lastOpenedAudiobookId,
  });

  UserSettings copyWith({
    String? homeFolderUri,
    ThemeMode? themeMode,
    String? languageCode,
    bool? showRemainingTime,
    bool? showBufferedProgress,
    bool? backArrowBacksToLibrary,
    bool? enableNotificationSlider,
    bool? isPlayerLockEnabled,
    bool? isPlaybackSpeedEnabled,
    bool? isSkipSilenceEnabled,
    double? playbackSpeed,
    bool? isSleepTimerEnabled,
    int? sleepTimerDurationMinutes,
    bool? restoreLastAudiobookOnLaunch,
    Object? lastOpenedAudiobookId = _unset,
  }) {
    return UserSettings(
      homeFolderUri: homeFolderUri ?? this.homeFolderUri,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      showRemainingTime: showRemainingTime ?? this.showRemainingTime,
      showBufferedProgress: showBufferedProgress ?? this.showBufferedProgress,
      backArrowBacksToLibrary:
          backArrowBacksToLibrary ?? this.backArrowBacksToLibrary,
      enableNotificationSlider:
          enableNotificationSlider ?? this.enableNotificationSlider,
      isPlayerLockEnabled: isPlayerLockEnabled ?? this.isPlayerLockEnabled,
      isSkipSilenceEnabled: isSkipSilenceEnabled ?? this.isSkipSilenceEnabled,
      isPlaybackSpeedEnabled:
          isPlaybackSpeedEnabled ?? this.isPlaybackSpeedEnabled,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isSleepTimerEnabled: isSleepTimerEnabled ?? this.isSleepTimerEnabled,
      sleepTimerDurationMinutes:
          sleepTimerDurationMinutes ?? this.sleepTimerDurationMinutes,
      restoreLastAudiobookOnLaunch:
          restoreLastAudiobookOnLaunch ?? this.restoreLastAudiobookOnLaunch,
      lastOpenedAudiobookId: identical(lastOpenedAudiobookId, _unset)
          ? this.lastOpenedAudiobookId
          : lastOpenedAudiobookId as String?,
    );
  }
}
