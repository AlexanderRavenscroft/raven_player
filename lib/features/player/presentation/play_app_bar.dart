import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/features/player/presentation/audiobook_title_display.dart';
import 'package:raven_player/features/settings/presentation/settings_page.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/models/audiobook.dart';
import 'package:raven_player/shared/buttons/app_bar_button.dart';

class PlayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Audiobook book;

  const PlayAppBar({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      centerTitle: true,
      title: AudiobookTitleDisplay(text: book.title),
      leading: AppBarButton(
        icon: AppIcons.back,
        tooltip: context.l10n.tooltipBack,
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        AppBarButton(
          icon: AppIcons.settings,
          tooltip: context.l10n.tooltipOpenSettings,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
