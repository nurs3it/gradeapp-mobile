import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/school_providers.dart';
import 'learner_providers.dart';

/// Streak kinds the backend names.
enum StreakKind { checkin, homework }

StreakKind? streakKindOf(String s) => StreakKind.values.asNameMap()[s];

/// State of today for one streak (B2). Unknown values read as «off».
enum StreakToday { done, pending, missed, frozen, excused, off }

StreakToday streakTodayOf(String s) => StreakToday.values.asNameMap()[s] ?? StreakToday.off;

/// Milestones in days (B2); each opens one more page of the mark.
const streakMilestones = [5, 10, 20, 50];

/// 0…4 pages of the «four pages» mark earned by [days].
int pagesOf(int days) => streakMilestones.where((m) => days >= m).length;

class StreakLine {
  const StreakLine({this.current = 0, this.best = 0, this.today = StreakToday.off, this.freezesLeft = 0});
  final int current;
  final int best;
  final StreakToday today;
  final int freezesLeft;

  factory StreakLine.fromJson(Json? j) => j == null
      ? const StreakLine()
      : StreakLine(
          current: (j.number('current') ?? 0).toInt(),
          best: (j.number('best') ?? 0).toInt(),
          today: streakTodayOf(j.str('today')),
          freezesLeft: (j.number('freezes_left') ?? 0).toInt(),
        );
}

typedef Milestone = ({StreakKind kind, int days, String reachedAt});
typedef MissedDay = ({StreakKind kind, String date, DateTime? freezeUntil});

class Streaks {
  const Streaks({
    required this.enabled,
    this.disabledByParent = false,
    this.checkin = const StreakLine(),
    this.homework = const StreakLine(),
    this.milestones = const [],
    this.missed = const [],
  });

  final bool enabled;
  final bool disabledByParent;
  final StreakLine checkin;
  final StreakLine homework;
  final List<Milestone> milestones;
  final List<MissedDay> missed;

  StreakLine line(StreakKind k) => k == StreakKind.checkin ? checkin : homework;

  factory Streaks.fromJson(Json j) => Streaks(
    enabled: j.flag('enabled'),
    disabledByParent: j.flag('disabled_by_parent'),
    checkin: StreakLine.fromJson(j['checkin'] as Json?),
    homework: StreakLine.fromJson(j['homework'] as Json?),
    milestones: [
      for (final m in j.list('milestones', (m) => m))
        if (streakKindOf(m.str('kind')) != null)
          (kind: streakKindOf(m.str('kind'))!, days: (m.number('days') ?? 0).toInt(), reachedAt: m.str('reached_at')),
    ],
    missed: [
      for (final m in j.list('missed', (m) => m))
        if (streakKindOf(m.str('kind')) != null)
          (
            kind: streakKindOf(m.str('kind'))!,
            date: m.str('date'),
            freezeUntil: DateTime.tryParse(m.str('freeze_until')),
          ),
    ],
  );
}

/// The highest milestone reached on [date] (`YYYY-MM-DD`), for the success screen.
Milestone? milestoneReachedOn(Streaks s, String date) {
  final today = s.milestones.where((m) => m.reachedAt == date).toList()..sort((a, b) => b.days.compareTo(a.days));
  return today.firstOrNull;
}

/// A missed day can still be frozen: a freeze is left and the window is open.
bool canFreeze(Streaks s, MissedDay m, DateTime now) =>
    s.line(m.kind).freezesLeft > 0 && (m.freezeUntil == null || now.isBefore(m.freezeUntil!));

final streaksProvider = StreamProvider.family<Streaks, String>(
  (ref, studentId) =>
      cachedGet(ref, '/students/$studentId/streaks/', parse: (d) => Streaks.fromJson(d as Json)),
);

/// Streaks shown to the learner in view: the school flag is on and the API
/// has them on. Null while unknown, so nothing flashes.
final streaksOfLearnerProvider = Provider<Streaks?>((ref) {
  if (!ref.watch(mobileFlagsProvider).streaksEnabled) return null;
  final id = ref.watch(learnerIdProvider);
  if (id == null) return null;
  final s = ref.watch(streaksProvider(id)).value;
  return s != null && s.enabled ? s : null;
});

