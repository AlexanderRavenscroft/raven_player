import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raven_player/core/theme/app_spacing.dart';
import 'package:raven_player/features/library/application/library_filter.dart';
import 'package:raven_player/l10n/app_localizations_x.dart';

class LibraryFilterToggle extends ConsumerWidget {
  static const double _height = 48;
  static const double _indicatorWeight = 4;

  const LibraryFilterToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialIndex =
        ref.watch(libraryFilterProvider) == LibraryFilter.reading ? 0 : 1;

    return SizedBox(
      width: double.infinity,
      height: _height,
      child: DefaultTabController(
        length: 2,
        initialIndex: initialIndex,
        child: TabBar(
          labelColor: Theme.of(context).colorScheme.onSurface,
          labelStyle: Theme.of(context).textTheme.labelLarge,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
          dividerHeight: 0,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorWeight: _indicatorWeight,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: -AppSpacing.xl,
          ),
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
