import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_icons.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/library/application/library_notifier.dart';
import 'package:raven_player/features/settings/presentation/settings_page.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';
import 'package:raven_player/shared/buttons/app_bar_button.dart';
import 'package:raven_player/shared/others/base_app_bar.dart';
import 'package:raven_player/shared/feedback/app_snack_bar.dart';

class LibraryAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const LibraryAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BaseAppBar(
      title: Row(
        children: [
          Icon(
            AppIcons.library,
            color: Theme.of(context).colorScheme.onSurface,
            size: AppIconSizes.medium,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.l10n.libraryTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      actions: [
        AppBarButton(
          icon: AppIcons.refresh,
          tooltip: context.l10n.tooltipRefreshLibrary,
          onPressed: () async {
            AppSnackBar.showSnackBar(
              context,
              context.l10n.libraryCheckingForNew,
              durationSec: 1,
              replacePrevious: true,
            );
            await ref.read(libraryProvider.notifier).rescan();
          },
        ),
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
