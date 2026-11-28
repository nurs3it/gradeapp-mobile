import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/settings.dart';
import '../../core/crash_reporting.dart';
import '../../core/env.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/school_providers.dart';
import '../platform/day_live.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/models.dart';
import '../learner/learner_providers.dart';
import 'header.dart';
import '../common/presence.dart';
import 'app_lock.dart';

const _webUrl = 'https://grade-app.kz';

String roleName(AppLocalizations l, AppRole r) => switch (r) {
  AppRole.teacher => l.roleTeacher,
  AppRole.parent => l.roleParent,
  AppRole.student => l.roleStudent,
};

/// Profile sheet behind the avatar (§1.2 screens): who I am, role, school,
/// children, settings, sign out.
Future<void> showProfileSheet(BuildContext context) =>
    showGSheet<void>(context, builder: (_) => const _ProfileSheet(), closeLabel: context.l10n.close);

class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final user = ref.watch(authProvider).value;
    final role = ref.watch(activeRoleProvider);
    if (user == null || role == null) return const SizedBox.shrink();
    final roles = user.appRoles;
    final settings = ref.watch(settingsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PersonAvatar(
                presence: PresenceRef.user(user.id),
                name: user.fullName,
                url: user.avatarUrl,
                size: 56,
                color: subjectOf(user.id).fill,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: context.t.title1, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      [roleName(l, role), ?user.school?.name].join(' · '),
                      style: context.t.subhead.copyWith(color: c.ink2),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (roles.length > 1) ...[
            const SizedBox(height: 16),
            GSegmented<AppRole>(
              values: roles,
              selected: role,
              labels: [for (final r in roles) roleName(l, r)],
              onChanged: (r) {
                ref.read(activeRoleProvider.notifier).set(r);
                Navigator.of(context).pop();
              },
            ),
          ],
          if (user.schools.length > 1) ...[
            const _Label(),
            GGroup(
              inset: 16,
              children: [
                for (final s in user.schools)
                  GRow(
                    minHeight: GSpace.rowCompact,
                    leading: GIcon(GIcons.school, size: 20, color: c.ink2),
                    title: Text(s.name),
                    trailing: s.id == user.linkedSchool ? GIcon(GIcons.check, size: 20, color: c.primaryText) : null,
                    onTap: s.id == user.linkedSchool ? null : () => _switchSchool(context, ref, s.id),
                  ),
              ],
            ),
          ],
          if (role == AppRole.parent) const _ChildrenGroup(),
          const SizedBox(height: 20),
          GGroup(
            inset: 48,
            children: [
              if (role == AppRole.student)
                GRow(
                  minHeight: GSpace.rowCompact,
                  leading: GIcon(GIcons.file, size: 20, color: c.ink2),
                  title: Text(l.s14Title),
                  chevron: true,
                  onTap: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    unawaited(router.push('/study-proof'));
                  },
                ),
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.bell, size: 20, color: c.ink2),
                title: Text(l.notifSettings),
                chevron: true,
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  unawaited(router.push('/settings/notifications'));
                },
              ),
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.language, size: 20, color: c.ink2),
                title: Text(l.settingsLanguage),
                trailing: Text(_langName(l, settings.locale), style: context.t.callout.copyWith(color: c.ink2)),
                chevron: true,
                onTap: () => _pickLanguage(context, ref),
              ),
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.theme, size: 20, color: c.ink2),
                title: Text(l.settingsTheme),
                trailing: Text(_themeName(l, settings.themeMode), style: context.t.callout.copyWith(color: c.ink2)),
                chevron: true,
                onTap: () => _pickTheme(context, ref),
              ),
              const _AppLockRow(),
              if (role == AppRole.student && DayLive.supported && ref.watch(mobileFlagsProvider).liveActivityEnabled)
                const _DayLiveRow(),
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.openInNew, size: 20, color: c.ink2),
                title: Text(l.openWeb),
                onTap: () => unawaited(launchUrl(Uri.parse(_webUrl), mode: LaunchMode.externalApplication)),
              ),
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.info, size: 20, color: c.ink2),
                title: Text(l.about),
                trailing: Text(l.version(appVersion), style: context.t.callout.copyWith(color: c.ink2)),
                // Debug builds only: raises a test crash to check the reporter.
                onLongPress: kDebugMode ? debugTestCrash : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GGroup(
            children: [
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.logout, size: 20, color: c.bad),
                title: Text(l.signOut, style: context.t.bodyStrong.copyWith(color: c.bad)),
                onTap: () => _signOut(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _langName(AppLocalizations l, Locale? loc) => switch (loc?.languageCode) {
    'kk' => l.langKk,
    'ru' => l.langRu,
    'en' => l.langEn,
    _ => l.langSystem,
  };

  static String _themeName(AppLocalizations l, ThemeMode m) => switch (m) {
    ThemeMode.light => l.themeLight,
    ThemeMode.dark => l.themeDark,
    ThemeMode.system => l.themeSystem,
  };

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final current = ref.read(settingsProvider).locale?.languageCode;
    final options = [(null, l.langSystem), ('kk', l.langKk), ('ru', l.langRu), ('en', l.langEn)];
    final picked = await showGSheet<(String?,)>(
      context,
      title: l.settingsLanguage,
      builder: (ctx) => _Options(options: [for (final (code, name) in options) ((code,), name, code == current)]),
    );
    if (picked == null) return;
    final code = picked.$1;
    ref.read(settingsProvider.notifier).setLocale(code == null ? null : Locale(code));
    GHaptics.selection();
    if (code != null) {
      // Server-side texts (notifications) follow the chosen language.
      unawaited(
        ref
            .read(dioProvider)
            .patch<void>('/users/me/', data: {'language_pref': apiLang(Locale(code))})
            .then((_) {}, onError: (Object _) {}),
      );
    }
  }

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final current = ref.read(settingsProvider).themeMode;
    final picked = await showGSheet<ThemeMode>(
      context,
      title: l.settingsTheme,
      builder: (ctx) => _Options(
        options: [
          for (final (m, name) in [
            (ThemeMode.system, l.themeSystem),
            (ThemeMode.light, l.themeLight),
            (ThemeMode.dark, l.themeDark),
          ])
            (m, name, m == current),
        ],
      ),
    );
    if (picked != null) {
      GHaptics.selection();
      ref.read(settingsProvider.notifier).setTheme(picked);
    }
  }

  Future<void> _switchSchool(BuildContext context, WidgetRef ref, String id) async {
    final l = context.l10n;
    try {
      await ref.read(authProvider.notifier).switchSchool(id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      GHaptics.error();
      if (context.mounted) GToast.show(context, l.switchSchoolFailed, icon: GIcons.error);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final outbox = ref.read(outboxProvider);
    final unsent = outbox.state.total;
    if (unsent == 0) {
      final ok = await confirmSheet(
        context,
        title: l.signOutConfirm,
        confirm: l.signOut,
        cancel: l.cancel,
        destructive: true,
      );
      if (ok) await ref.read(authProvider.notifier).logout();
      return;
    }
    // T11: never lose the teacher's records silently.
    final choice = await showGSheet<int>(
      context,
      title: l.signOutConfirm,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Text(l.signOutPending(unsent), style: ctx.t.body.copyWith(color: ctx.c.ink2)),
      ),
      actions: Builder(
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GButton(
              label: l.signOutSendFirst,
              expand: true,
              size: GButtonSize.l,
              onPressed: () => Navigator.pop(ctx, 1),
            ),
            const SizedBox(height: 8),
            GButton(
              label: l.signOutAnyway,
              expand: true,
              variant: GButtonVariant.destructive,
              onPressed: () => Navigator.pop(ctx, 2),
            ),
          ],
        ),
      ),
    );
    if (choice == 1) {
      await outbox.flush();
      if (outbox.state.pending.isNotEmpty) {
        if (context.mounted) GToast.show(context, l.signOutWaitNet, icon: GIcons.syncFailed);
        return;
      }
      await ref.read(authProvider.notifier).logout();
    } else if (choice == 2) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _Label extends StatelessWidget {
  const _Label();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(context.l10n.profileSchools, style: context.t.subhead.copyWith(color: context.c.ink2)),
  );
}

