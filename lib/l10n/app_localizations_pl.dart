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
      'Wybierz folder z podfolderami, z których każdy zawiera pliki audio jednego audiobooka.';

  @override
  String get onboardingChooseFolder => 'Wybierz folder domyślny';

  @override
  String get onboardingFooter =>
      'Obsługiwane formaty: MP3, M4A, M4B, FLAC i OGG. Możesz później zmienić folder w ustawieniach.';

  @override
  String lottieError(String error) {
    return 'Błąd Lottie: $error';
  }

  @override
  String get libraryTitle => 'Biblioteka';

  @override
  String get libraryCheckingForNew => 'Aktualizowanie biblioteki...';

  @override
  String libraryLoadingError(String error) {
    return 'Błąd wczytywania biblioteki:\n$error';
  }

  @override
  String get libraryAudiobookUnavailable =>
      'Pliki audiobooka nie są już dostępne. Aktualizowanie biblioteki...';

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
  String get settingsHomeFolderTitle => 'Folder z audiobookami';

  @override
  String get settingsNoFolderSelected => 'Nie wybrano folderu';

  @override
  String get settingsInternalStorage => 'Pamięć wewnętrzna';

  @override
  String settingsCurrentFolder(String folder) {
    return 'Obecnie:\n$folder';
  }

  @override
  String get settingsChangeFolderTitle => 'Zmienić folder z audiobookami?';

  @override
  String get settingsChangeFolderWarning =>
      'Wybranie innego folderu przebuduje bibliotekę i zresetuje postęp wszystkich audiobooków.';

  @override
  String get settingsChangeFolderConfirm => 'Wybierz folder';

  @override
  String get settingsStopPlaybackAndChangeFolderTitle =>
      'Zatrzymać odtwarzanie i zmienić folder?';

  @override
  String get settingsStopPlaybackAndChangeFolderWarning =>
      'Bieżący audiobook zostanie zatrzymany, a jego pozycja zapisana. Wybranie innego folderu przebuduje bibliotekę i zresetuje postęp każdego audiobooka.';

  @override
  String get settingsStopPlaybackToChooseFolderTitle =>
      'Zatrzymać odtwarzanie przed wyborem folderu?';

  @override
  String get settingsStopPlaybackToChooseFolderWarning =>
      'Bieżący audiobook zostanie zatrzymany, a jego pozycja zapisana przed otwarciem wyboru folderu.';

  @override
  String get settingsStopPlaybackAndChooseFolderConfirm =>
      'Zatrzymaj i wybierz folder';

  @override
  String get settingsThemeTitle => 'Motyw';

  @override
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsLanguageTitle => 'Język';

  @override
  String get settingsShowRemainingTimeTitle => 'Pozostały czas';

  @override
  String get settingsShowRemainingTimeDescription =>
      'Pokazuj czas do końca rozdziału.';

  @override
  String get settingsShowBufferedProgressTitle => 'Buforowanie';

  @override
  String get settingsShowBufferedProgressDescription =>
      'Pokaż wczytaną część na pasku postępu.';

  @override
  String get settingsBackArrowTitle => 'Przycisk wstecz';

  @override
  String get settingsBackArrowDescription =>
      'Wracaj do biblioteki zamiast minimalizować.';

  @override
  String get settingsCreatorTitle => 'Twórca';

  @override
  String get settingsCreatorDescription => 'O twórcy aplikacji.';

  @override
  String get settingsCreatorDialogTitle => 'O twórcy';

  @override
  String get settingsLegalTitle => 'Informacje prawne';

  @override
  String get settingsLegalDescription => 'Licencje i noty prawne.';

  @override
  String get settingsAppVersionTitle => 'Wersja aplikacji';

  @override
  String settingsAppVersionDescription(String version, String build) {
    return 'v$version (kompilacja $build)';
  }

  @override
  String get settingsFollowRavenPlayer => 'Projekt i wsparcie';

  @override
  String get settingsOpenLinkTitle => 'Otworzyć link?';

  @override
  String get settingsCouldNotOpenLink => 'Nie udało się otworzyć linku';

  @override
  String get tooltipRefreshLibrary => 'Odśwież bibliotekę';

  @override
  String get tooltipOpenSettings => 'Otwórz ustawienia';

  @override
  String get tooltipBack => 'Wstecz';

  @override
  String get tooltipOpenGitHub => 'Otwórz GitHub';

  @override
  String get tooltipSendEmail => 'Wyślij e-mail';

  @override
  String get tooltipOpenKoFi => 'Otwórz Ko-fi';

  @override
  String playerLoadingError(String error) {
    return 'Błąd wczytywania audiobooka: $error';
  }

  @override
  String get playerAdjustPlaybackSpeed => 'Dostosuj prędkość odtwarzania';

  @override
  String get playerAdjustSleepTimer => 'Dostosuj timer snu';

  @override
  String get playerLockedMessage =>
      'Sterowanie jest zablokowane.\nPrzytrzymaj przycisk blokady.';

  @override
  String chapterProgress(int current, int total) {
    return 'Rozdział $current z $total';
  }

  @override
  String get noChaptersFound => 'Nie znaleziono rozdziałów';

  @override
  String readingProgress(String read, String total, String percent) {
    return 'Przeczytano $read z $total ($percent%)';
  }

  @override
  String leftTime(String duration) {
    return 'Pozostało: $duration';
  }

  @override
  String get playbackSourceErrorMessage =>
      'Odtwarzanie przerwane w tym miejscu. Plik może być uszkodzony. Spróbuj przewinąć dalej.';

  @override
  String get playbackUnknownErrorMessage =>
      'Błąd odtwarzania. Spróbuj ponownie.';
}
