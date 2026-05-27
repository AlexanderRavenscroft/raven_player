import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/hive/hive_boxes.dart';
import 'package:raven_player/core/hive/hive_debug_utils.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/presentation/settings_app_bar.dart';
import 'package:raven_player/features/settings/presentation/settings_button.dart';
import 'package:raven_player/features/settings/presentation/settings_tile.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_button.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_switch.dart';
import 'package:raven_player/utils/uri_utils.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: SettingsAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer(
              builder: (_, ref, _) {
                final path = ref.watch(
                  settingsProvider.select((s) => s.homeFolderUri),
                );
                final pretty = path == null
                    ? 'No folder selected'
                    : prettifyTreeUri(path);
                return SettingsTile(
                  title: 'Change home folder',
                  description: 'Current folder:\n$pretty ',
                  icon: Icons.folder_outlined,
                  trailing: SettingsButton(
                    icon: Icons.add,
                    onPressed: () => ref
                        .read(settingsProvider.notifier)
                        .updateHomeFolderUri(),
                  ),
                );
              },
            ),

            Consumer(
              builder: (_, ref, _) {
                final themeMode = ref.watch(
                  settingsProvider.select((s) => s.themeMode),
                );
                return SettingsTile(
                  title: 'Theme',
                  description: switch (themeMode) {
                    ThemeMode.light => 'Light mode',
                    ThemeMode.dark => 'Dark mode',
                    ThemeMode.system => 'Follow system',
                  },
                  icon: switch (themeMode) {
                    ThemeMode.light => Icons.light_mode_outlined,
                    ThemeMode.dark => Icons.dark_mode_outlined,
                    ThemeMode.system => Icons.brightness_auto_outlined,
                  },
                  trailing: SettingsToggleButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                    selected: themeMode,
                    onChanged: (mode) => ref
                        .read(settingsProvider.notifier)
                        .updateThemeMode(mode),
                  ),
                );
              },
            ),

            Consumer(
              builder: (_, ref, _) {
                final showRemainingTime = ref.watch(
                  settingsProvider.select((s) => s.showRemainingTime),
                );
                return SettingsTile(
                  title: 'Show remaining time',
                  description:
                      'Instead of total chapter duration, show remaining duration instead',
                  icon: Icons.textsms_outlined,
                  trailing: SettingsToggleSwitch(
                    value: showRemainingTime,
                    onChanged: (enabled) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleShowRemainingTime();
                    },
                  ),
                );
              },
            ),

            Consumer(
              builder: (_, ref, _) {
                final showBufferedProgress = ref.watch(
                  settingsProvider.select((s) => s.showBufferedProgress),
                );
                return SettingsTile(
                  title: 'Show buffored progress',
                  description: 'Show buffored progress on a progress bar',
                  icon: Icons.hourglass_empty_rounded,
                  trailing: SettingsToggleSwitch(
                    value: showBufferedProgress,
                    onChanged: (enabled) {
                      ref
                          .read(settingsProvider.notifier)
                          .toggleShowBufferedProgress();
                    },
                  ),
                );
              },
            ),
            SettingsTile(
              title: 'Reset Settingse',
              description: 'Debug setting',
              icon: Icons.delete_forever_outlined,
              trailing: SettingsButton(
                onPressed: () {
                  HiveDebugUtils.deleteBox(HiveBox.userSettings);
                },
                icon: Icons.delete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