/// Freeze outcome: null = done, else the backend `code`
/// (`freeze_expired`, `no_freezes_left`, `not_missed`) or `error`.
Future<String?> freezeStreakDay(WidgetRef ref, String studentId, StreakKind kind, String date) async {
  try {
    await ref
        .read(dioProvider)
        .post<Object?>('/students/$studentId/streaks/freeze/', data: {'kind': kind.name, 'date': date});
    ref.invalidate(streaksProvider(studentId));
    return null;
  } on DioException catch (e) {
    final body = e.response?.data;
    final code = body is Map ? (body['code'] ?? body['error'] ?? body['detail']) : null;
    return code is String && code.isNotEmpty ? code : 'error';
  }
}

/// Parent: turn streaks off or on for one child.
Future<bool> setStreaksEnabled(WidgetRef ref, String studentId, bool enabled) async {
  try {
    await ref.read(dioProvider).post<Object?>('/students/$studentId/streaks/settings/', data: {'enabled': enabled});
    ref.invalidate(streaksProvider(studentId));
    return true;
  } catch (_) {
    return false;
  }
}

String todayLine(AppLocalizations l, StreakToday t, StreakKind k) => switch (t) {
  StreakToday.done => k == StreakKind.checkin ? l.s10TodayDoneCheckin : l.s10TodayDoneHomework,
  StreakToday.pending => l.s10TodayPending,
  StreakToday.frozen => l.s10TodayFrozen,
  StreakToday.excused => l.s10TodayExcused,
  StreakToday.missed => l.s10TodayMissed,
  StreakToday.off => k == StreakKind.checkin ? l.s10TodayOff : l.s10TodayOffHomework,
};

/// Card on the student's «Сегодня»: the first streak and a hint of the second.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(streaksOfLearnerProvider);
    if (s == null) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final excused = s.checkin.today == StreakToday.excused;
    final title = s.checkin.current > 0 ? l.s10CardCheckin(s.checkin.current) : l.s10CardStart;
    final sub = excused ? l.s10TodayExcused : (s.homework.current > 0 ? l.s10CardHomework(s.homework.current) : null);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GCard(
        onTap: () => context.push('/streaks'),
        semanticLabel: [title, ?sub, l.s10Title].join('. '),
        child: Row(
          children: [
            GFanProgress(earned: pagesOf(s.checkin.current).toDouble(), size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.bodyStrong),
                  if (sub != null) Text(sub, style: t.footnote.copyWith(color: c.ink2)),
                ],
              ),
            ),
            GIcon(GIcons.chevron, size: 22, color: c.ink3),
          ],
        ),
      ),
    );
  }
}

