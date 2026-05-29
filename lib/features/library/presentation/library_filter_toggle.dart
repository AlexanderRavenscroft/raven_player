import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_typography.dart';
import 'package:raven_player/features/library/application/library_filter.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class LibraryFilterToggle extends ConsumerWidget {
  const LibraryFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialIndex =
        ref.watch(libraryFilterProvider) == LibraryFilter.reading ? 0 : 1;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.05,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: TabBar(
          labelColor: Theme.of(context).colorScheme.onSurface,
          labelStyle: context.appText.labelLarge,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          unselectedLabelStyle: context.appText.labelLarge,
          dividerHeight: 0,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: MediaQuery.of(context).size.height * 0.005,
          indicatorSize: TabBarIndicatorSize.label,
          //TODO: Think about indicator size, label or little larger than label but smaller than tab
          tabs: [
            Tab(text: context.l10n.libraryReading),
            Tab(text: context.l10n.libraryRead),
          ],
          onTap: (index) {
            ref
                .read(libraryFilterProvider.notifier)
                .setFilter(
                  index == 0 ? LibraryFilter.reading : LibraryFilter.read,
                );
          },
        ),
      ),
    );
  }
}
