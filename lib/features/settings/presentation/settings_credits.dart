import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/shared/pop_ups/app_confirm_dialog.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }

  Future<void> _confirmAndOpen(BuildContext context, Uri uri) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AppConfirmDialog(
        title: 'Open link?',
        content: uri.host,
        onAccept: () => _openExternalLink(context, uri),
        acceptText: 'Open',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.18,
      child: Column(
        spacing: MediaQuery.of(context).size.height * 0.006,
        children: [
          Text(
            'Made with Flutter',
            style: context.appText.labelMedium!.withStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'Follow Raven Player:',
            style: context.appText.labelMedium!.withStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: 'Flutter',
                icon: FlutterLogo(size: context.bodyLarge),
                onPressed: () => _confirmAndOpen(context, _flutterUrl),
              ),
              IconButton(
                tooltip: 'GitHub',
                icon: Icon(Icons.code, size: context.bodyLarge),
                onPressed: () => _confirmAndOpen(context, _githubUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
