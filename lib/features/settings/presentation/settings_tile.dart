import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';

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
        SizedBox(
          height: 86,
          child: ListTile(
            dense: false,
            isThreeLine: true,
            titleAlignment: ListTileTitleAlignment.center,
            // minTileHeight: MediaQuery.of(context).size.height * 0.094,
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: Icon(
              icon,
              size: AppIconSizes.large,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            trailing: trailing,
          ),
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
