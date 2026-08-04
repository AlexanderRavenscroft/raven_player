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
  String get libraryCheckingForNew => 'Updating library...';

  @override
  String libraryLoadingError(String error) {
    return 'Error loading library:\n$error';
  }

  @override
  String get libraryAudiobookUnavailable =>
      'Audiobook files are no longer available. Updating the library...';

  @override
  String get libraryEmpty => 'No audiobooks found';

  @override
  String get libraryReading => 'READING';

  @override
  String get libraryRead => 'READ';

  @override
  String get libraryMarkAsReadAction => 'Mark as read';

  @override
  String get libraryMarkAsReadingAction => 'Mark as currently reading';

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
  String get settingsChangeFolderTitle => 'Change audiobook folder?';

  @override
  String get settingsChangeFolderWarning =>
      'Choosing a different folder will rebuild your library and reset progress for every book.';

  @override
  String get settingsChangeFolderConfirm => 'Choose folder';

  @override
  String get settingsStopPlaybackAndChangeFolderTitle =>
      'Stop playback and change folder?';

  @override
  String get settingsStopPlaybackAndChangeFolderWarning =>
      'The current audiobook will be stopped and its position saved. Choosing a different folder will rebuild your library and reset progress for every book.';

  @override
  String get settingsStopPlaybackToChooseFolderTitle =>
      'Stop playback to choose folder?';

  @override
  String get settingsStopPlaybackToChooseFolderWarning =>
      'The current audiobook will be stopped and its position saved before the folder picker opens.';

  @override
  String get settingsStopPlaybackAndChooseFolderConfirm =>
      'Stop and choose folder';

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
  String get settingsRestoreLastAudiobookTitle => 'Restore audiobook on launch';

  @override
  String get settingsRestoreLastAudiobookDescription =>
      'Open the last listened audiobook when the app starts.';

  @override
  String get settingsNotificationSeekTitle => 'Notification seek bar';

  @override
  String get settingsNotificationSeekDescription =>
      'Allow seeking from the media notification.';

  @override
  String get settingsAboutTitle => 'About Raven Player';

  @override
  String get settingsAboutDescription =>
      'App information, support, and developer details.';

  @override
  String get settingsLegalTitle => 'Legal';

  @override
  String get settingsLegalDescription => 'Licenses and notices.';

  @override
  String get settingsAppVersionTitle => 'App version';

  @override
  String settingsAppVersionDescription(String version) {
    return 'Version $version';
  }

  @override
  String get settingsFollowRavenPlayer => 'Project and support';

  @override
  String get settingsOpenLinkTitle => 'Open link?';

  @override
  String get settingsOpenEmailTitle => 'Open email app?';

  @override
  String get settingsOpenGitHubDescription =>
      'Open the Raven Player repository on GitHub?';

  @override
  String get settingsOpenEmailDescription =>
      'Open your email app to contact the Raven Player developer?';

  @override
  String get settingsOpenKoFiDescription =>
      'Open Ko-fi to leave an optional tip? Tipping does not unlock features or content.';

  @override
  String get settingsCouldNotOpenLink => 'Could not open link';

  @override
  String get settingsCouldNotOpenEmail => 'Could not open email app';

  @override
  String get tooltipRefreshLibrary => 'Refresh library';

  @override
  String get tooltipOpenSettings => 'Open settings';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipOpenGitHub => 'Open GitHub';

  @override
  String get tooltipSendEmail => 'Send email';

  @override
  String get tooltipOpenKoFi => 'Open Ko-fi';

  @override
  String playerLoadingError(String error) {
    return 'Error loading audiobook: $error';
  }

  @override
  String get playerPlayAction => 'Play';

  @override
  String get playerPauseAction => 'Pause';

  @override
  String get playerReplayAction => 'Replay';

  @override
  String get playerPlaybackLoadingLabel => 'Loading playback';

  @override
  String get playerPreviousChapterAction => 'Previous chapter';

  @override
  String get playerNextChapterAction => 'Next chapter';

  @override
  String playerRewindSecondsAction(int seconds) {
    return 'Rewind $seconds seconds';
  }

  @override
  String playerForwardSecondsAction(int seconds) {
    return 'Fast-forward $seconds seconds';
  }

  @override
  String get playerSleepTimerControl => 'Sleep timer';

  @override
  String get playerSleepTimerHint =>
      'Toggles the timer. Long press to adjust its duration.';

  @override
  String get playerPlaybackSpeedControl => 'Playback speed';

  @override
  String get playerPlaybackSpeedHint =>
      'Changes the selected speed. Long press to adjust it.';

  @override
  String get playerSkipSilenceControl => 'Skip silence';

  @override
  String get playerLockControl => 'Player controls lock';

  @override
  String get playerLockHint => 'Locks the player controls.';

  @override
  String get playerUnlockHint => 'Long press to unlock the player controls.';

  @override
  String get playerAdjustPlaybackSpeed => 'Adjust Playback Speed';

  @override
  String get playerAdjustSleepTimer => 'Adjust Sleep Timer';

  @override
  String get playerLockedMessage =>
      'Controls are locked.\nHold lock button to unlock.';

  @override
  String get playerSkipSilenceOnMessage =>
      'Skip silence: enabled.\nQuiet gaps will be shortened.';

  @override
  String get playerSkipSilenceOffMessage =>
      'Skip silence: disabled.\nQuiet gaps play normally.';

  @override
  String chapterProgress(int current, int total) {
    return 'Chapter $current of $total';
  }

  @override
  String get noChaptersFound => 'No chapters found';

  @override
  String readingProgress(String read, String total, String percent) {
    return 'Read $read of $total ($percent%)';
  }

  @override
  String leftTime(String duration) {
    return 'Left: $duration';
  }

  @override
  String get playbackSourceErrorMessage =>
      'Playback failed here. The file may be damaged. Try skipping ahead.';

  @override
  String get playbackUnknownErrorMessage =>
      'Playback stopped unexpectedly. Try again.';
}
