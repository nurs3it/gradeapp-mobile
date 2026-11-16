import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/user.dart';
import '../common/pulse.dart';
import '../notifications/push.dart';

class _Signal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// One «tap the active tab» signal per tab position (one shell is visible at
/// a time, so positions can be shared).
final _reselect = List.generate(4, (_) => _Signal());

/// The tab bodies: an indexed stack (tab stacks survive switching) with a
/// [TabScope] per tab for scroll-to-top.
class ShellBranches extends StatelessWidget {
  const ShellBranches({super.key, required this.shell, required this.children});
  final StatefulNavigationShell shell;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => IndexedStack(
    index: shell.currentIndex,
    children: [
      for (var i = 0; i < children.length; i++)
        TabScope(
          reselect: _reselect[i],
          child: TickerMode(enabled: i == shell.currentIndex, child: children[i]),
        ),
    ],
  );
}

/// Role shell (C1): floating capsule tab bar over the tab content. Profile
/// lives behind the avatar, not in a tab.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell, required this.role});
  final StatefulNavigationShell shell;
  final AppRole role;

  static bool _askScheduled = false;

  /// C3: parents and teachers are offered notifications shortly after the
  /// shell first shows (students — after their first check-in).
  void _offerPush(BuildContext context, WidgetRef ref) {
    if (_askScheduled || role == AppRole.student) return;
    _askScheduled = true;
    final push = ref.read(pushProvider);
    final prefs = ref.read(prefsProvider);
    final l = context.l10n;
    final reason = role == AppRole.parent ? l.pushWhyParent : l.pushWhyTeacher;
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (context.mounted) unawaited(askForPushOnce(context, push, prefs, reason));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _offerPush(context, ref);
    final l = context.l10n;
    final rejected = ref.watch(outboxStateProvider.select((s) => s.value?.rejected.length ?? 0));
    final inbox = ref.watch(pulseProvider.select((p) => p.inbox + p.notificationsUnread));
    GTabItem item(IconData icon, String label, [int badge = 0]) => GTabItem(
      icon: icon,
      label: label,
      badge: badge,
      semanticLabel: badge > 0 ? l.tabWithBadge(label, badge) : label,
    );
    final items = switch (role) {
      AppRole.student => [
        item(GIcons.today, l.tabToday),
        item(GIcons.week, l.tabWeek),
        item(GIcons.grades, l.tabGrades),
        item(GIcons.tasks, l.tabTasks),
      ],
      AppRole.parent => [
        item(GIcons.today, l.tabToday),
        item(GIcons.grades, l.tabGrades),
        item(GIcons.week, l.tabWeek),
        item(GIcons.family, l.tabFamily),
      ],
      AppRole.teacher => [
        item(GIcons.today, l.tabToday),
        item(GIcons.week, l.tabWeek),
        item(GIcons.inbox, l.tabInbox, inbox + rejected),
      ],
    };
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: context.c.canvas,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: shell),
          if (!keyboard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GTabBar(
                items: items,
                index: shell.currentIndex,
                onTap: (i) {
                  if (i == shell.currentIndex) _reselect[i].fire();
                  shell.goBranch(i, initialLocation: i == shell.currentIndex);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(body: GSplash());
}
