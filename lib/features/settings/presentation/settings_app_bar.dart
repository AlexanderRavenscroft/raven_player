import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/base_app_bar.dart';
import 'package:raven_player/shared/buttons/app_bar_button.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseAppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.settings,
            color: Theme.of(context).colorScheme.onSurface,
            size: context.bodySmall,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text(context.l10n.settingsTitle, style: context.appText.bodySmall),
        ],
      ),
      leading: AppBarButton(
        icon: AppIcons.back,
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
