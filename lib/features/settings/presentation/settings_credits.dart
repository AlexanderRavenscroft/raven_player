import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/pop_ups/app_confirm_dialog.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCredits extends StatelessWidget {
  const SettingsCredits({super.key});

  static final Uri _flutterUrl = Uri.https('flutter.dev');
  static final Uri _githubUrl = Uri.https(
    'github.com',
    '/your-profile-or-repo',
  );

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
      height: MediaQuery.of(context).size.height * 0.18,
      child: Column(
        spacing: AppSpacing.xs,
        children: [
          Text(
            context.l10n.settingsMadeWithFlutter,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
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
                tooltip: 'Flutter',
                icon: FlutterLogo(size: AppIconSizes.large),
                onPressed: () => _confirmAndOpen(context, _flutterUrl),
              ),
              IconButton(
                tooltip: 'GitHub',
                icon: FaIcon(FontAwesomeIcons.github, size: AppIconSizes.large),
                onPressed: () => _confirmAndOpen(context, _githubUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
