import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/features/player/application/playback_issue_provider.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class PlaybackIssueFeedbackListener extends ConsumerWidget {
  final Widget child;

  const PlaybackIssueFeedbackListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<PlaybackIssue?>(playbackIssueProvider, (previous, next) {
      if (next == null) return;

      final message = switch (next.type) {
        PlaybackIssueType.sourceError =>
          context.l10n.playbackSourceErrorMessage,
        PlaybackIssueType.unknown => context.l10n.playbackUnknownErrorMessage,
      };

      AppSnackBar.showSnackBar(
        context,
        message,
        type: SnackBarType.error,
        durationSec: 4,
        replacePrevious: true,
      );

      ref.read(playbackIssueProvider.notifier).clear();
    });

    return child;
  }
}
