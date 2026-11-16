import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../platform/lesson_live.dart';
import '../platform/reminders.dart';
import 'push.dart';

/// C6: which groups come as a push. Optimistic, rolled back on error; the
/// phone-level switch is checked again when the app returns from settings.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _State();
}

class _State extends ConsumerState<NotificationSettingsScreen> {
  final Map<String, bool> _pending = {};
  AuthorizationStatus? _status;
  late final AppLifecycleListener _life = AppLifecycleListener(onResume: _checkStatus);

  @override
  void initState() {
    super.initState();
    _life;
    _checkStatus();
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final push = ref.read(pushProvider);
    final s = await push.status();
    if (s == AuthorizationStatus.authorized) unawaited(push.register());
    if (mounted) setState(() => _status = s);
  }

  Future<void> _toggle(AppUser user, PushGroup g, bool on) async {
    setState(() => _pending[g.name] = on);
    final prefs = {
      ...user.notificationPrefs,
      g.name: {...?(user.notificationPrefs[g.name] as Json?), 'push': on},
    };
    try {
      await ref.read(dioProvider).patch<void>('/users/me/', data: {'notification_prefs': prefs});
      await ref.read(authProvider.notifier).refreshMe();
    } catch (_) {
      if (mounted) GToast.show(context, context.l10n.errorGeneric, icon: GIcons.error);
    }
    if (mounted) setState(() => _pending.remove(g.name));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final g = GSpace.gutter(context);
    final user = ref.watch(authProvider).value;
    final role = ref.watch(activeRoleProvider);
    final groups = [
      PushGroup.grades,
      PushGroup.homework,
      PushGroup.schedule,
      PushGroup.attendance,
      PushGroup.chat,
      if (role == AppRole.parent) PushGroup.billing,
    ];
    final off = _status == AuthorizationStatus.denied;
    final ask = _status == AuthorizationStatus.notDetermined && Push.enabled;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(title: l.notifSettings, backLabel: l.back),
      body: user == null
          ? const SizedBox.shrink()
          : ListView(
              padding: EdgeInsets.fromLTRB(g, 8, g, 32),
              children: [
                if (!Push.enabled)
                  _Banner(text: l.pushUnavailable)
                else if (off)
                  _Banner(text: l.pushOffTitle, action: l.pushOffOpen, onAction: SystemBridge.openNotificationSettings)
                else if (ask)
                  _Banner(
                    text: l.pushAskTitle,
                    action: l.pushTurnOn,
                    onAction: () async {
                      await ref.read(pushProvider).request();
                      await _checkStatus();
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
                  child: Text(l.notifSettingsHint, style: t.callout.copyWith(color: c.ink2)),
                ),
                GGroup(
                  children: [
                    for (final grp in groups)
                      GRow(
                        minHeight: GSpace.rowCompact,
                        title: Text(grp.label(l)),
                        trailing: Switch.adaptive(
                          value: _pending[grp.name] ?? user.pushOn(grp.name),
                          activeTrackColor: GColors.brand,
                          onChanged: off || _pending.containsKey(grp.name) ? null : (v) => _toggle(user, grp, v),
                        ),
                      ),
                  ],
                ),
                if (role == AppRole.teacher) const _LocalSwitches(),
              ],
            ),
    );
  }
}

/// Teacher: things that live on this phone only (T10, W5).
class _LocalSwitches extends ConsumerStatefulWidget {
  const _LocalSwitches();

  @override
  ConsumerState<_LocalSwitches> createState() => _LocalSwitchesState();
}

class _LocalSwitchesState extends ConsumerState<_LocalSwitches> {
  bool _reminders = true;
  bool _live = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(prefsProvider);
    unawaited(
      Future.wait([Reminders.enabled(prefs), LessonLive.enabled(prefs)]).then((v) {
        if (mounted) {
          setState(() {
            _reminders = v[0];
            _live = v[1];
          });
        }
      }),
    );
  }

  Future<void> _set(String key, bool on) async {
    await ref.read(prefsProvider).write(key, on);
    if (key == remindersPrefKey && !on) await Reminders.cancelAll();
    if (key == LessonLive.prefKey && !on) {
      final live = LessonLive.current;
      if (live != null) await LessonLive.finish(live.lessonId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.t;
    final c = context.c;
    Widget row(String title, bool value, String key, ValueChanged<bool> apply) => GRow(
      minHeight: GSpace.rowCompact,
      title: Text(title),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: GColors.brand,
        onChanged: (v) {
          apply(v);
          unawaited(_set(key, v));
        },
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
          child: Text(l.setLocalTitle, style: t.callout.copyWith(color: c.ink2)),
        ),
        GGroup(
          children: [
            row(l.setReminders, _reminders, remindersPrefKey, (v) => setState(() => _reminders = v)),
            row(l.setLive, _live, LessonLive.prefKey, (v) => setState(() => _live = v)),
          ],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(color: c.surface, shape: GRadius.surface(GRadius.card)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GIcon(GIcons.bell, size: 22, color: c.ink2),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: context.t.bodyStrong)),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            GButton(label: action!, size: GButtonSize.s, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
