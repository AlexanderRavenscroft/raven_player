import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/core/saf/saf_uri_utils.dart';
import 'package:raven_player/features/library/application/audiobook_availability_checker.dart';
import 'package:raven_player/features/library/application/audiobook_repository.dart';
import 'package:raven_player/features/settings/application/settings_repository.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/models/user_settings.dart';
import 'package:raven_player/utils/app_logger.dart';

class StartupAudiobookResolution {
  final UserSettings settings;
  final Audiobook? audiobook;
  final AppIssue? issue;

  const StartupAudiobookResolution({
    required this.settings,
    required this.audiobook,
    this.issue,
  });
}

class StartupAudiobookResolver {
  final UserSettingsRepository _settingsRepository;
  final AudiobookRepository _audiobookRepository;
  final AudiobookAvailabilityChecker _availabilityChecker;

  const StartupAudiobookResolver({
    required UserSettingsRepository settingsRepository,
    required AudiobookRepository audiobookRepository,
    required AudiobookAvailabilityChecker availabilityChecker,
  }) : _settingsRepository = settingsRepository,
       _audiobookRepository = audiobookRepository,
       _availabilityChecker = availabilityChecker;

  Future<StartupAudiobookResolution> resolve(UserSettings settings) async {
    if (!settings.restoreLastAudiobookOnLaunch) {
      return StartupAudiobookResolution(settings: settings, audiobook: null);
    }

    final audiobookId = settings.lastOpenedAudiobookId;
    if (audiobookId == null || audiobookId.isEmpty) {
      return StartupAudiobookResolution(settings: settings, audiobook: null);
    }

    final homeFolderUri = settings.homeFolderUri;
    if (homeFolderUri == null || homeFolderUri.isEmpty) {
      return _clearStaleAudiobook(settings);
    }

    try {
      final audiobook = await _audiobookRepository.getById(audiobookId);

      if (audiobook == null ||
          !isSafDocumentInTree(
            documentUri: audiobook.folderUri,
            treeUri: homeFolderUri,
          )) {
        return await _clearStaleAudiobook(
          settings,
          issue: AppIssue.audiobookUnavailable,
        );
      }

      try {
        await _availabilityChecker.ensureAvailable(audiobook);
      } on AudiobookUnavailableException {
        return await _clearStaleAudiobook(
          settings,
          issue: AppIssue.audiobookUnavailable,
        );
      }

      return StartupAudiobookResolution(
        settings: settings,
        audiobook: audiobook,
      );
    } catch (_) {
      log.e('Failed to resolve the startup audiobook.');
      return StartupAudiobookResolution(settings: settings, audiobook: null);
    }
  }

  Future<StartupAudiobookResolution> _clearStaleAudiobook(
    UserSettings settings, {
    AppIssue? issue,
  }) async {
    final updated = settings.copyWith(lastOpenedAudiobookId: null);

    try {
      await _settingsRepository.save(updated);
    } catch (_) {
      log.e('Failed to clear the stale startup audiobook.');
    }

    return StartupAudiobookResolution(
      settings: updated,
      audiobook: null,
      issue: issue,
    );
  }
}
