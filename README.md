<a id="readme-top"></a>

<div align="center">
	<a href="https://github.com/AlexanderRavenscroft/raven_player">
		<img src="assets/launcher/app_icon.png" alt="Raven Player logo" width="80" height="80">
	</a>

  <h3 align="center">Raven Player</h3>

  <p align="center">
    An offline audiobook player for Android, built with Flutter!
    <br />
    <a href="https://github.com/AlexanderRavenscroft/raven_player/issues/new?title=%5BBug%5D%20">Report Bug</a>
    &middot;
    <a href="https://github.com/AlexanderRavenscroft/raven_player/issues/new?title=%5BFeature%5D%20">Request Feature</a>
  </p>
</div>

<details>
	<summary>Table of Contents</summary>
	<ol>
		<li><a href="#about-the-project">About the Project</a></li>
		<li><a href="#built-with">Built With</a></li>
		<li><a href="#getting-started">Getting Started</a></li>
		<li><a href="#usage">Usage</a></li>
		<li><a href="#how-the-project-works">How the Project Works</a></li>
		<li><a href="#next-steps">Next Steps</a></li>
		<li><a href="#contributing">Contributing</a></li>
		<li><a href="#license">License</a></li>
		<li><a href="#contact">Contact</a></li>
		<li><a href="#acknowledgments">Acknowledgments</a></li>
	</ol>
</details>

## About the Project

Raven Player is an Android audiobook player for collections stored on your device. It organizes books from a folder you choose, keeps track of your listening progress, and supports playback while the app is in the background.

I started Raven Player because I couldn't find an offline audiobook player that fit my needs. I wanted to choose a folder, listen to my own collection, and return to a book without losing my place. Building it is also how I learn Flutter through practical problems: managing Android folder access, keeping background playback connected to media controls, and saving progress as the listening session changes.

- **Folder-based library** - Select a folder through Android's folder picker and scan its audiobook subfolders. Audio files are ordered naturally, so chapter 2 comes before chapter 10.
- **Book details and organization** - Read author information and embedded cover art when available, rename books in the library, and filter by reading status.
- **Saved listening progress** - Keep a separate chapter and playback position for each book, with an option to reopen the last audiobook when the app starts.
- **Background playback** - Continue listening with notification and lock screen media controls.
- **Playback controls** - Adjust speed from 0.5x to 3.0x, skip silence, seek within a chapter, and lock player controls to prevent accidental changes.
- **Sleep timer** - Set a countdown that pauses playback when it expires.
- **Personalization** - Choose light, dark, or system themes and use the app in English or Polish.

The code is organized by feature, with Riverpod managing application state and Hive CE storing library records, settings, and progress locally. Native Android code handles folder access and audio metadata extraction through Flutter platform channels.

You supply your own audio files. Raven Player does not provide or download audiobooks; your library, settings, and progress stay on your device.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Built With

