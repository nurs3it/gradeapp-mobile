import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/settings.dart';
import '../../app/shell.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../learner/learner_providers.dart';
import '../learner/models.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final user = ref.watch(authProvider).value;
    final role = ref.watch(activeRoleProvider);
    final settings = ref.watch(settingsProvider);
    final pending = ref.watch(outboxPendingProvider).value?.length ?? 0;
    if (user == null) return const SizedBox.shrink();

    String roleName(AppRole r) => switch (r) {
      AppRole.teacher => l.roleTeacher,
      AppRole.parent => l.roleParent,
      AppRole.student => l.roleStudent,
    };

    return GPage(
      title: l.tabProfile,
      slivers: [
        SliverList.list(
          children: [
            GGroup(
              children: [
                GRow(
                  leading: GAvatar(name: user.fullName, url: user.avatarUrl, size: 52),
                  title: Text(user.fullName, style: context.t.titleMedium),
                  subtitle: Text(user.email),
                ),
              ],
            ),
            if (pending > 0) ...[
              const SizedBox(height: GSpace.md),
              GGroup(
                children: [
                  GRow(
                    leading: Icon(Icons.cloud_upload_outlined, color: context.c.warningText),
                    title: Text(l.syncPending(pending)),
                    trailing: TextButton(onPressed: () => ref.read(outboxProvider).flush(), child: Text(l.retry)),
                  ),
                ],
              ),
            ],
            if (user.appRoles.length > 1) ...[
              GSectionHeader(l.role),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
                child: SegmentedButton<AppRole>(
                  showSelectedIcon: false,
                  segments: [for (final r in user.appRoles) ButtonSegment(value: r, label: Text(roleName(r)))],
                  selected: {?role},
                  onSelectionChanged: (s) => ref.read(activeRoleProvider.notifier).set(s.first),
                ),
              ),
            ],
            if (role == AppRole.parent) const _Children(),
            GSectionHeader(l.language),
            GGroup(
              inset: 16,
              children: [
                for (final (locale, name) in [
                  (null, l.themeSystem),
                  (const Locale('ru'), 'Русский'),
                  (const Locale('kk'), 'Қазақша'),
                  (const Locale('en'), 'English'),
                ])
                  GRow(
                    dense: true,
                    title: Text(name),
                    trailing: settings.locale?.languageCode == locale?.languageCode
                        ? Icon(Icons.check_rounded, color: context.c.primaryText)
                        : null,
                    onTap: () => ref.read(settingsProvider.notifier).setLocale(locale),
                  ),
              ],
            ),
            GSectionHeader(l.theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GSpace.page),
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: ThemeMode.system, label: Text(l.themeSystem)),
                  ButtonSegment(value: ThemeMode.light, label: Text(l.themeLight)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(l.themeDark)),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (s) => ref.read(settingsProvider.notifier).setTheme(s.first),
              ),
            ),
            const SizedBox(height: GSpace.xl),
            GGroup(
              children: [
                GRow(
                  title: Text(l.signOut, style: TextStyle(color: context.c.destructiveText)),
                  leading: Icon(Icons.logout_rounded, color: context.c.destructiveText),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog.adaptive(
                        title: Text(l.signOutConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.signOut)),
                        ],
                      ),
                    );
                    if (ok ?? false) await ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Parent: children with the photo check-in consent switch.
class _Children extends ConsumerStatefulWidget {
  const _Children();

  @override
  ConsumerState<_Children> createState() => _ChildrenState();
}

class _ChildrenState extends ConsumerState<_Children> {
  final _optimistic = <String, bool>{};

  Future<void> _setConsent(Child child, bool value) async {
    setState(() => _optimistic[child.id] = value);
    try {
      await ref.read(dioProvider).post<void>('/students/${child.id}/photo-consent/', data: {'consent': value});
      ref.invalidate(childrenProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() => _optimistic.remove(child.id));
      showGToast(context, context.l10n.errorMessage, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final children = ref.watch(childrenProvider).value ?? const [];
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionHeader(l.profileChildren),
        GGroup(
          inset: 68,
          children: [
            for (final child in children)
              GRow(
                leading: GAvatar(name: child.fullName, url: child.avatarUrl, size: 40),
                title: Text(child.fullName),
                subtitle: Text([?child.className, l.photoConsent].join(' · ')),
                trailing: Switch.adaptive(
                  value: _optimistic[child.id] ?? child.photoConsent,
                  onChanged: (v) => _setConsent(child, v),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
