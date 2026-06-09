import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/settings/application/settings_notifier.dart';
import 'package:raven_player/features/settings/presentation/settings_app_bar.dart';
import 'package:raven_player/features/settings/presentation/settings_button.dart';
import 'package:raven_player/features/settings/presentation/settings_credits.dart';
import 'package:raven_player/features/settings/presentation/settings_tile.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_button.dart';
import 'package:raven_player/features/settings/presentation/settings_toggle_switch.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/app_confirm_dialog.dart';
import 'package:raven_player/shared/dialogs/app_scrollable_dialog.dart';
import 'package:raven_player/core/docs/app_docs.dart';
import 'package:raven_player/utils/app_version.dart';
import 'package:raven_player/core/saf/saf_uri_formatter.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: const SettingsAppBar(),
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
                  icon: AppIcons.folder,
                  trailing: SettingsButton(
                    icon: AppIcons.add,
                    onPressed: () async =>
                        await _changeHomeFolderUri(context, ref, path),
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
                    ThemeMode.light => AppIcons.themeLight,
                    ThemeMode.dark => AppIcons.themeDark,
                    ThemeMode.system => AppIcons.themeSystem,
                  },
                  trailing: SettingsToggleButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(AppIcons.themeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(AppIcons.themeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(AppIcons.themeDark),
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
                final showRemainingTime = ref.watch(
                  settingsProvider.select((s) => s.showRemainingTime),
                );
                return SettingsTile(
                  title: l10n.settingsShowRemainingTimeTitle,
                  description: l10n.settingsShowRemainingTimeDescription,
                  icon: AppIcons.showRemainingTime,
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
                  icon: AppIcons.showBufferedProgress,
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
                  icon: AppIcons.systemBackBehavior,
                  trailing: SettingsToggleSwitch(
                    value: backArrowBacksToLibrary,
                    onChanged: (enabled) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleArrowBacksToLibrary(),
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
                  icon: AppIcons.language,
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
            SettingsTile(
              title: l10n.settingsCreatorTitle,
              description: l10n.settingsCreatorDescription,
              icon: AppIcons.creator,
              trailing: SettingsButton(
                icon: AppIcons.creator,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      final languageCode = ref
                          .read(settingsProvider)
                          .languageCode;

                      return AppScrollableDialog(
                        headingIcon: AppIcons.creator,
                        headingText: l10n.settingsCreatorDialogTitle,
                        content: AppDocs.getText(
                          TextFiles.creator,
                          languageCode: languageCode,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SettingsTile(
              title: l10n.settingsLegalTitle,
              description: l10n.settingsLegalDescription,
              icon: AppIcons.legal,
              trailing: SettingsButton(
                icon: AppIcons.legalDocument,
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) {
                      final languageCode = ref
                          .read(settingsProvider)
                          .languageCode;

                      return AppScrollableDialog(
                        headingIcon: AppIcons.legal,
                        headingText: l10n.settingsLegalTitle,
                        content: AppDocs.getText(
                          TextFiles.legal,
                          languageCode: languageCode,
                        ),
                      );
                    },
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
              icon: AppIcons.appVersion,
              trailing: null,
            ),

            const SizedBox(height: AppSpacing.xs),
            const SettingsCredits(),
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

  Future<void> _changeHomeFolderUri(
    BuildContext context,
    WidgetRef ref,
    String? currentFolderUri,
  ) async {
    if (currentFolderUri != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppConfirmDialog(
          title: dialogContext.l10n.settingsChangeFolderTitle,
          content: dialogContext.l10n.settingsChangeFolderWarning,
          level: AppConfirmDialogLevel.danger,
          acceptText: dialogContext.l10n.settingsChangeFolderConfirm,
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    await ref.read(settingsProvider.notifier).updateHomeFolderUri();
  }
}
