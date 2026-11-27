import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/lesson_widgets.dart';
import '../common/models.dart';
import '../common/school_providers.dart';
import '../learner/learner_providers.dart';
import 'attendance_logic.dart';
import 'excuse_sheet.dart';

typedef MonthArgs = ({String studentId, String from, String to});

final attendanceRecordsProvider = StreamProvider.family<List<AttRecord>, MonthArgs>(
  (ref, a) => cachedGet(
    ref,
    '/attendance/',
    query: {'student_id': a.studentId, 'date_from': a.from, 'date_to': a.to, 'page_size': 500},
    parse: (d) => parseList(d, AttRecord.fromJson),
  ),
);

final attendanceStatsProvider = StreamProvider.family<AttStats, MonthArgs>(
  (ref, a) => cachedGet(
    ref,
    '/attendance/statistics/',
    query: {'student_id': a.studentId, 'date_from': a.from, 'date_to': a.to},
    parse: (d) => AttStats.fromJson(d as Json),
  ),
);

MonthArgs _monthArgs(String id, DateTime month) =>
    (studentId: id, from: isoDate(month), to: isoDate(DateTime(month.year, month.month + 1, 0)));

/// Parent: attendance of a child (P5): month calendar, quarter percent,
/// absences with «Объяснить», tap a day for its lessons.
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, this.studentId});
  final String? studentId;

  @override
  ConsumerState<AttendanceScreen> createState() => _State();
}

class _State extends ConsumerState<AttendanceScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  String? _day;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final id = widget.studentId ?? ref.watch(learnerIdProvider);
    final terms = ref.watch(termsProvider).value ?? const <Term>[];
    final term = currentTermOf(terms, DateTime.now());
    final child = ref.watch(childrenProvider).value?.where((x) => x.id == id).firstOrNull;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: id == null
          ? const Center(child: GLoader())
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                GRefreshControl(
                  onRefresh: () async {
                    final month = _monthArgs(id, _month);
                    ref.invalidate(attendanceRecordsProvider(month));
                    if (term != null) {
                      ref.invalidate(attendanceStatsProvider((studentId: id, from: term.start, to: term.end)));
                    }
                    await ref.read(attendanceRecordsProvider(month).future).catchError((_) => const <AttRecord>[]);
                  },
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
                  sliver: SliverList.list(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Semantics(
                          header: true,
                          child: Text(
                            child == null ? l.p5Title : '${l.p5Title} · ${child.shortName}',
                            style: context.t.title1,
                          ),
                        ),
                      ),
                      if (term != null) _Percent(studentId: id, term: term),
                      const SizedBox(height: 14),
                      _Calendar(
                        studentId: id,
                        month: _month,
                        selected: _day,
                        onMonth: (d) => setState(() {
                          _month = d;
                          _day = null;
                        }),
                        onDay: (d) => setState(() => _day = _day == d ? null : d),
                      ),
                      if (_day != null) _DayLessons(studentId: id, date: _day!),
                      _Absences(studentId: id, month: _month),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Percent extends ConsumerWidget {
  const _Percent({required this.studentId, required this.term});
  final String studentId;
  final Term term;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final stats = ref.watch(attendanceStatsProvider((studentId: studentId, from: term.start, to: term.end))).value;
    return GCard(
      child: stats == null
          ? const SizedBox(height: 56, child: Center(child: GLoader(size: 28)))
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.p5Quarter(term.name).toUpperCase(), style: t.eyebrow.copyWith(color: c.ink2)),
                      const SizedBox(height: 4),
                      Text(stats.rate == null ? '—' : '${fmtNum(stats.rate!.round())} %', style: t.title1),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (stats.absent > 0) Text(l.p5CountAbsent(stats.absent), style: t.footnote.copyWith(color: c.bad)),
                    if (stats.tardy > 0) Text(l.p5CountTardy(stats.tardy), style: t.footnote.copyWith(color: c.warn)),
                    if (stats.excused > 0)
                      Text(l.p5CountExcused(stats.excused), style: t.footnote.copyWith(color: c.ink2)),
                    if (stats.absent + stats.tardy + stats.excused == 0)
                      Text(l.p5NoMisses, style: t.footnote.copyWith(color: c.ok)),
                  ],
                ),
              ],
            ),
    );
  }
}

