import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/core/saf/saf.dart';

class SettingsNotifier extends Notifier<UserSettings> {
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
}

final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(
  SettingsNotifier.new,
);

final initialSettingsProvider = Provider<UserSettings>((ref) {
  throw UnimplementedError(
    'initialSettingsProvider must be overridden in ProviderScope',
  );
});
