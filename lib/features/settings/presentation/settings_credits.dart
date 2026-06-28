import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/app_confirm_dialog.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCredits extends StatelessWidget {
  //TODO: ADD ACUTAL LINKS & DATA
  static final Uri _githubUrl = Uri.https(
    'github.com',
    '/your-profile-or-repo',
  );
  static final Uri _emailUrl = Uri(
    scheme: 'mailto',
    path: 'ravenplayer.dev@gmail.com',
    queryParameters: {'subject': 'Raven Player'},
  );
  static final Uri _koFiUrl = Uri.https('ko-fi.com', '/your-profile');

  const SettingsCredits({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.settingsFollowRavenPlayer,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: context.l10n.tooltipOpenGitHub,
                  icon: const FaIcon(
                    FontAwesomeIcons.github,
                    size: AppIconSizes.large,
                  ),
                  onPressed: () => _confirmAndOpen(context, _githubUrl),
                ),
                IconButton(
                  tooltip: context.l10n.tooltipSendEmail,
                  icon: const FaIcon(
                    FontAwesomeIcons.envelope,
                    size: AppIconSizes.large,
                  ),
                  onPressed: () => _confirmAndOpen(context, _emailUrl),
                ),
                IconButton(
                  tooltip: context.l10n.tooltipOpenKoFi,
                  icon: const FaIcon(
                    FontAwesomeIcons.koFi,
                    size: AppIconSizes.large,
                  ),
                  onPressed: () => _confirmAndOpen(context, _koFiUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalLink(BuildContext context, Uri uri) async {
    if (uri.scheme != 'https' && uri.scheme != 'mailto') {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      final message = uri.scheme == 'mailto'
          ? context.l10n.settingsCouldNotOpenEmail
          : context.l10n.settingsCouldNotOpenLink;

      AppSnackBar.showSnackBar(context, message, type: SnackBarType.error);
    }
  }

  Future<void> _confirmAndOpen(BuildContext context, Uri uri) async {
    final isEmail = uri.scheme == 'mailto';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppConfirmDialog(
        title: isEmail
            ? dialogContext.l10n.settingsOpenEmailTitle
            : dialogContext.l10n.settingsOpenLinkTitle,
        content: isEmail ? uri.path : uri.host,
        onAccept: () => _openExternalLink(context, uri),
        acceptText: dialogContext.l10n.dialogOpen,
      ),
    );
  }
}
