// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Raven Player';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get dialogOk => 'Ok';

  @override
  String get dialogRename => 'Rename';

  @override
  String get dialogOpen => 'Open';

  @override
  String get dialogClose => 'Close';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get onboardingTitle => 'Let\'s get started';

  @override
  String get onboardingDescription =>
      'Pick a folder with subfolders, each containing audio files for one audiobook.';

  @override
  String get onboardingChooseFolder => 'Choose default folder';

  @override
  String get onboardingFooter =>
      'Supported audio formats: MP3, M4A, M4B, FLAC, and OGG. You can change the folder later in settings.';

  @override
  String lottieError(String error) {
    return 'Lottie error: $error';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryCheckingForNew => 'Checking for new audiobooks...';

  @override
  String libraryLoadingError(String error) {
    return 'Error loading library:\n$error';
  }

  @override
  String get libraryEmpty => 'No audiobooks found';

  @override
  String get libraryReading => 'READING';

  @override
  String get libraryRead => 'READ';

  @override
  String get libraryUnknownAuthor => 'Unknown author';

  @override
  String get libraryRenameTitle => 'Rename Audiobook';

  @override
  String get libraryRenameHint => 'Enter new audiobook title';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHomeFolderTitle => 'Audiobook folder';

  @override
  String get settingsNoFolderSelected => 'No folder selected';

  @override
  String get settingsInternalStorage => 'Internal storage';

  @override
  String settingsCurrentFolder(String folder) {
    return 'Current:\n$folder';
  }

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsShowRemainingTimeTitle => 'Remaining time';

  @override
  String get settingsShowRemainingTimeDescription =>
      'Show time left instead of total.';

  @override
  String get settingsShowBufferedProgressTitle => 'Buffered progress';

  @override
  String get settingsShowBufferedProgressDescription =>
      'Show loaded audio on the progress bar.';

  @override
  String get settingsBackArrowTitle => 'Back behavior';

  @override
  String get settingsBackArrowDescription =>
      'Return to Library instead of minimizing.';

  @override
  String get settingsCreatorTitle => 'Developer';

  @override
  String get settingsCreatorDescription => 'About the app creator.';

  @override
  String get settingsCreatorDialogTitle => 'About the developer';

  @override
  String get settingsLegalTitle => 'Legal';

  @override
  String get settingsLegalDescription => 'Licenses and notices.';

  @override
  String get settingsAppVersionTitle => 'App version';

  @override
  String settingsAppVersionDescription(String version, String build) {
    return 'v$version (build $build)';
  }

  @override
  String get settingsMadeWithFlutter => 'Made with Flutter';

  @override
  String get settingsFollowRavenPlayer => 'Follow Raven Player:';

  @override
  String get settingsOpenLinkTitle => 'Open link?';

  @override
  String get settingsCouldNotOpenLink => 'Could not open link';

  @override
  String playerLoadingError(String error) {
    return 'Error loading audiobook: $error';
  }

  @override
  String get playerAdjustPlaybackSpeed => 'Adjust Playback Speed';

  @override
  String get playerAdjustSleepTimer => 'Adjust Sleep Timer';

  @override
  String get playerSet => 'Set';

  @override
  String get playerLockedMessage => 'Player is locked.\nLong press to unlock.';

  @override
  String get playerDropdownLocked =>
      'Dropdown is locked.\nYou can enable it in toolbar.';

  @override
  String get playerSliderLocked =>
      'Slider is locked.\nYou can enable it in toolbar.';

  @override
  String chapterProgress(int current, int total) {
    return 'Chapter $current of $total';
  }

  @override
  String readingProgress(String read, String total, String percent) {
    return 'Read $read of $total ($percent%)';
  }

  @override
  String leftTime(String duration) {
    return 'Left: $duration';
  }
}
