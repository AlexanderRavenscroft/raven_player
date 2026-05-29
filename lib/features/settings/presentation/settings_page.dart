import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/presentation/settings_app_bar.dart';
import 'package:raven_player/features/settings/presentation/settings_button.dart';
import 'package:raven_player/features/settings/presentation/settings_credits.dart';
import 'package:raven_player/features/settings/presentation/settings_tile.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_button.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_switch.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/pop_ups/app_scrollable_dialog.dart';
import 'package:raven_player/utils/app_docs.dart';
import 'package:raven_player/utils/app_version.dart';
import 'package:raven_player/utils/uri_utils.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

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
                    ? l10n.settingsNoFolderSelected
                    : _localizedFolderPath(context, prettifyTreeUri(path));
                return SettingsTile(
                  title: l10n.settingsHomeFolderTitle,
                  description: l10n.settingsCurrentFolder(pretty),
                  icon: Icons.folder_outlined,
                  trailing: SettingsButton(
                    icon: Icons.add,
                    onPressed: () async => await ref
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
                  title: l10n.settingsThemeTitle,
                  description: switch (themeMode) {
                    ThemeMode.light => l10n.settingsThemeLight,
                    ThemeMode.dark => l10n.settingsThemeDark,
                    ThemeMode.system => l10n.settingsThemeSystem,
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
                    onChanged: (mode) async => await ref
                        .read(settingsProvider.notifier)
                        .updateThemeMode(mode),
                  ),
                );
              },
            ),

            Consumer(
              builder: (_, ref, _) {
                final languageCode = ref.watch(
                  settingsProvider.select((s) => s.languageCode),
                );
                return SettingsTile(
                  title: l10n.settingsLanguageTitle,
                  description: switch (languageCode) {
                    AppLanguages.polish => l10n.languagePolish,
                    _ => l10n.languageEnglish,
                  },
                  icon: Icons.language,
                  trailing: SettingsToggleButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: AppLanguages.english,
                        label: Text('EN'),
                      ),
                      ButtonSegment(
                        value: AppLanguages.polish,
                        label: Text('PL'),
                      ),
                    ],
                    selected: languageCode,
                    onChanged: (code) async => await ref
                        .read(settingsProvider.notifier)
                        .updateLanguageCode(code),
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
                  title: l10n.settingsShowRemainingTimeTitle,
                  description: l10n.settingsShowRemainingTimeDescription,
                  icon: Icons.textsms_outlined,
                  trailing: SettingsToggleSwitch(
                    value: showRemainingTime,
                    onChanged: (enabled) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleShowRemainingTime(),
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
                  title: l10n.settingsShowBufferedProgressTitle,
                  description: l10n.settingsShowBufferedProgressDescription,
                  icon: Icons.hourglass_empty_rounded,
                  trailing: SettingsToggleSwitch(
                    value: showBufferedProgress,
                    onChanged: (enabled) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleShowBufferedProgress(),
                  ),
                );
              },
            ),
            Consumer(
              builder: (_, ref, _) {
                final backArrowBacksToLibrary = ref.watch(
                  settingsProvider.select((s) => s.backArrowBacksToLibrary),
                );
                return SettingsTile(
                  title: l10n.settingsBackArrowTitle,
                  description: l10n.settingsBackArrowDescription,
                  icon: Icons.arrow_back,
                  trailing: SettingsToggleSwitch(
                    value: backArrowBacksToLibrary,
                    onChanged: (enabled) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleArrowBacksToLibrary(),
                  ),
                );
              },
            ),
            SettingsTile(
              title: l10n.settingsCreatorTitle,
              description: l10n.settingsCreatorDescription,
              icon: Icons.person_outlined,
              trailing: SettingsButton(
                icon: Icons.person,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AppScrollableDialog(
                      headingIcon: Icons.person,
                      headingText: l10n.settingsCreatorDialogTitle,
                      textFile: TextFiles.creator,
                    ),
                  );
                },
              ),
            ),
            SettingsTile(
              title: l10n.settingsLegalTitle,
              description: l10n.settingsLegalDescription,
              icon: Icons.gavel_outlined,
              trailing: SettingsButton(
                icon: Icons.description_outlined,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AppScrollableDialog(
                      headingIcon: Icons.gavel_outlined,
                      headingText: l10n.settingsLegalTitle,
                      textFile: TextFiles.legal,
                    ),
                  );
                },
              ),
            ),

            SettingsTile(
              title: l10n.settingsAppVersionTitle,
              description: l10n.settingsAppVersionDescription(
                AppVersion.version,
                AppVersion.buildNumber,
              ),
              icon: Icons.android,
              trailing: null,
            ),
            SettingsCredits(),
          ],
        ),
      ),
    );
  }

  String _localizedFolderPath(BuildContext context, String path) {
    if (path == 'Internal storage') {
      return context.l10n.settingsInternalStorage;
    }
    return path;
  }
}