class _Calendar extends ConsumerWidget {
  const _Calendar({
    required this.studentId,
    required this.month,
    required this.selected,
    required this.onMonth,
    required this.onDay,
  });
  final String studentId;
  final DateTime month;
  final String? selected;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<String> onDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final loc = context.localeTag;
    final records = ref.watch(attendanceRecordsProvider(_monthArgs(studentId, month)));
    final classes = classifyDays(records.value ?? const []);
    final cells = monthCells(month);
    final rows = <List<DateTime?>>[
      for (var i = 0; i < cells.length; i += 7) [for (var j = i; j < i + 7; j++) j < cells.length ? cells[j] : null],
    ];
    final today = isoDate(DateTime.now());
    final title = Fmt.monthYear(month, loc);
    final nextOk = shiftMonth(month, 1).isBefore(DateTime.now());
    return GCard(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
      child: Column(
        children: [
          Row(
            children: [
              GIconButton(
                icon: GIcons.back,
                label: l.p5PrevMonth,
                size: 40,
                background: c.surface2,
                onPressed: () => onMonth(shiftMonth(month, -1)),
              ),
              Expanded(
                child: Text(title, textAlign: TextAlign.center, style: t.headline),
              ),
              GIconButton(
                icon: GIcons.chevron,
                label: l.p5NextMonth,
                size: 40,
                background: c.surface2,
                onPressed: nextOk ? () => onMonth(shiftMonth(month, 1)) : null,
              ),
            ],
          ),
          Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      Fmt.weekdayShort(DateTime(2026, 11, 2 + i), loc),
                      style: t.caption.copyWith(color: c.ink3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (!records.hasValue && records.hasError)
            GEmpty(error: true, title: l.errorTitle, message: l.errorOffline)
          else
            for (final row in rows)
              Row(
                children: [
                  for (final d in row)
                    Expanded(
                      child: d == null
                          ? const SizedBox(height: 52)
                          : _DayCell(
                              date: d,
                              cls: classes[isoDate(d)] ?? DayClass.none,
                              selected: selected == isoDate(d),
                              isToday: isoDate(d) == today,
                              onTap: () => onDay(isoDate(d)),
                            ),
                    ),
                ],
              ),
          const SizedBox(height: 10),
          const _Legend(),
        ],
      ),
    );
  }
}

(Color bg, Color fg, IconData? icon) _dayStyle(GColors c, DayClass cls) => switch (cls) {
  DayClass.present => (c.okSoft, c.ok, GIcons.check),
  DayClass.tardy => (c.warnSoft, c.warn, GIcons.clock),
  DayClass.absent => (c.badSoft, c.bad, GIcons.close),
  DayClass.excused => (c.primarySoft, c.primarySoftText, GIcons.excuse),
  DayClass.none => (Colors.transparent, c.ink3, null),
};

