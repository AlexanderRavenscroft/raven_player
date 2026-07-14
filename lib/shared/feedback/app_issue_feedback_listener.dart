import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/feedback/app_issue_provider.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class AppIssueFeedbackListener extends ConsumerStatefulWidget {
  final AppIssue? initialIssue;
  final Widget child;

  const AppIssueFeedbackListener({
    super.key,
    this.initialIssue,
    required this.child,
  });

  @override
  ConsumerState<AppIssueFeedbackListener> createState() =>
      _AppIssueFeedbackListenerState();
}

class _AppIssueFeedbackListenerState
    extends ConsumerState<AppIssueFeedbackListener> {
  @override
  void initState() {
    super.initState();

    final initialIssue = widget.initialIssue;
    if (initialIssue == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appIssueProvider.notifier).report(initialIssue);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppIssue?>(appIssueProvider, (previous, next) {
      if (next == null) return;

      final message = switch (next.type) {
        AppIssueType.playbackSource =>
          context.l10n.playbackSourceErrorMessage,
        AppIssueType.playbackUnknown =>
          context.l10n.playbackUnknownErrorMessage,
        AppIssueType.audiobookUnavailable =>
          context.l10n.libraryAudiobookUnavailable,
      };

      AppSnackBar.showSnackBar(
        context,
        message,
        type: SnackBarType.error,
        durationSec: 4,
        replacePrevious: true,
      );

      ref.read(appIssueProvider.notifier).clear();
    });

    return widget.child;
  }
}
