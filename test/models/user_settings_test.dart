import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/models/user_settings.dart';

void main() {
  group('UserSettings defaults', () {
    test('uses safe app defaults', () {
      const settings = UserSettings();

      expect(settings.homeFolderUri, isNull);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.languageCode, AppLanguages.english);
      expect(settings.showRemainingTime, isFalse);
      expect(settings.showBufferedProgress, isFalse);
      expect(settings.backArrowBacksToLibrary, isFalse);
      expect(settings.enableNotificationSlider, isTrue);
      expect(settings.isPlaybackSpeedEnabled, isFalse);
      expect(settings.playbackSpeed, 1.0);
      expect(settings.isSkipSilenceEnabled, isFalse);
      expect(settings.isPlayerLockEnabled, isFalse);
      expect(settings.isSleepTimerEnabled, isFalse);
      expect(settings.sleepTimerDurationMinutes, 10);
    });
  });

  group('UserSettings.copyWith', () {
    test('changes selected fields and preserves the rest', () {
      const settings = UserSettings(
        homeFolderUri: 'old-folder',
        themeMode: ThemeMode.light,
        languageCode: AppLanguages.polish,
        showRemainingTime: false,
        playbackSpeed: 1.5,
      );

      final updated = settings.copyWith(
        themeMode: ThemeMode.dark,
        showRemainingTime: true,
        sleepTimerDurationMinutes: 30,
      );

      expect(updated.homeFolderUri, 'old-folder');
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.languageCode, AppLanguages.polish);
      expect(updated.showRemainingTime, isTrue);
      expect(updated.playbackSpeed, 1.5);
      expect(updated.sleepTimerDurationMinutes, 30);
    });
  });
}
