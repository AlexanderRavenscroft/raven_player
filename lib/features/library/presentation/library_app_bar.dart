import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/settings/presentation/settings_page.dart';
import 'package:raven_player/shared/base_app_bar.dart';
import 'package:raven_player/shared/pop_ups/app_snack_bar.dart';
import 'package:raven_player/shared/buttons/app_bar_button.dart';

class LibraryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseAppBar(
      title: Row(
        children: [
          Icon(
            Icons.library_books,
            color: Theme.of(context).colorScheme.onSurface,
            size: context.bodySmall,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Text('Library', style: context.appText.bodySmall),
        ],
      ),
      actions: [
        AppBarButton(
          icon: Icons.refresh_outlined,
          onPressed: () async {
            AppSnackBar.showSnackBar(
              context,
              'Checking for new audiobooks...',
              durationSec: 1,
              replacePrevious: true,
            );
            await ref.read(libraryProvider.notifier).rescan();
          },
        ),
        AppBarButton(
          icon: Icons.settings,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
