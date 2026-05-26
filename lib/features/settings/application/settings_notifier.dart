import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/core/saf/saf.dart';

class UserSettingsNotifier extends Notifier<UserSettings> {
  late final UserSettingsRepository _repo;

  @override
  UserSettings build() {
    _repo = ref.read(userSettingsRepositoryProvider);
    return ref.read(initialSettingsProvider);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repo.save(state);
  }

  Future<void> updateHomeFolderUri() async {
    final uri = await Saf.pickTree();
    if (uri == null) return;
    state = state.copyWith(homeFolderUri: uri);
    await _repo.save(state);
  }

  Future<void> toggleCoverPlay() async {
    final newValue = !state.isCoverPlayEnabled;
    state = state.copyWith(isCoverPlayEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> togglePauseLock() async {
    final newValue = !state.isPauseLockEnabled;
    state = state.copyWith(isPauseLockEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> toggleShowBufferedProgress() async {
    final newValue = !state.showBufferedProgress;
    state = state.copyWith(showBufferedProgress: newValue);
    await _repo.save(state);
  }

  Future<void> toggleShowRemainingTime() async {
    final newValue = !state.showRemainingTime;
    state = state.copyWith(showRemainingTime: newValue);
    await _repo.save(state);
  }

  Future<void> togglePlayerLock() async {
    final newValue = !state.isPlayerLockEnabled;
    state = state.copyWith(isPlayerLockEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> enablePlaybackSpeed() async {
    state = state.copyWith(isPlaybackSpeedEnabled: true);
    await _repo.save(state);
  }

  Future<void> disablePlaybackSpeed() async {
    ref.read(playerProvider.notifier).updatePlaybackSpeed(1.0);
    state = state.copyWith(isPlaybackSpeedEnabled: false);
    await _repo.save(state);
  }

  Future<void> togglePlaybackSpeed() async {
    final newValue = !state.isPlaybackSpeedEnabled;

    final speedToApply = newValue ? state.playbackSpeed : 1.0;
    ref.read(playerProvider.notifier).updatePlaybackSpeed(speedToApply);

    state = state.copyWith(isPlaybackSpeedEnabled: newValue);
    await _repo.save(state);
  }

  Future<void> updatePlaybackSpeed(double speed) async {
    ref.read(playerProvider.notifier).updatePlaybackSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
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