/// Streaks detail (S10): both streaks, best, freezes, missed days, milestones.
class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final id = ref.watch(learnerIdProvider);
    final async = id == null ? null : ref.watch(streaksProvider(id));
    final enabledBySchool = ref.watch(mobileFlagsProvider).streaksEnabled;
    final s = async?.value;
    Widget body;
    if (!enabledBySchool || (s != null && !s.enabled)) {
      body = GEmpty(
        title: l.s10Title,
        message: s?.disabledByParent ?? false ? l.s10ParentOff : l.s10Unavailable,
        icon: GIcons.info,
      );
    } else if (s == null) {
      body = async != null && async.hasError
          ? GEmpty(
              error: true,
              title: l.errorTitle,
              message: l.errorOffline,
              action: l.retry,
              onAction: () => ref.invalidate(streaksProvider(id!)),
            )
          : const GSkeleton(hero: false);
    } else {
      body = _Body(streaks: s, studentId: id!);
    }
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: ListView(
        padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14, left: 4),
            child: Semantics(header: true, child: Text(l.s10Title, style: context.t.title1)),
          ),
          body,
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.streaks, required this.studentId});
  final Streaks streaks;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final now = DateTime.now();
    final loc = context.localeTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final k in StreakKind.values) ...[
          _LineCard(kind: k, line: streaks.line(k)),
          const SizedBox(height: 12),
        ],
        if (streaks.checkin.today == StreakToday.excused || streaks.homework.today == StreakToday.excused)
          GStateRow(title: l.s10ExcusedTitle, message: l.s10ExcusedBody, tone: GTone.info, icon: GIcons.excuse),
        GSectionTitle(title: l.s10Milestones),
        GCard(
          child: Row(
            children: [
              for (final m in streakMilestones)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final reached = streaks.milestones.any((x) => x.days == m) || streaks.checkin.best >= m;
                      final idx = streakMilestones.indexOf(m) + 1;
                      return Semantics(
                        label: reached ? l.s10MilestoneReached(m) : l.s10MilestoneAhead(m),
                        excludeSemantics: true,
                        child: Column(
                          children: [
                            GFanProgress(earned: reached ? idx.toDouble() : 0, size: 40),
                            const SizedBox(height: 6),
                            Text(
                              '$m',
                              style: t.bodyStrong.copyWith(color: reached ? c.ink : c.ink3),
                            ),
                            Text(l.s10DaysShort, style: t.caption.copyWith(color: c.ink3)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        if (streaks.missed.isNotEmpty) ...[
          GSectionTitle(title: l.s10Missed),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Text(l.s10MissedHint, style: t.footnote.copyWith(color: c.ink2)),
          ),
          GGroup(
            children: [
              for (final m in streaks.missed)
                GRow(
                  title: Text(Fmt.weekdayDayMonth(DateTime.parse(m.date), loc)),
                  subtitle: Text(m.kind == StreakKind.checkin ? l.s10KindCheckin : l.s10KindHomework),
                  trailing: GButton(
                    label: l.s10Freeze,
                    size: GButtonSize.s,
                    variant: GButtonVariant.tinted,
                    onPressed: canFreeze(streaks, m, now)
                        ? () async {
                            final err = await freezeStreakDay(ref, studentId, m.kind, m.date);
                            if (!context.mounted) return;
                            if (err == null) {
                              GHaptics.success();
                              GToast.show(context, l.s10Frozen);
                            } else {
                              GHaptics.error();
                              GToast.show(context, switch (err) {
                                'freeze_expired' => l.s10FreezeExpired,
                                'no_freezes_left' => l.s10NoFreezes,
                                _ => l.errorGeneric,
                              }, icon: GIcons.error);
                            }
                          }
                        : null,
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(l.s10SickNote, style: t.footnote.copyWith(color: c.ink2)),
        ),
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({required this.kind, required this.line});
  final StreakKind kind;
  final StreakLine line;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final title = kind == StreakKind.checkin ? l.s10KindCheckin : l.s10KindHomework;
    return GCard(
      semanticLabel: [title, l.s10Days(line.current), l.s10Best(line.best), l.s10FreezesLeft(line.freezesLeft)].join('. '),
      child: Row(
        children: [
          GFanProgress(earned: pagesOf(line.current).toDouble(), size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.footnote.copyWith(color: c.ink2)),
                Text(l.s10Days(line.current), style: t.title2),
                const SizedBox(height: 2),
                Text(todayLine(l, line.today, kind), style: t.footnote.copyWith(color: c.ink2)),
                const SizedBox(height: 6),
                Text(
                  '${l.s10Best(line.best)} · ${l.s10FreezesLeft(line.freezesLeft)}',
                  style: t.footnote.copyWith(color: c.ink3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Parent: «Серии и достижения» switch for the child in view. Hidden when the
/// school has streaks off.
class StreaksParentSwitch extends ConsumerStatefulWidget {
  const StreaksParentSwitch({super.key, required this.studentId});
  final String studentId;

  @override
  ConsumerState<StreaksParentSwitch> createState() => _StreaksParentSwitchState();
}

class _StreaksParentSwitchState extends ConsumerState<StreaksParentSwitch> {
  bool? _pending;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(mobileFlagsProvider).streaksEnabled) return const SizedBox.shrink();
    final s = ref.watch(streaksProvider(widget.studentId)).value;
    // School off (backend answers enabled:false without the parent flag).
    if (s == null || (!s.enabled && !s.disabledByParent)) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final on = _pending ?? s.enabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.s10Title),
        GGroup(
          children: [
            GRow(
              title: Text(l.s10ParentSwitch),
              trailing: Switch.adaptive(
                value: on,
                activeTrackColor: GColors.brand,
                onChanged: _pending != null
                    ? null
                    : (v) async {
                        setState(() => _pending = v);
                        final ok = await setStreaksEnabled(ref, widget.studentId, v);
                        if (!context.mounted) return;
                        setState(() => _pending = null);
                        if (!ok) GToast.show(context, l.errorGeneric, icon: GIcons.error);
                      },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(l.s10ParentExplain, style: context.t.footnote.copyWith(color: c.ink2)),
        ),
      ],
    );
  }
}
