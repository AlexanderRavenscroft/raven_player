import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/dialogs/app_confirm_dialog.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCredits extends StatelessWidget {
  const SettingsCredits({super.key});

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

  Future<void> _openExternalLink(BuildContext context, Uri uri) async {
    if (uri.scheme != 'https') {
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      AppSnackBar.showSnackBar(
        context,
        context.l10n.settingsCouldNotOpenLink,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _confirmAndOpen(BuildContext context, Uri uri) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppConfirmDialog(
        title: dialogContext.l10n.settingsOpenLinkTitle,
        content: uri.host,
        onAccept: () => _openExternalLink(context, uri),
        acceptText: dialogContext.l10n.dialogOpen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.16,
      child: Column(
        spacing: AppSpacing.xs,
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
              //TODO: Fix tooltrips & set translations
              IconButton(
                tooltip: 'GitHub',
                icon: const FaIcon(
                  FontAwesomeIcons.github,
                  size: AppIconSizes.large,
                ),
                onPressed: () => _confirmAndOpen(context, _githubUrl),
              ),
              IconButton(
                tooltip: 'Email',
                icon: const FaIcon(
                  FontAwesomeIcons.envelope,
                  size: AppIconSizes.large,
                ),
                onPressed: () => _confirmAndOpen(context, _emailUrl),
              ),
              IconButton(
                tooltip: 'Ko-fi',
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
    );
  }
}
