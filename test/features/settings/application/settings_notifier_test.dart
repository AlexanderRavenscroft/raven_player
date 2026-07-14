import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/user_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const safChannel = MethodChannel('raven/saf');
  late String? pickedTreeUri;

  setUp(() {
    pickedTreeUri = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safChannel, (call) async {
          if (call.method == 'pickTree') {
            return pickedTreeUri;
          }

          throw PlatformException(
            code: 'UNEXPECTED_METHOD',
            message: call.method,
          );
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safChannel, null);
  });

  group('UserSettingsNotifier', () {
    test('updateHomeFolderUri persists newly selected folder uri', () async {
      final repo = FakeUserSettingsRepository();
      final container = _container(
        repo,
        initialSettings: const UserSettings(
          lastOpenedAudiobookId: 'book-1',
        ),
      );
      addTearDown(container.dispose);
      pickedTreeUri = 'content://new-folder';

      final changed = await container
          .read(settingsProvider.notifier)
          .updateHomeFolderUri();

      expect(changed, isTrue);
      expect(
        container.read(settingsProvider).homeFolderUri,
        'content://new-folder',
      );
      expect(repo.saved, isNotNull);
      expect(repo.saved!.homeFolderUri, 'content://new-folder');
      expect(repo.saved!.lastOpenedAudiobookId, isNull);
    });

    test(
      'updateHomeFolderUri returns false and does not save when picker is cancelled',
      () async {
        final repo = FakeUserSettingsRepository();
        final container = _container(repo);
        addTearDown(container.dispose);
        pickedTreeUri = null;

        final changed = await container
            .read(settingsProvider.notifier)
            .updateHomeFolderUri();

        expect(changed, isFalse);
        expect(container.read(settingsProvider).homeFolderUri, isNull);
        expect(repo.saved, isNull);
      },
    );

    test(
      'updateHomeFolderUri returns false and does not save same folder uri',
      () async {
        final repo = FakeUserSettingsRepository();
        final container = _container(
          repo,
          initialSettings: const UserSettings(
            homeFolderUri: 'content://same-folder',
          ),
        );
        addTearDown(container.dispose);
        pickedTreeUri = 'content://same-folder';

        final changed = await container
            .read(settingsProvider.notifier)
            .updateHomeFolderUri();

        expect(changed, isFalse);
        expect(
          container.read(settingsProvider).homeFolderUri,
          'content://same-folder',
        );
        expect(repo.saved, isNull);
      },
    );

    test(
      'updateLanguageCode sanitizes unsupported language before saving',
      () async {
        final repo = FakeUserSettingsRepository();
        final container = _container(repo);
        addTearDown(container.dispose);

        await container
            .read(settingsProvider.notifier)
            .updateLanguageCode('unsupported');

        expect(
          container.read(settingsProvider).languageCode,
          AppLanguages.english,
        );
        expect(repo.saved!.languageCode, AppLanguages.english);
      },
    );

    test(
      'updates simple settings in memory and persistence together',
      () async {
        final repo = FakeUserSettingsRepository();
        final container = _container(repo);
        addTearDown(container.dispose);

        await container
            .read(settingsProvider.notifier)
            .updateThemeMode(ThemeMode.dark);
        await container
            .read(settingsProvider.notifier)
            .toggleShowRemainingTime();
        await container
            .read(settingsProvider.notifier)
            .updateSleepTimerDuration(45);

        final state = container.read(settingsProvider);
        expect(state.themeMode, ThemeMode.dark);
        expect(state.showRemainingTime, isTrue);
        expect(state.sleepTimerDurationMinutes, 45);
        expect(repo.saved!.themeMode, ThemeMode.dark);
        expect(repo.saved!.showRemainingTime, isTrue);
        expect(repo.saved!.sleepTimerDurationMinutes, 45);
      },
    );

    test('toggles launch restoration and persists the change', () async {
      final repo = FakeUserSettingsRepository();
      final container = _container(repo);
      addTearDown(container.dispose);

      await container
          .read(settingsProvider.notifier)
          .toggleRestoreLastAudiobookOnLaunch();

      expect(
        container.read(settingsProvider).restoreLastAudiobookOnLaunch,
        isFalse,
      );
      expect(repo.saved!.restoreLastAudiobookOnLaunch, isFalse);
    });

    test('remembers the latest audiobook while restoration is disabled', () async {
      final repo = FakeUserSettingsRepository();
      final container = _container(
        repo,
        initialSettings: const UserSettings(
          restoreLastAudiobookOnLaunch: false,
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(settingsProvider.notifier)
          .setLastOpenedAudiobookId('book-1');

      expect(
        container.read(settingsProvider).lastOpenedAudiobookId,
        'book-1',
      );
      expect(repo.saved!.lastOpenedAudiobookId, 'book-1');
      expect(repo.saved!.restoreLastAudiobookOnLaunch, isFalse);
    });

    test('clears the last opened audiobook id and persists it', () async {
      final repo = FakeUserSettingsRepository();
      final container = _container(
        repo,
        initialSettings: const UserSettings(
          lastOpenedAudiobookId: 'book-1',
        ),
      );
      addTearDown(container.dispose);

      await container
          .read(settingsProvider.notifier)
          .clearLastOpenedAudiobookId();

      expect(container.read(settingsProvider).lastOpenedAudiobookId, isNull);
      expect(repo.saved!.lastOpenedAudiobookId, isNull);
    });
  });
}

ProviderContainer _container(
  FakeUserSettingsRepository repo, {
  UserSettings initialSettings = const UserSettings(),
}) {
  return ProviderContainer(
    overrides: [
      initialSettingsProvider.overrideWithValue(initialSettings),
      userSettingsRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

class FakeUserSettingsRepository extends UserSettingsRepository {
  UserSettings? saved;

  @override
  Future<UserSettings?> load() async => saved;

  @override
  Future<void> save(UserSettings settings) async {
    saved = settings;
  }
}
