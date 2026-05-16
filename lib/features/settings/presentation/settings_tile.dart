import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_typography.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: false,
          title: Text(
            title,
            style: context.appText.labelLarge!.withStyle(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            description,
            style: context.appText.labelMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          leading: Icon(
            icon,
            size: context.titleLarge,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          trailing: trailing,
        ),
        Divider(
          color: Theme.of(context).colorScheme.surfaceContainer,
          thickness: 1,
          height: MediaQuery.of(context).size.height * 0.012,
        ),
      ],
    );
  }
}
