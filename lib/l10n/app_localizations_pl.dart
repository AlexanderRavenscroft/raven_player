// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Raven Player';

  @override
  String get dialogCancel => 'Anuluj';

  @override
  String get dialogConfirm => 'Potwierdź';

  @override
  String get dialogOk => 'Ok';

  @override
  String get dialogRename => 'Zmień nazwę';

  @override
  String get dialogOpen => 'Otwórz';

  @override
  String get dialogClose => 'Zamknij';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePolish => 'Polski';

  @override
  String get onboardingTitle => 'Zacznijmy';

  @override
  String get onboardingDescription =>
      'Wybierz folder z podfolderami, z których każdy zawiera pliki MP3 jednego audiobooka.';

  @override
  String get onboardingChooseFolder => 'Wybierz folder domyślny';

  @override
  String get onboardingFooter =>
      'Możesz to później zmienić w ustawieniach.\nWięcej formatów plików będzie obsługiwanych w przyszłości.';

  @override
  String onboardingLottieError(String error) {
    return 'Błąd Lottie: $error';
  }

  @override
  String get libraryTitle => 'Biblioteka';

  @override
  String get libraryCheckingForNew => 'Sprawdzanie nowych audiobooków...';

  @override
  String libraryLoadingError(String error) {
    return 'Błąd wczytywania biblioteki:\n$error';
  }

  @override
  String get libraryEmpty => 'Nie znaleziono audiobooków';

  @override
  String get libraryReading => 'CZYTANE';

  @override
  String get libraryRead => 'PRZECZYTANE';

  @override
  String get libraryUnknownAuthor => 'Nieznany autor';

  @override
  String get libraryRenameTitle => 'Zmień nazwę audiobooka';

  @override
  String get libraryRenameHint => 'Wpisz nowy tytuł audiobooka';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsHomeFolderTitle => 'Zmień folder domowy';

  @override
  String get settingsNoFolderSelected => 'Nie wybrano folderu';

  @override
  String get settingsInternalStorage => 'Pamięć wewnętrzna';

  @override
  String settingsCurrentFolder(String folder) {
    return 'Obecny folder:\n$folder';
  }

  @override
  String get settingsThemeTitle => 'Motyw';

  @override
  String get settingsThemeLight => 'Tryb jasny';

  @override
  String get settingsThemeDark => 'Tryb ciemny';

  @override
  String get settingsThemeSystem => 'Zgodnie z systemem';

  @override
  String get settingsLanguageTitle => 'Język';

  @override
  String get settingsShowRemainingTimeTitle => 'Pokaż pozostały czas';

  @override
  String get settingsShowRemainingTimeDescription =>
      'Zamiast całkowitego czasu rozdziału pokaż pozostały czas';

  @override
  String get settingsShowBufferedProgressTitle => 'Pokaż buforowanie';

  @override
  String get settingsShowBufferedProgressDescription =>
      'Pokaż zbuforowany postęp na pasku postępu';

  @override
  String get settingsBackArrowTitle => 'Strzałka wstecz otwiera bibliotekę';

  @override
  String get settingsBackArrowDescription =>
      'Po włączeniu dotknięcie strzałki wstecz wraca do Biblioteki zamiast minimalizować aplikację.';

  @override
  String get settingsCreatorTitle => 'Twórca';

  @override
  String get settingsCreatorDescription => 'Informacje o twórcy Raven Player.';

  @override
  String get settingsCreatorDialogTitle => 'O twórcy';

  @override
  String get settingsLegalTitle => 'Informacje prawne';

  @override
  String get settingsLegalDescription =>
      'Przeczytaj informacje prawne i noty aplikacji.';

  @override
  String get settingsAppVersionTitle => 'Wersja aplikacji';

  @override
  String settingsAppVersionDescription(String version, String build) {
    return 'Wersja: $version\nBuild: $build';
  }

  @override
  String get settingsMadeWithFlutter => 'Stworzone z Flutterem';

  @override
  String get settingsFollowRavenPlayer => 'Obserwuj Raven Player:';

  @override
  String get settingsOpenLinkTitle => 'Otworzyć link?';

  @override
  String get settingsCouldNotOpenLink => 'Nie udało się otworzyć linku';

  @override
  String playerLoadingError(String error) {
    return 'Błąd wczytywania audiobooka: $error';
  }

  @override
  String get playerAdjustPlaybackSpeed => 'Dostosuj prędkość odtwarzania';

  @override
  String get playerAdjustSleepTimer => 'Dostosuj timer snu';

  @override
  String get playerSet => 'Ustaw';

  @override
  String get playerLockedMessage =>
      'Odtwarzacz jest zablokowany.\nPrzytrzymaj, aby odblokować.';

  @override
  String get playerDropdownLocked =>
      'Lista rozdziałów jest zablokowana.\nMożesz ją włączyć na pasku narzędzi.';

  @override
  String get playerSliderLocked =>
      'Suwak jest zablokowany.\nMożesz go włączyć na pasku narzędzi.';

  @override
  String chapterProgress(int current, int total) {
    return 'Rozdział $current z $total';
  }

  @override
  String readingProgress(String read, String total, String percent) {
    return 'Przeczytano $read z $total ($percent%)';
  }

  @override
  String leftTime(String duration) {
    return 'Pozostało: $duration';
  }
}