- [![Flutter][Flutter-badge]][Flutter-url] and [![Dart][Dart-badge]][Dart-url] - application framework and language.
- [![Riverpod][Riverpod-badge]][Riverpod-url] - state management.
- [![Hive CE][Hive-badge]][Hive-url] - local persistence.
- [![just_audio][JustAudio-badge]][JustAudio-url] - audio playback.
- [![audio_service][AudioService-badge]][AudioService-url] - background audio and media controls.
- [![Android SAF][Android-badge]][Android-url] - access to user-selected folders.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/).
- [Flutter SDK](https://docs.flutter.dev/install) with bundled Dart satisfying `>=3.11.5 <4.0.0`.
- Android SDK and development tools, typically installed through [Android Studio](https://developer.android.com/studio).
- An Android emulator or a connected Android device with USB debugging enabled.

Android is the currently supported target.

### Installation

Clone the repository, install dependencies, generate the required files, and run the app:

```sh
git clone https://github.com/AlexanderRavenscroft/raven_player.git
cd raven_player
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

If Flutter prompts you to choose a device, select your Android device or emulator.

### Generated Files

Hive adapters (`*.g.dart`) are excluded from Git. Generate them after cloning and whenever you change Hive models or code generation annotations:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Generate adapters rather than editing them manually.

After changing localization files (`lib/l10n/*.arb`), regenerate translations:

```sh
flutter gen-l10n
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

I recommend keeping your collection in a folder named `Audiobooks`. You can choose any folder that Android allows Raven Player to access through the folder picker; the folder name is up to you.

Store each audiobook in its own direct subfolder of your main audiobook folder, even when a book consists of only one file. Put its audio files directly inside that subfolder:

```text
Audiobooks/
├── First Book/
│   ├── 01.mp3
│   └── 02.mp3
└── Second Book/
    ├── Chapter 1.m4b
    └── Chapter 2.m4b
```

The scanner recognizes MP3, M4A, M4B, FLAC, and OGG files. Each audio file is treated as one chapter.

1. Open Raven Player and tap **Choose default folder**. Select `Audiobooks` or another accessible folder containing your audiobook subfolders through Android's folder picker and grant access. This becomes your default audiobook folder.
2. Tap a book in the library to open it. Use the playback button, seek bar, skip controls, and chapter selector to listen. Your position is saved for later.
3. Use the speed control to choose a playback speed; once configured, tap it to toggle between that speed and normal playback. Long-press it to adjust the selected speed.
4. Tap the sleep timer to enable or disable it. Long-press it to set the duration.
5. Swipe a library entry to reveal actions for renaming the book or changing its reading status.
6. After adding books or audio files, tap the library's refresh button to rescan the folder.

You can change the audiobook folder in Settings. Choosing a different folder rebuilds the library and resets progress for every book.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## How the Project Works

### Project Structure

Features are grouped into `onboarding`, `library`, `player`, and `settings`. Within each feature, `application` handles state and operations, while `presentation` contains screens and widgets.

| Location                                                     | Responsibility                                                                                                 |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------- |
| [lib/main.dart](lib/main.dart)                               | Initialize storage and background audio, load settings, and resolve the last audiobook before starting the UI. |
| [lib/features/](lib/features/)                               | Feature state, repositories, services, and UI.                                                                 |
| [lib/core/](lib/core/)                                       | Shared infrastructure: Hive storage, Android folder access, themes, localization, and error feedback.          |
| [lib/models/](lib/models/)                                   | Audiobook, chapter, and settings models with Hive persistence annotations.                                     |
| [lib/shared/](lib/shared/)                                   | Reusable dialogs, app bars, loading indicators, and other widgets.                                             |
| [lib/l10n/](lib/l10n/)                                       | English and Polish ARB files and generated translations.                                                       |
| [android/app/src/main/kotlin/](android/app/src/main/kotlin/) | Native folder access and audio metadata extraction.                                                            |
| [test/](test/)                                               | Focused tests for application logic, models, storage access, and widgets.                                      |

### Core Mechanics

1. **Folder access and scanning.** Android's Storage Access Framework grants access to a selected folder. Dart calls the native implementation through the `raven/saf` platform channel and works with document URIs. [LibraryScanner](lib/features/library/application/library_scanner.dart) treats each direct subfolder as a book and naturally sorts its audio files into chapters.
2. **Library updates.** [LibraryNotifier](lib/features/library/application/library_notifier.dart) coordinates scanning, persistence, and metadata extraction. `AudiobookRepository` merges results using folder URIs as book identifiers, preserving renamed titles, reading status, and stored progress for existing books. Author and cover metadata come from the first audio file; missing chapter durations are fetched when a book is opened.
3. **Playback and progress.** [PlayerNotifier](lib/features/player/application/player_notifier.dart) loads chapter sources with the saved chapter index and position. [AppAudioHandler](lib/features/player/application/raven_audio_handler.dart) connects `just_audio` playback to `audio_service` media controls. Progress is saved periodically, after seeks and chapter changes, and before switching books. Previous stream subscriptions are cancelled when replacing the playback session.
4. **State and storage.** Widgets observe Riverpod providers and call notifier methods for user actions. Repositories write audiobook records and settings to separate Hive boxes. At startup, the app checks whether the last audiobook is still accessible before reopening it.

### Where to Start

- For library scanning or playback behavior, start in the relevant feature's `application` folder; for controls and layouts, start in `presentation`.
- For a persisted setting, update its model, repository/notifier, and settings UI. Keep existing Hive field numbers and add a new number for the new field, then regenerate adapters.
- For new UI text, update both ARB files and run `flutter gen-l10n`.
- Add focused tests under the matching feature in `test/` when changing behavior.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Next Steps

The current goal is to prepare Raven Player for publication on Google Play soon.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contributing

Bug reports, feature suggestions, and pull requests are welcome. Open an [issue](https://github.com/AlexanderRavenscroft/raven_player/issues) to report a problem or suggest an improvement.

To contribute code:

1. Fork the repository and create a branch for your change.
2. Follow the setup instructions above and make your changes.
3. Keep changes focused and follow the surrounding code's structure and style.
4. Add or update relevant tests for meaningful behavior changes and run `flutter test`.
5. Push your branch to your fork and open a pull request describing the change and how you tested it.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

[Alexander Ravenscroft](https://github.com/AlexanderRavenscroft) - [alex.ravenscroft.dev+ravenplayer@gmail.com](mailto:alex.ravenscroft.dev+ravenplayer@gmail.com)

Project: [Raven Player](https://github.com/AlexanderRavenscroft/raven_player)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments

- [Inter](https://rsms.me/inter/) - app typography.
- [Font Awesome](https://fontawesome.com/) - icons.
- [Material Symbols](https://fonts.google.com/icons) - icons.
- [file documents searching and find](https://lottiefiles.com/free-animation/file-documents-searching-and-find-5wTuFO2oDz) by Salman - Lottie onboarding animation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[Flutter-badge]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev/
[Dart-badge]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev/
[Riverpod-badge]: https://img.shields.io/badge/Riverpod-1565C0?style=for-the-badge
[Riverpod-url]: https://riverpod.dev/
[Hive-badge]: https://img.shields.io/badge/Hive_CE-FFB300?style=for-the-badge
[Hive-url]: https://pub.dev/packages/hive_ce
[JustAudio-badge]: https://img.shields.io/badge/just__audio-00796B?style=for-the-badge
[JustAudio-url]: https://pub.dev/packages/just_audio
[AudioService-badge]: https://img.shields.io/badge/audio__service-6A1B9A?style=for-the-badge
[AudioService-url]: https://pub.dev/packages/audio_service
[Android-badge]: https://img.shields.io/badge/Android_SAF-3DDC84?style=for-the-badge&logo=android&logoColor=white
[Android-url]: https://developer.android.com/guide/topics/providers/document-provider
