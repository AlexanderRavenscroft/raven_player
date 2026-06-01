import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/others/base_app_bar.dart';
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
            size: AppIconSizes.medium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.settingsTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
