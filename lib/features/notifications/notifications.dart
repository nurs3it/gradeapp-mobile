import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import '../auth/user.dart';
import '../common/pulse.dart';

class NotificationTarget {
  const NotificationTarget({required this.kind, required this.id, required this.available});
  final String kind;
  final String id;
  final bool available;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.payload,
    required this.read,
    required this.createdAt,
    this.target,
  });

  final String id;
  final String type;
  final Json payload;
  final bool read;
  final DateTime createdAt;
  final NotificationTarget? target;

  AppNotification asRead() =>
      AppNotification(id: id, type: type, payload: payload, read: true, createdAt: createdAt, target: target);

  factory AppNotification.fromJson(Json j) {
    final t = j['target'];
    return AppNotification(
      id: j.str('id'),
      type: j.str('type'),
      payload: (j['payload'] as Json?) ?? const {},
      read: j.flag('read_flag'),
      createdAt: DateTime.tryParse(j.str('created_at'))?.toLocal() ?? DateTime.now(),
      target: t is Json
          ? NotificationTarget(kind: t.str('kind'), id: t.str('id'), available: t.flag('available'))
          : null,
    );
  }
}

final notificationsProvider = StreamProvider<List<AppNotification>>(
  (ref) => cachedGet(
    ref,
    '/notifications/',
    parse: (d) => parseList(d, AppNotification.fromJson)..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
  ),
);

/// Locally read ids until the server list refreshes.
class ReadIds extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};
  void add(String id) => state = {...state, id};
  void all(Iterable<String> ids) => state = {...state, ...ids};
}

final readIdsProvider = NotifierProvider<ReadIds, Set<String>>(ReadIds.new);

Future<void> markRead(WidgetRef ref, AppNotification n) async {
  if (n.read) return;
  ref.read(readIdsProvider.notifier).add(n.id);
  try {
    await ref.read(dioProvider).patch<void>('/notifications/${n.id}/', data: {'read_flag': true});
    unawaited(ref.read(pulseProvider.notifier).refresh());
  } catch (_) {}
}

Future<void> markAllRead(WidgetRef ref, List<AppNotification> list) async {
  ref.read(readIdsProvider.notifier).all(list.map((n) => n.id));
  ref.read(pulseProvider.notifier).seen();
  try {
    await ref.read(dioProvider).post<void>('/notifications/mark_all_read/');
  } catch (_) {}
}

String notificationTitle(AppLocalizations l, String type) => switch (type) {
  'grade.created' => l.ntGradeCreated,
  'grade.updated' => l.ntGradeUpdated,
  'homework.assigned' || 'homework.updated' => l.ntHomework,
  'homework.reminder' => l.ntHomeworkReminder,
  'lesson.cancelled' => l.ntLessonCancelled,
  'lesson.rescheduled' => l.ntLessonRescheduled,
  'lesson.substitution' || 'lesson.substitution_cancelled' => l.ntSubstitution,
  'lesson.started' => l.ntLessonStarted,
  'checkin.arrived' => l.ntCheckIn,
  'checkin.missing' => l.ntCheckInMissing,
  'attendance.flagged' => l.ntAttendance,
  'attendance.unmarked' => l.ntUnmarked,
  'grades.reminder' => l.ntGradesReminder,
  'excuse.pending' || 'excuse.digest' => l.ntExcusePending,
  'excuse.approved' || 'excuse.student_excused' => l.ntExcuseApproved,
  'excuse.rejected' => l.ntExcuseRejected,
  'excuse.cancelled' => l.ntExcuseCancelled,
  'school_event' => l.ntEvent,
  'chat.message' => l.ntChat,
  'digest.weekly' => l.ntDigest,
  'consent.requested' => l.ntConsentRequested,
  _ when type.startsWith('invoice.') => l.ntInvoice,
  _ => l.ntOther,
};

/// Readable payload: course · title · student · value — never ids.
String notificationBody(Json p) {
  String s(String k) => p.str(k).trim();
  final parts = [
    s('student_name'),
    if (s('course_name').isNotEmpty) s('course_name') else s('course'),
    s('title'),
    if (s('value').isNotEmpty) s('value'),
    s('text'),
    s('date'),
  ].where((x) => x.isNotEmpty).toList();
  return parts.take(3).join(' · ');
}

