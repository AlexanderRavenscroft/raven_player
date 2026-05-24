import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:raven_player/core/hive/hive_helper.dart';
import 'package:raven_player/core/theme/app_colors.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/raven_player_app.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  await HiveHelper.initHive();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.raven_player.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
    preloadArtwork: true,
    notificationColor: AppColors.primary,
    androidShowNotificationBadge: true,
  );

  final repo = UserSettingsRepository();
  final settings = await repo.load();

  runApp(
    ProviderScope(
      overrides: [initialSettingsProvider.overrideWithValue(settings)],
      child: const RavenPlayerApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}
