import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers.dart';
import '../l10n/l10n.dart';
import '../ui/ui.dart';

/// Bottom tab bar + per-tab navigation stacks (state kept between tabs).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell, required this.teacher});
  final StatefulNavigationShell shell;
  final bool teacher;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  StreamSubscription<Object?>? _rejected;

  @override
  void initState() {
    super.initState();
    _rejected = ref.read(outboxProvider).rejected.stream.listen((_) {
      if (mounted) showGToast(context, context.l10n.syncRejected, error: true);
    });
  }

  @override
  void dispose() {
    _rejected?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tabs = widget.teacher
        ? [
            (Icons.class_outlined, Icons.class_rounded, l.tabLessons),
            (Icons.person_outline_rounded, Icons.person_rounded, l.tabProfile),
          ]
        : [
            (Icons.wb_sunny_outlined, Icons.wb_sunny_rounded, l.tabToday),
            (Icons.calendar_today_outlined, Icons.calendar_today_rounded, l.tabSchedule),
            (Icons.star_outline_rounded, Icons.star_rounded, l.tabGrades),
            (Icons.task_alt_outlined, Icons.task_alt_rounded, l.tabHomework),
            (Icons.person_outline_rounded, Icons.person_rounded, l.tabProfile),
          ];
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.c.border)),
        ),
        child: NavigationBar(
          selectedIndex: widget.shell.currentIndex,
          onDestinationSelected: (i) {
            unawaited(HapticFeedback.selectionClick());
            // Tapping the active tab pops it to its root, like iOS.
            widget.shell.goBranch(i, initialLocation: i == widget.shell.currentIndex);
          },
          destinations: [
            for (final (icon, active, label) in tabs)
              NavigationDestination(icon: Icon(icon), selectedIcon: Icon(active), label: label),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: BrandLoader()));
}

/// Large-title page scaffold used by every tab: pull-to-refresh, collapsing
/// title, optional header widget under the title.
class GPage extends StatelessWidget {
  const GPage({
    super.key,
    required this.title,
    required this.slivers,
    this.onRefresh,
    this.actions,
    this.subtitle,
    this.header,
  });

  final String title;
  final String? subtitle;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;
  final List<Widget>? actions;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        SliverAppBar.large(title: Text(title), actions: actions, pinned: true),
        if (subtitle != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(GSpace.page, 0, GSpace.page, GSpace.sm),
              child: Text(subtitle!, style: context.t.bodyMedium!.copyWith(color: context.c.mutedForeground)),
            ),
          ),
        if (header != null) SliverToBoxAdapter(child: header),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: GSpace.xxl)),
      ],
    );
    return Scaffold(
      body: onRefresh == null
          ? scroll
          : RefreshIndicator.adaptive(
              onRefresh: () async {
                unawaited(HapticFeedback.lightImpact());
                await onRefresh!();
              },
              child: scroll,
            ),
    );
  }
}

/// Small header action that lets a page jump somewhere.
extension GoX on BuildContext {
  void pushPath(String path) => GoRouter.of(this).push(path);
}
