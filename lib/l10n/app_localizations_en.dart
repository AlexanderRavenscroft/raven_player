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
      'Pick a folder with subfolders, each holding MP3s of one audiobook.';

  @override
  String get onboardingChooseFolder => 'Choose default folder';

  @override
  String get onboardingFooter =>
      'This can be changed later in the settings.\nMore file formats will be supported in the future.';

  @override
  String onboardingLottieError(String error) {
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
  String get settingsHomeFolderTitle => 'Change home folder';

  @override
  String get settingsNoFolderSelected => 'No folder selected';

  @override
  String get settingsInternalStorage => 'Internal storage';

  @override
  String settingsCurrentFolder(String folder) {
    return 'Current folder:\n$folder';
  }

  @override
  String get settingsThemeTitle => 'Theme';

  @override
  String get settingsThemeLight => 'Light mode';

  @override
  String get settingsThemeDark => 'Dark mode';

  @override
  String get settingsThemeSystem => 'Follow system';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsShowRemainingTimeTitle => 'Show remaining time';

  @override
  String get settingsShowRemainingTimeDescription =>
      'Instead of total chapter duration, show remaining duration instead';

  @override
  String get settingsShowBufferedProgressTitle => 'Show buffered progress';

  @override
  String get settingsShowBufferedProgressDescription =>
      'Show buffered progress on a progress bar';

  @override
  String get settingsBackArrowTitle => 'Back Arrow Opens Library';

  @override
  String get settingsBackArrowDescription =>
      'When enabled, tapping the back arrow returns to the Library instead of minimizing the app.';

  @override
  String get settingsCreatorTitle => 'Creator';

  @override
  String get settingsCreatorDescription =>
      'About the developer of Raven Player.';

  @override
  String get settingsCreatorDialogTitle => 'About Creator';

  @override
  String get settingsLegalTitle => 'Legal';

  @override
  String get settingsLegalDescription =>
      'Read legal information and app notices.';

  @override
  String get settingsAppVersionTitle => 'App version';

  @override
  String settingsAppVersionDescription(String version, String build) {
    return 'Version: $version\nBuild: $build';
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
