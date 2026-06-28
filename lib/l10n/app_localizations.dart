import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// Application title used by MaterialApp.
  ///
  /// In en, this message translates to:
  /// **'Raven Player'**
  String get appTitle;

  /// Generic dialog button that closes without applying changes.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// Generic dialog button that confirms the current action.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get dialogConfirm;

  /// Generic dialog acknowledgement button.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get dialogOk;

  /// Dialog button that applies an audiobook rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get dialogRename;

  /// Dialog button that opens an external link.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dialogOpen;

  /// Generic dialog button that closes the dialog.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get dialogClose;

  /// Display name for the English app language.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Display name for the Polish app language.
  ///
  /// In en, this message translates to:
  /// **'Polski'**
  String get languagePolish;

  /// Main title shown on the first-run onboarding screen.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get started'**
  String get onboardingTitle;

  /// Onboarding text explaining the expected audiobook folder structure.
  ///
  /// In en, this message translates to:
  /// **'Pick a folder with subfolders, each containing audio files for one audiobook.'**
  String get onboardingDescription;

  /// Button label for selecting the initial audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'Choose default folder'**
  String get onboardingChooseFolder;

  /// Onboarding note about changing the folder later and future file support.
  ///
  /// In en, this message translates to:
  /// **'Supported audio formats: MP3, M4A, M4B, FLAC, and OGG. You can change the folder later in settings.'**
  String get onboardingFooter;

  /// Fallback text shown when a Lottie animation fails to load.
  ///
  /// In en, this message translates to:
  /// **'Lottie error: {error}'**
  String lottieError(String error);

  /// Title shown in the library app bar.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// Snackbar shown when the user starts a library rescan.
  ///
  /// In en, this message translates to:
  /// **'Updating library...'**
  String get libraryCheckingForNew;

  /// Message shown when the audiobook library fails to load.
  ///
  /// In en, this message translates to:
  /// **'Error loading library:\n{error}'**
  String libraryLoadingError(String error);

  /// Snackbar shown when a stale audiobook can no longer be opened from the library.
  ///
  /// In en, this message translates to:
  /// **'Audiobook files are no longer available. Updating the library...'**
  String get libraryAudiobookUnavailable;

  /// Message shown when the current library filter has no audiobooks.
  ///
  /// In en, this message translates to:
  /// **'No audiobooks found'**
  String get libraryEmpty;

  /// Library filter tab for audiobooks currently being read.
  ///
  /// In en, this message translates to:
  /// **'READING'**
  String get libraryReading;

  /// Library filter tab for audiobooks marked as read.
  ///
  /// In en, this message translates to:
  /// **'READ'**
  String get libraryRead;

  /// Fallback author text when audiobook metadata has no author.
  ///
  /// In en, this message translates to:
  /// **'Unknown author'**
  String get libraryUnknownAuthor;

  /// Title of the dialog used to rename an audiobook.
  ///
  /// In en, this message translates to:
  /// **'Rename Audiobook'**
  String get libraryRenameTitle;

  /// Text field hint in the audiobook rename dialog.
  ///
  /// In en, this message translates to:
  /// **'Enter new audiobook title'**
  String get libraryRenameHint;

  /// Title shown in the settings app bar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings row title for the selected audiobook home folder.
  ///
  /// In en, this message translates to:
  /// **'Audiobook folder'**
  String get settingsHomeFolderTitle;

  /// Shown when no audiobook home folder has been selected.
  ///
  /// In en, this message translates to:
  /// **'No folder selected'**
  String get settingsNoFolderSelected;

  /// Readable label for the device internal storage root.
  ///
  /// In en, this message translates to:
  /// **'Internal storage'**
  String get settingsInternalStorage;

  /// Settings row description showing the current audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'Current:\n{folder}'**
  String settingsCurrentFolder(String folder);

  /// Confirmation dialog title shown before changing the audiobook folder from settings.
  ///
  /// In en, this message translates to:
  /// **'Change audiobook folder?'**
  String get settingsChangeFolderTitle;

  /// Danger confirmation message shown before changing the audiobook folder from settings.
  ///
  /// In en, this message translates to:
  /// **'Choosing a different folder will rebuild your library and reset progress for every book.'**
  String get settingsChangeFolderWarning;

  /// Confirmation dialog button that proceeds to the system folder picker.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get settingsChangeFolderConfirm;

  /// Confirmation dialog title shown before stopping the current audiobook and changing an existing audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'Stop playback and change folder?'**
  String get settingsStopPlaybackAndChangeFolderTitle;

  /// Confirmation dialog message shown before stopping the current audiobook and changing an existing audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'The current audiobook will be stopped and its position saved. Choosing a different folder will rebuild your library and reset progress for every book.'**
  String get settingsStopPlaybackAndChangeFolderWarning;

  /// Confirmation dialog title shown before stopping the current audiobook and choosing the first audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'Stop playback to choose folder?'**
  String get settingsStopPlaybackToChooseFolderTitle;

  /// Confirmation dialog message shown before stopping the current audiobook and choosing the first audiobook folder.
  ///
  /// In en, this message translates to:
  /// **'The current audiobook will be stopped and its position saved before the folder picker opens.'**
  String get settingsStopPlaybackToChooseFolderWarning;

  /// Confirmation dialog button that stops playback and proceeds to the system folder picker.
  ///
  /// In en, this message translates to:
  /// **'Stop and choose folder'**
  String get settingsStopPlaybackAndChooseFolderConfirm;

  /// Settings row title for app theme selection.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeTitle;

  /// Description shown when the light theme is selected.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Description shown when the dark theme is selected.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Description shown when the app follows the system theme.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// Settings row title for app language selection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// Settings row title for showing remaining playback time.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get settingsShowRemainingTimeTitle;

  /// Settings row description for the remaining time option.
  ///
  /// In en, this message translates to:
  /// **'Show time left instead of total.'**
  String get settingsShowRemainingTimeDescription;

  /// Settings row title for showing buffered audio progress.
  ///
  /// In en, this message translates to:
  /// **'Buffered progress'**
  String get settingsShowBufferedProgressTitle;

  /// Settings row description for the buffered progress option.
  ///
  /// In en, this message translates to:
  /// **'Show loaded audio on the progress bar.'**
  String get settingsShowBufferedProgressDescription;

  /// Settings row title for back arrow behavior on the player screen.
  ///
  /// In en, this message translates to:
  /// **'Back behavior'**
  String get settingsBackArrowTitle;

  /// Settings row description for back arrow behavior on the player screen.
  ///
  /// In en, this message translates to:
  /// **'Return to Library instead of minimizing.'**
  String get settingsBackArrowDescription;

  /// Settings row title for allowing seeking from the media notification.
  ///
  /// In en, this message translates to:
  /// **'Notification seek bar'**
  String get settingsNotificationSeekTitle;

  /// Settings row description for allowing seeking from the media notification.
  ///
  /// In en, this message translates to:
  /// **'Allow seeking from the media notification.'**
  String get settingsNotificationSeekDescription;

  /// Settings row title for about app information.
  ///
  /// In en, this message translates to:
  /// **'About Raven Player'**
  String get settingsAboutTitle;

  /// Settings row description for about app information.
  ///
  /// In en, this message translates to:
  /// **'App information, support, and developer details.'**
  String get settingsAboutDescription;

  /// Settings row and dialog title for legal information.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegalTitle;

  /// Settings row description for legal information.
  ///
  /// In en, this message translates to:
  /// **'Licenses and notices.'**
  String get settingsLegalDescription;

  /// Settings row title for app version information.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersionTitle;

  /// Settings row description showing app version and build number.
  ///
  /// In en, this message translates to:
  /// **'v{version} (build {build})'**
  String settingsAppVersionDescription(String version, String build);

  /// Credits prompt shown above external project links.
  ///
  /// In en, this message translates to:
  /// **'Project and support'**
  String get settingsFollowRavenPlayer;

  /// Confirmation dialog title before opening an external link.
  ///
  /// In en, this message translates to:
  /// **'Open link?'**
  String get settingsOpenLinkTitle;

  /// Confirmation dialog title before opening an email app from settings.
  ///
  /// In en, this message translates to:
  /// **'Open email app?'**
  String get settingsOpenEmailTitle;

  /// Snackbar shown when an external link cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get settingsCouldNotOpenLink;

  /// Snackbar shown when the email app cannot be opened.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get settingsCouldNotOpenEmail;

  /// Tooltip for the app bar button that rescans the audiobook library.
  ///
  /// In en, this message translates to:
  /// **'Refresh library'**
  String get tooltipRefreshLibrary;

  /// Tooltip for the app bar button that opens settings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get tooltipOpenSettings;

  /// Tooltip for the app bar button that returns to the previous screen.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// Tooltip for the credits button that opens GitHub.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub'**
  String get tooltipOpenGitHub;

  /// Tooltip for the credits button that opens an email app.
  ///
  /// In en, this message translates to:
  /// **'Send email'**
  String get tooltipSendEmail;

  /// Tooltip for the credits button that opens Ko-fi.
  ///
  /// In en, this message translates to:
  /// **'Open Ko-fi'**
  String get tooltipOpenKoFi;

  /// Message shown when the player fails to load an audiobook.
  ///
  /// In en, this message translates to:
  /// **'Error loading audiobook: {error}'**
  String playerLoadingError(String error);

  /// Title of the dialog used to change playback speed.
  ///
  /// In en, this message translates to:
  /// **'Adjust Playback Speed'**
  String get playerAdjustPlaybackSpeed;

  /// Title of the dialog used to change the sleep timer duration.
  ///
  /// In en, this message translates to:
  /// **'Adjust Sleep Timer'**
  String get playerAdjustSleepTimer;

  /// Snackbar shown when the user taps a locked player control.
  ///
  /// In en, this message translates to:
  /// **'Controls are locked.\nHold lock button to unlock.'**
  String get playerLockedMessage;

  /// Text showing the current chapter number and total chapter count.
  ///
  /// In en, this message translates to:
  /// **'Chapter {current} of {total}'**
  String chapterProgress(int current, int total);

  /// Text shown when an audiobook has no chapters.
  ///
  /// In en, this message translates to:
  /// **'No chapters found'**
  String get noChaptersFound;

  /// Text showing completed audiobook time, total time, and percent progress.
  ///
  /// In en, this message translates to:
  /// **'Read {read} of {total} ({percent}%)'**
  String readingProgress(String read, String total, String percent);

  /// Text showing remaining audiobook time.
  ///
  /// In en, this message translates to:
  /// **'Left: {duration}'**
  String leftTime(String duration);

  /// Snackbar message shown when audio playback fails because the audio source cannot be read or parsed.
  ///
  /// In en, this message translates to:
  /// **'Playback failed here. The file may be damaged. Try skipping ahead.'**
  String get playbackSourceErrorMessage;

  /// Snackbar message shown when audio playback fails for an unknown reason.
  ///
  /// In en, this message translates to:
  /// **'Playback stopped unexpectedly. Try again.'**
  String get playbackUnknownErrorMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