IconData notificationIcon(String type) => switch (type.split('.').first) {
  'grade' || 'grades' => GIcons.grades,
  'homework' => GIcons.homework,
  'lesson' => GIcons.swap,
  'excuse' => GIcons.excuse,
  'invoice' => GIcons.payments,
  'checkin' => GIcons.checkIn,
  'attendance' => GIcons.info,
  'chat' => GIcons.chat,
  'digest' => GIcons.summary,
  'consent' => GIcons.checkIn,
  _ => GIcons.bell,
};

/// Where a notification leads (spec §4.3) for the active role.
String? notificationRoute(AppNotification n, AppRole role) {
  // Stage 3: the summary opens on the week the push names; a consent request
  // lands on the parent's «Сегодня», where the consent card is.
  if (n.type == 'digest.weekly' && role != AppRole.teacher) {
    final student = n.payload.strOrNull('student_id') ?? n.target?.id;
    final week = n.payload.strOrNull('week');
    final q = [if (student != null) 'student=$student', if (week != null) 'week=$week'].join('&');
    return q.isEmpty ? '/week-summary' : '/week-summary?$q';
  }
  if (n.type == 'consent.requested') return role == AppRole.parent ? '/p/today' : null;
  final kind = n.target?.kind ?? n.type.split('.').first;
  final id = n.target?.id ?? '';
  return switch ((kind, role)) {
    ('grade', AppRole.student) => '/s/grades',
    ('grade', AppRole.parent) => '/p/grades',
    ('homework', AppRole.student) => '/s/tasks',
    ('homework', AppRole.parent) => '/p/week',
    ('lesson', AppRole.teacher) when id.isNotEmpty => '/lesson/$id',
    ('lesson', AppRole.student) => '/s/week',
    ('lesson', AppRole.parent) => '/p/week',
    ('checkin' || 'attendance', AppRole.parent) => '/p/today',
    ('excuse' || 'invoice', AppRole.parent) => '/p/family',
    ('excuse', AppRole.teacher) => '/t/inbox',
    _ => null,
  };
}

/// Opens the target of a notification and marks it read; explains when the
/// entity is gone (`target.available = false`).
Future<void> openNotification(BuildContext context, WidgetRef ref, AppNotification n) async {
  unawaited(markRead(ref, n));
  final l = context.l10n;
  if (n.target != null && !n.target!.available) {
    await showGSheet<void>(
      context,
      title: l.notifUnavailable,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Text(l.notifUnavailableHint, style: ctx.t.body.copyWith(color: ctx.c.ink2)),
      ),
    );
    return;
  }
  final role = ref.read(activeRoleProvider);
  final route = role == null ? null : notificationRoute(n, role);
  if (route == null || !context.mounted) return;
  if (route.startsWith('/lesson/') || route.startsWith('/week-summary')) {
    unawaited(context.push(route));
  } else {
    context.go(route);
  }
}

/// Notification row (§6.1): icon plate, bold title + gold dot when unread.
class NotificationRow extends StatelessWidget {
  const NotificationRow({super.key, required this.n, required this.read, required this.onTap});
  final AppNotification n;
  final bool read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final body = notificationBody(n.payload);
    return GRow(
      minHeight: 72,
      onTap: onTap,
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(color: c.surface2, shape: GRadius.surface(13)),
            child: GIcon(notificationIcon(n.type), size: 22, color: c.ink2),
          ),
          if (!read) const Positioned(right: -3, top: -3, child: GNewDot()),
        ],
      ),
      title: Text(notificationTitle(l, n.type), style: read ? t.body : t.bodyStrong),
      subtitle: body.isEmpty ? null : Text(body),
      subtitleMaxLines: 2,
      trailing: Text(Fmt.clock(n.createdAt), style: t.footnote.copyWith(color: c.ink3)),
    );
  }
}

/// Groups by day: «Сегодня», «Вчера», dates.
List<(String, List<AppNotification>)> groupByDay(BuildContext context, List<AppNotification> list) {
  final l = context.l10n;
  final now = DateTime.now();
  String key(DateTime d) => '${d.year}-${d.month}-${d.day}';
  final today = key(now);
  final yesterday = key(now.subtract(const Duration(days: 1)));
  final out = <(String, List<AppNotification>)>[];
  for (final n in list) {
    final k = key(n.createdAt);
    final title = k == today
        ? l.todayWord
        : k == yesterday
        ? l.yesterday
        : Fmt.dayMonth(n.createdAt, context.localeTag);
    if (out.isEmpty || out.last.$1 != title) out.add((title, <AppNotification>[]));
    out.last.$2.add(n);
  }
  return out;
}
