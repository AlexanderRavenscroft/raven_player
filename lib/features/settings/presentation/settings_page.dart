import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/docs/app_docs.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/saf/saf_uri_formatter.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/features/player/application/player_notifier.dart';
import 'package:raven_player/features/player/application/raven_audio_handler.dart';
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
import 'package:raven_player/utils/app_version.dart';

class SettingsPage extends ConsumerWidget {
  final bool openedFromPlayer;

  const SettingsPage({super.key, this.openedFromPlayer = false});

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
                final homeFolderUri = ref.watch(
                  settingsProvider.select((s) => s.homeFolderUri),
                );
                final folderLabel = homeFolderUri == null
                    ? l10n.settingsNoFolderSelected
                    : _localizedFolderPath(
                        context,
                        prettifyTreeUri(homeFolderUri),
                      );

                return SettingsTile(
                  title: l10n.settingsHomeFolderTitle,
                  description: l10n.settingsCurrentFolder(folderLabel),
                  icon: AppIcons.folder,
                  trailing: SettingsButton(
                    icon: AppIcons.add,
                    onPressed: () async =>
                        await _changeHomeFolderUri(context, ref, homeFolderUri),
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
                    onChanged: (_) async => await ref
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
                    onChanged: (_) async => await ref
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
                    onChanged: (_) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleArrowBacksToLibrary(),
                  ),
                );
              },
            ),
            Consumer(
              builder: (_, ref, _) {
                final enableNotificationSlider = ref.watch(
                  settingsProvider.select((s) => s.enableNotificationSlider),
                );

                return SettingsTile(
                  title: l10n.settingsNotificationSeekTitle,
                  description: l10n.settingsNotificationSeekDescription,
                  icon: AppIcons.enableNotificationSlider,
                  trailing: SettingsToggleSwitch(
                    value: enableNotificationSlider,
                    onChanged: (_) async => await ref
                        .read(settingsProvider.notifier)
                        .toggleNotificationSlider(),
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
              title: l10n.settingsAboutTitle,
              description: l10n.settingsAboutDescription,
              icon: AppIcons.about,
              trailing: SettingsButton(
                icon: AppIcons.aboutDocument,
                onPressed: () => _showDocsDialog(
                  context,
                  ref,
                  icon: AppIcons.about,
                  title: l10n.settingsAboutTitle,
                  file: TextFiles.about,
                ),
              ),
            ),
            SettingsTile(
              title: l10n.settingsLegalTitle,
              description: l10n.settingsLegalDescription,
              icon: AppIcons.legal,
              trailing: SettingsButton(
                icon: AppIcons.legalDocument,
                onPressed: () => _showDocsDialog(
                  context,
                  ref,
                  icon: AppIcons.legal,
                  title: l10n.settingsLegalTitle,
                  file: TextFiles.legal,
                ),
              ),
            ),
            SettingsTile(
              title: l10n.settingsAppVersionTitle,
              description: l10n.settingsAppVersionDescription(
                AppVersion.version,
                AppVersion.buildNumber,
              ),
              icon: AppIcons.appVersion,
            ),
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

  void _showDocsDialog(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required TextFiles file,
  }) {
    showDialog<void>(
      context: context,
      builder: (_) {
        final languageCode = ref.read(settingsProvider).languageCode;

        return AppScrollableDialog(
          headingIcon: icon,
          headingText: title,
          content: AppDocs.getText(file, languageCode: languageCode),
        );
      },
    );
  }

  Future<void> _changeHomeFolderUri(
    BuildContext context,
    WidgetRef ref,
    String? currentFolderUri,
  ) async {
    final hasLoadedAudiobook = ref.read(playerProvider) != null;
    final isPlaying = ref.read(audioHandlerProvider).isPlaying;

    if (hasLoadedAudiobook && isPlaying) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppConfirmDialog(
          title: currentFolderUri == null
              ? dialogContext.l10n.settingsStopPlaybackToChooseFolderTitle
              : dialogContext.l10n.settingsStopPlaybackAndChangeFolderTitle,
          content: currentFolderUri == null
              ? dialogContext.l10n.settingsStopPlaybackToChooseFolderWarning
              : dialogContext.l10n.settingsStopPlaybackAndChangeFolderWarning,
          level: currentFolderUri == null
              ? AppConfirmDialogLevel.info
              : AppConfirmDialogLevel.warning,
          acceptText:
              dialogContext.l10n.settingsStopPlaybackAndChooseFolderConfirm,
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    if (!(hasLoadedAudiobook && isPlaying) &&
        currentFolderUri != null &&
        context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppConfirmDialog(
          title: dialogContext.l10n.settingsChangeFolderTitle,
          content: dialogContext.l10n.settingsChangeFolderWarning,
          level: AppConfirmDialogLevel.warning,
          acceptText: dialogContext.l10n.settingsChangeFolderConfirm,
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    final changed = await ref
        .read(settingsProvider.notifier)
        .updateHomeFolderUri();

    if (!changed) return;

    await ref.read(playerProvider.notifier).stopForFolderChange();

    if (openedFromPlayer && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
