import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/core/saf/saf.dart';
import 'package:raven_player/features/library/application/audiobook_availability_checker.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/onboarding/application/startup_audiobook_resolver.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/chapter.dart';
import 'package:raven_player/models/user_settings.dart';

const _authority = 'com.android.externalstorage.documents';
const _homeUri = 'content://$_authority/tree/primary%3AAudiobooks';
const _bookUri =
    'content://$_authority/tree/primary%3AAudiobooks/'
    'document/primary%3AAudiobooks%2FBook%201';
const _chapterUri =
    'content://$_authority/tree/primary%3AAudiobooks/'
    'document/primary%3AAudiobooks%2FBook%201%2FChapter%201.mp3';
const _otherBookUri =
    'content://$_authority/tree/primary%3AOther/'
    'document/primary%3AOther%2FBook%201';

void main() {
  group('StartupAudiobookResolver', () {
    test('disabled restoration retains id and skips resolution', () async {
      final settingsRepository = FakeUserSettingsRepository();
      final audiobookRepository = FakeAudiobookRepository(_book());
      final availabilityChecker = FakeAudiobookAvailabilityChecker();
      final resolver = _resolver(
        settingsRepository,
        audiobookRepository,
        availabilityChecker,
      );
      const settings = UserSettings(
        homeFolderUri: 'content://library',
        restoreLastAudiobookOnLaunch: false,
        lastOpenedAudiobookId: 'content://library/book-1',
      );

      final result = await resolver.resolve(settings);

      expect(result.audiobook, isNull);
      expect(result.issue, isNull);
      expect(
        result.settings.lastOpenedAudiobookId,
        settings.lastOpenedAudiobookId,
      );
      expect(audiobookRepository.loadCount, 0);
      expect(availabilityChecker.checkCount, 0);
      expect(settingsRepository.saved, isNull);
    });

    test(
      'returns an available audiobook from the current home folder',
      () async {
        final book = _book();
        final settingsRepository = FakeUserSettingsRepository();
        final audiobookRepository = FakeAudiobookRepository(book);
        final availabilityChecker = FakeAudiobookAvailabilityChecker();
        final resolver = _resolver(
          settingsRepository,
          audiobookRepository,
          availabilityChecker,
        );

        final result = await resolver.resolve(_settings());

        expect(result.audiobook, same(book));
        expect(result.issue, isNull);
        expect(result.settings.lastOpenedAudiobookId, book.id);
        expect(audiobookRepository.loadedId, book.id);
        expect(availabilityChecker.checkCount, 1);
        expect(settingsRepository.saved, isNull);
      },
    );

    test('clears an id that is missing from the cached library', () async {
      final settingsRepository = FakeUserSettingsRepository();
      final resolver = _resolver(
        settingsRepository,
        FakeAudiobookRepository(null),
        FakeAudiobookAvailabilityChecker(),
      );

      final result = await resolver.resolve(_settings());

      _expectCleared(result, settingsRepository);
    });

    test('clears an audiobook without chapters', () async {
      final settingsRepository = FakeUserSettingsRepository();
      final resolver = _resolver(
        settingsRepository,
        FakeAudiobookRepository(_book(chapters: const [])),
        AudiobookAvailabilityChecker(),
      );

      final result = await resolver.resolve(_settings());

      _expectCleared(result, settingsRepository);
    });

    test('clears an audiobook outside the current home folder', () async {
      final settingsRepository = FakeUserSettingsRepository();
      final resolver = _resolver(
        settingsRepository,
        FakeAudiobookRepository(
          _book(
            id: _otherBookUri,
            folderUri: _otherBookUri,
          ),
        ),
        FakeAudiobookAvailabilityChecker(),
      );

      final result = await resolver.resolve(
        _settings(lastOpenedAudiobookId: _otherBookUri),
      );

      _expectCleared(result, settingsRepository);
    });

    test('rejects an audiobook from a tree with a matching text prefix', () async {
      const selectedHome =
          'content://$_authority/tree/primary%3AAudio';
      const similarBookUri =
          'content://$_authority/tree/primary%3AAudiobooks/'
          'document/primary%3AAudiobooks%2FBook';
      final settingsRepository = FakeUserSettingsRepository();
      final resolver = _resolver(
        settingsRepository,
        FakeAudiobookRepository(
          _book(id: similarBookUri, folderUri: similarBookUri),
        ),
        FakeAudiobookAvailabilityChecker(),
      );

      final result = await resolver.resolve(
        const UserSettings(
          homeFolderUri: selectedHome,
          lastOpenedAudiobookId: similarBookUri,
        ),
      );

      _expectCleared(result, settingsRepository);
    });

    test('clears an audiobook that is no longer available', () async {
      final settingsRepository = FakeUserSettingsRepository();
      final availabilityChecker = FakeAudiobookAvailabilityChecker(
        error: const AudiobookUnavailableException(
          status: SafAvailabilityStatus.missing,
        ),
      );
      final resolver = _resolver(
        settingsRepository,
        FakeAudiobookRepository(_book()),
        availabilityChecker,
      );

      final result = await resolver.resolve(_settings());

      _expectCleared(result, settingsRepository);
      expect(availabilityChecker.checkCount, 1);
    });
  });
}

StartupAudiobookResolver _resolver(
  UserSettingsRepository settingsRepository,
  AudiobookRepository audiobookRepository,
  AudiobookAvailabilityChecker availabilityChecker,
) {
  return StartupAudiobookResolver(
    settingsRepository: settingsRepository,
    audiobookRepository: audiobookRepository,
    availabilityChecker: availabilityChecker,
  );
}

UserSettings _settings({
  String lastOpenedAudiobookId = _bookUri,
}) {
  return UserSettings(
    homeFolderUri: _homeUri,
    lastOpenedAudiobookId: lastOpenedAudiobookId,
  );
}

Audiobook _book({
  String id = _bookUri,
  String folderUri = _bookUri,
  List<Chapter> chapters = const [
    Chapter(name: 'Chapter 1', uri: _chapterUri),
  ],
}) {
  return Audiobook(
    id: id,
    title: 'Book One',
    folderUri: folderUri,
    chapters: chapters,
  );
}

void _expectCleared(
  StartupAudiobookResolution result,
  FakeUserSettingsRepository settingsRepository,
) {
  expect(result.audiobook, isNull);
  expect(result.issue, AppIssue.audiobookUnavailable);
  expect(result.settings.lastOpenedAudiobookId, isNull);
  expect(settingsRepository.saved, isNotNull);
  expect(settingsRepository.saved!.lastOpenedAudiobookId, isNull);
}

class FakeUserSettingsRepository extends UserSettingsRepository {
  UserSettings? saved;

  @override
  Future<void> save(UserSettings settings) async {
    saved = settings;
  }
}

class FakeAudiobookRepository extends AudiobookRepository {
  final Audiobook? audiobook;
  int loadCount = 0;
  String? loadedId;

  FakeAudiobookRepository(this.audiobook);

  @override
  Future<Audiobook?> getById(String id) async {
    loadCount++;
    loadedId = id;
    return audiobook;
  }
}

class FakeAudiobookAvailabilityChecker extends AudiobookAvailabilityChecker {
  final Object? error;
  int checkCount = 0;

  FakeAudiobookAvailabilityChecker({this.error});

  @override
  Future<void> ensureAvailable(Audiobook book) async {
    checkCount++;
    final currentError = error;
    if (currentError != null) throw currentError;
  }
}