class _ChildrenGroup extends ConsumerWidget {
  const _ChildrenGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final children = ref.watch(childrenProvider).value ?? const <Child>[];
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
          child: Text(l.profileChildren, style: context.t.subhead.copyWith(color: c.ink2)),
        ),
        GGroup(
          inset: 68,
          children: [
            for (final child in children)
              GRow(
                leading: PersonAvatar(
                  presence: PresenceRef.student(child.id),
                  name: child.fullName,
                  url: child.avatarUrl,
                  size: 40,
                  color: childColor(child.id),
                ),
                title: Text(child.fullName),
                subtitle: Text(
                  [
                    ?child.className,
                    '${l.photoConsent}: ${child.photoConsent ? l.consentOn : l.consentOff}',
                  ].join(' · '),
                ),
                trailing: child.photoConsent
                    ? GButton(
                        label: l.consentRevokeAction,
                        size: GButtonSize.s,
                        variant: GButtonVariant.secondary,
                        onPressed: () => _revoke(context, ref, child),
                      )
                    : null,
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _revoke(BuildContext context, WidgetRef ref, Child child) async {
    final l = context.l10n;
    final ok = await confirmSheet(
      context,
      title: l.consentRevoke,
      message: l.consentRevokeBody,
      confirm: l.consentRevokeAction,
      cancel: l.cancel,
      destructive: true,
    );
    if (!ok) return;
    try {
      await ref.read(dioProvider).post<void>('/students/${child.id}/photo-consent/', data: {'consent': false});
      ref
        ..invalidate(childrenProvider)
        ..invalidate(learnerDayProvider);
    } catch (_) {
      GHaptics.error();
      if (context.mounted) GToast.show(context, l.consentFailed, icon: GIcons.error);
    }
  }
}

/// Radio list in a sheet.
class _Options<T> extends StatelessWidget {
  const _Options({required this.options});
  final List<(T, String, bool)> options;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
    child: GGroup(
      children: [
        for (final (value, label, selected) in options)
          GRow(
            minHeight: GSpace.rowCompact,
            title: Text(label),
            trailing: selected ? GIcon(GIcons.check, size: 20, color: context.c.primaryText) : null,
            onTap: () => Navigator.of(context).pop(value),
          ),
      ],
    ),
  );
}

/// Parent: the children sheet from the avatar (§3.20).
Future<void> showChildrenSheet(BuildContext context) =>
    showGSheet<void>(context, title: context.l10n.profileChildren, builder: (_) => const _ChildrenSheet());

class _ChildrenSheet extends ConsumerWidget {
  const _ChildrenSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final children = ref.watch(childrenProvider).value ?? const <Child>[];
    final current = ref.watch(learnerIdProvider);
    final family = ref.watch(familyModeProvider) && children.length > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GGroup(
            inset: 68,
            children: [
              if (children.length > 1)
                GRow(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: c.primarySoft, shape: BoxShape.circle),
                    child: GIcon(GIcons.family, size: 22, color: c.primarySoftText),
                  ),
                  title: Text(l.allFamily),
                  trailing: family ? GIcon(GIcons.check, size: 20, color: c.primaryText) : null,
                  onTap: () {
                    GHaptics.selection();
                    ref.read(familyModeProvider.notifier).set(true);
                    Navigator.pop(context);
                  },
                ),
              for (final child in children)
                GRow(
                  leading: PersonAvatar(
                    presence: PresenceRef.student(child.id),
                    name: child.fullName,
                    url: child.avatarUrl,
                    size: 40,
                    color: childColor(child.id),
                  ),
                  title: Text(child.fullName),
                  subtitle: child.className == null ? null : Text(child.className!),
                  trailing: !family && child.id == current ? GIcon(GIcons.check, size: 20, color: c.primaryText) : null,
                  onTap: () {
                    GHaptics.selection();
                    ref.read(selectedChildProvider.notifier).select(child.id);
                    ref.read(familyModeProvider.notifier).set(false);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          GGroup(
            children: [
              GRow(
                minHeight: GSpace.rowCompact,
                leading: GIcon(GIcons.person, size: 20, color: c.ink2),
                title: Text(l.profile),
                chevron: true,
                onTap: () {
                  Navigator.pop(context);
                  unawaited(showProfileSheet(context));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Opt-in Face ID / fingerprint lock.
class _AppLockRow extends ConsumerWidget {
  const _AppLockRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final on = ref.watch(appLockProvider.select((s) => s.enabled));
    Future<void> toggle(bool want) async {
      final ctl = ref.read(appLockProvider.notifier);
      final ok = want ? await ctl.enable(l.lockReason) : await ctl.disable(l.lockReason);
      if (ok) {
        GHaptics.selection();
      } else if (want && context.mounted) {
        GToast.show(context, l.lockUnavailable, icon: GIcons.error);
      }
    }

    return GRow(
      minHeight: GSpace.rowCompact,
      leading: GIcon(GIcons.faceId, size: 20, color: c.ink2),
      title: Text(l.lockSetting),
      subtitle: Text(l.lockSettingHint),
      trailing: Switch.adaptive(value: on, activeTrackColor: GColors.brand, onChanged: (v) => unawaited(toggle(v))),
      onTap: () => unawaited(toggle(!on)),
    );
  }
}

/// W6: opt-in «Мой учебный день» on the lock screen (iOS).
class _DayLiveRow extends ConsumerStatefulWidget {
  const _DayLiveRow();

  @override
  ConsumerState<_DayLiveRow> createState() => _DayLiveRowState();
}

class _DayLiveRowState extends ConsumerState<_DayLiveRow> {
  bool? _on;

  @override
  void initState() {
    super.initState();
    unawaited(DayLive.enabled(ref.read(prefsProvider)).then((v) => mounted ? setState(() => _on = v) : null));
  }

  Future<void> _toggle(bool want) async {
    GHaptics.selection();
    setState(() => _on = want);
    await DayLive.setEnabled(want, prefs: ref.read(prefsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final on = _on ?? false;
    return GRow(
      minHeight: GSpace.rowCompact,
      leading: GIcon(GIcons.clock, size: 20, color: c.ink2),
      title: Text(l.w6Setting),
      subtitle: Text(l.w6SettingHint),
      subtitleMaxLines: 2,
      trailing: Switch.adaptive(value: on, activeTrackColor: GColors.brand, onChanged: (v) => unawaited(_toggle(v))),
      onTap: () => unawaited(_toggle(!on)),
    );
  }
}
