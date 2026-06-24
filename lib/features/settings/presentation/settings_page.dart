import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:raven_player/core/docs/app_docs.dart';
import 'package:raven_player/core/localization/app_languages.dart';
import 'package:raven_player/core/saf/saf_uri_formatter.dart';
import 'package:raven_player/core/theme/app_icons.dart';
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
                onPressed: () => _showDocsDialog(
                  context,
                  ref,
                  icon: AppIcons.creator,
                  title: l10n.settingsCreatorDialogTitle,
                  file: TextFiles.creator,
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
    final player = ref.read(audioHandlerProvider).player;
    final processingState = player.processingState;
    final isPlaying = player.playing;

    if (processingState == ProcessingState.ready && !isPlaying) {
      await ref.read(audioHandlerProvider).clearSession();
    } else if (processingState != ProcessingState.idle) {
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => const AppConfirmDialog(
          title:
              'Cannot change audiobook folder.', //TODO Add translatinos && Look at UX
          content:
              'Cannot change audiobook folder when player is playing. Dispose the player or pause it, to change the audiobook folder.',
          level: AppConfirmDialogLevel.danger,
          acceptText: 'Okay',
          showOnlyAccept: true,
        ),
      );
      return;
    }

    if (currentFolderUri != null && context.mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppConfirmDialog(
          title: dialogContext.l10n.settingsChangeFolderTitle,
          content: dialogContext.l10n.settingsChangeFolderWarning,
          level: AppConfirmDialogLevel.warning,
          acceptText: dialogContext.l10n.settingsChangeFolderConfirm,
          onAccept: () =>
              ref.read(settingsProvider.notifier).updateHomeFolderUri(),
        ),
      );

      if (confirmed != true || !context.mounted) {
        return;
      }
    }

    await ref.read(settingsProvider.notifier).updateHomeFolderUri();
  }
}