String _dayLabel(AppLocalizations l, DayClass c) => switch (c) {
  DayClass.present => l.p5Present,
  DayClass.tardy => l.p5Tardy,
  DayClass.absent => l.p5Absent,
  DayClass.excused => l.p5Excused,
  DayClass.none => l.p5NoLessons,
};

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.cls,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });
  final DateTime date;
  final DayClass cls;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg, icon) = _dayStyle(c, cls);
    return GPressable(
      onTap: cls == DayClass.none ? null : onTap,
      semanticLabel: '${Fmt.dayMonth(date, context.localeTag)}, ${_dayLabel(context.l10n, cls)}',
      excludeChildSemantics: true,
      scale: 0.92,
      child: SizedBox(
        height: 52,
        child: Center(
          child: Container(
            width: 42,
            height: 46,
            decoration: ShapeDecoration(
              color: bg,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(14),
                side: selected
                    ? const BorderSide(color: GColors.brand, width: 2)
                    : isToday
                    ? BorderSide(color: c.ink3, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: context.t.callout.copyWith(
                    color: cls == DayClass.none ? c.ink3 : fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (icon != null) GIcon(icon, size: 14, color: fg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final cls in [DayClass.present, DayClass.tardy, DayClass.absent, DayClass.excused])
          Builder(
            builder: (context) {
              final (bg, fg, icon) = _dayStyle(c, cls);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(7)),
                    child: GIcon(icon!, size: 13, color: fg),
                  ),
                  const SizedBox(width: 5),
                  Text(_dayLabel(l, cls), style: context.t.caption.copyWith(color: c.ink2)),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _DayLessons extends ConsumerWidget {
  const _DayLessons({required this.studentId, required this.date});
  final String studentId;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final day = ref.watch(learnerDayProvider((studentId: studentId, date: date)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: Fmt.weekdayDayMonth(DateTime.parse(date), context.localeTag)),
        if (!day.hasValue)
          day.hasError
              ? GStateRow(title: l.errorTitle, message: l.errorOffline, tone: GTone.bad)
              : const GSkeleton(hero: false, rows: 3)
        else if (day.value!.lessons.isEmpty)
          GCard(child: GEmpty(title: l.p5NoLessons))
        else
          GGroup(
            inset: 64,
            children: [
              for (final lesson in day.value!.lessons.where((x) => !x.isCancelled))
                Builder(
                  builder: (context) {
                    final mark = day.value!.attendance[lesson.id];
                    final grades = day.value!.recentGrades.where((x) => x.lessonId == lesson.id).toList();
                    final cls = mark == null
                        ? DayClass.none
                        : classifyDay([
                            AttRecord(
                              id: '',
                              lessonId: lesson.id,
                              date: date,
                              course: lesson.subject,
                              start: lesson.start,
                              status: mark.status,
                            ),
                          ]);
                    final (_, fg, icon) = _dayStyle(c, cls);
                    return GRow(
                      leading: SizedBox(
                        width: 48,
                        child: Text(hm(lesson.start), style: context.t.callout.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      title: Text(lesson.subject),
                      subtitle: mark == null ? null : Text(_dayLabel(l, cls), style: TextStyle(color: fg)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final gr in grades.take(2))
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: GradeChipOf(grade: gr),
                            ),
                          if (icon != null && grades.isEmpty) GIcon(icon, size: 20, color: fg),
                        ],
                      ),
                      onTap: cls == DayClass.absent
                          ? () => showExcuseSheet(context, studentId: studentId, lesson: lesson)
                          : null,
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _Absences extends ConsumerWidget {
  const _Absences({required this.studentId, required this.month});
  final String studentId;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final list = absencesOf(ref.watch(attendanceRecordsProvider(_monthArgs(studentId, month))).value ?? const []);
    if (list.isEmpty) return const SizedBox.shrink();
    final loc = context.localeTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p5Absences),
        GGroup(
          children: [
            for (final r in list)
              GRow(
                title: Text(r.course),
                titleMaxLines: 1,
                subtitle: Text(
                  [
                    Fmt.dayMonth(DateTime.parse(r.date), loc),
                    hm(r.start),
                    if (r.reason.isNotEmpty)
                      r.reason
                    else if (r.status == Presence.excused)
                      l.p5Excused
                    else
                      l.p5NoReason,
                  ].join(' · '),
                ),
                trailing: r.status == Presence.absent
                    ? GButton(
                        label: l.actExplain,
                        size: GButtonSize.s,
                        variant: GButtonVariant.tinted,
                        onPressed: () => showExcuseSheet(context, studentId: studentId, date: DateTime.parse(r.date)),
                      )
                    : GStatusPill(label: l.p5Excused, tone: GTone.info, icon: GIcons.excuse),
              ),
          ],
        ),
      ],
    );
  }
}
