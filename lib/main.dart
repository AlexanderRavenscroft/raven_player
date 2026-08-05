import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/docs/app_docs.dart';
import 'package:raven_player/core/hive/hive_helper.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/features/library/application/audiobook_availability_checker.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/onboarding/application/startup_audiobook_resolver.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/raven_player_app.dart';
import 'package:raven_player/utils/app_version.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await HiveHelper.initHive();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final audioHandler = await AudioService.init(
    builder: () => AppAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId:
          'com.alexanderavenscroft.raven_player.channel.audio',
      androidNotificationChannelName: 'Audiobook playback',
      androidNotificationChannelDescription:
          'Shows playback controls and track info while audio is playing',
      androidNotificationIcon: 'drawable/ic_notification',
      notificationColor: AppColors.primary,
    ),
  );

  final settingsRepository = UserSettingsRepository();
  var settings = await settingsRepository.load();

  if (settings == null) {
    final systemLanguage =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    settings = UserSettings(
      languageCode: AppLanguages.sanitize(systemLanguage),
    );
    await settingsRepository.save(settings);
  }

  final startupResolution = await StartupAudiobookResolver(
    settingsRepository: settingsRepository,
    audiobookRepository: AudiobookRepository(),
    availabilityChecker: AudiobookAvailabilityChecker(),
  ).resolve(settings);
  settings = startupResolution.settings;

  await AppVersion.setAppVersion();
  await AppDocs.loadTextFiles();

  runApp(
    ProviderScope(
      overrides: [
        initialSettingsProvider.overrideWithValue(settings),
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: RavenPlayerApp(
        initialAudiobook: startupResolution.audiobook,
        initialIssue: startupResolution.issue,
      ),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
