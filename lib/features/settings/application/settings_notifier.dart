import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/saf/saf.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/user_settings.dart';

class UserSettingsNotifier extends Notifier<UserSettings> {
  static const double _defaultPlaybackSpeed = 1.0;

  late final UserSettingsRepository _repo;

  @override
  UserSettings build() {
    _repo = ref.read(userSettingsRepositoryProvider);
    return ref.read(initialSettingsProvider);
  }

  Future<bool> updateHomeFolderUri() async {
    final uri = await Saf.pickTree();
    if (uri == null || uri == state.homeFolderUri) return false;

    state = state.copyWith(homeFolderUri: uri);
    await _repo.save(state);
    return true;
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> updateLanguageCode(String languageCode) async {
    final code = AppLanguages.sanitize(languageCode);
    state = state.copyWith(languageCode: code);
    await _repo.save(state);
  }

  Future<void> toggleShowRemainingTime() async {
    final newValue = !state.showRemainingTime;
    state = state.copyWith(showRemainingTime: newValue);
    await _repo.save(state);
  }

  Future<void> toggleShowBufferedProgress() async {
    final newValue = !state.showBufferedProgress;
    state = state.copyWith(showBufferedProgress: newValue);
    await _repo.save(state);
  }

  Future<void> toggleArrowBacksToLibrary() async {
    final newValue = !state.backArrowBacksToLibrary;
    state = state.copyWith(backArrowBacksToLibrary: newValue);
    await _repo.save(state);
  }

  Future<void> enablePlaybackSpeed() async {
    state = state.copyWith(isPlaybackSpeedEnabled: true);
    await _repo.save(state);
  }

  Future<void> disablePlaybackSpeed() async {
    await ref.read(audioHandlerProvider).setSpeed(_defaultPlaybackSpeed);
    state = state.copyWith(isPlaybackSpeedEnabled: false);
    await _repo.save(state);
  }

  Future<void> togglePlaybackSpeed() async {
    final newValue = !state.isPlaybackSpeedEnabled;

    final speedToApply = newValue ? state.playbackSpeed : _defaultPlaybackSpeed;
    await ref.read(audioHandlerProvider).setSpeed(speedToApply);

    state = state.copyWith(isPlaybackSpeedEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> updatePlaybackSpeed(double speed) async {
    await ref.read(audioHandlerProvider).setSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
    await _repo.save(state);
  }

  Future<void> toggleSkipSilence() async {
    final newValue = !state.isSkipSilenceEnabled;
    await ref.read(audioHandlerProvider).setSkipSilenceEnabled(newValue);
    state = state.copyWith(isSkipSilenceEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> enablePlayerLock() async {
    state = state.copyWith(isPlayerLockEnabled: true);
    await _repo.save(state);
  }

  Future<void> disablePlayerLock() async {
    state = state.copyWith(isPlayerLockEnabled: false);
    await _repo.save(state);
  }

  Future<void> enableSleepTimer() async {
    state = state.copyWith(isSleepTimerEnabled: true);
    await _repo.save(state);
  }

  Future<void> disableSleepTimer() async {
    state = state.copyWith(isSleepTimerEnabled: false);
    await _repo.save(state);
  }

  Future<void> toggleSleepTimer() async {
    final newValue = !state.isSleepTimerEnabled;
    state = state.copyWith(isSleepTimerEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> updateSleepTimerDuration(int minutes) async {
    state = state.copyWith(sleepTimerDurationMinutes: minutes);
    await _repo.save(state);
  }
}

final settingsProvider = NotifierProvider<UserSettingsNotifier, UserSettings>(
  UserSettingsNotifier.new,
);

final initialSettingsProvider = Provider<UserSettings>((ref) {
  throw UnimplementedError(
    'initialSettingsProvider must be overridden in ProviderScope',
  );
});
