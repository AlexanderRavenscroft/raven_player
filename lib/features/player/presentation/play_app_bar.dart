import 'package:flutter/material.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/features/player/presentation/audiobook_title_display.dart';
import 'package:raven_player/features/settings/presentation/settings_page.dart';
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
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        AppBarButton(
          icon: AppIcons.settings,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => SettingsPage()));
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
