import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../learner/learner_providers.dart';
import '../learner/weekly_summary.dart';

/// Tone of the verdict sheet.
GTone weekVerdictTone(WeekVerdictCode code) => switch (code) {
  WeekVerdictCode.great => GTone.ok,
  WeekVerdictCode.steady => GTone.info,
  WeekVerdictCode.empty => GTone.neutral,
  _ => GTone.warn,
};

/// The one-sentence verdict (P6). Gentle for the learner who reads it too.
String weekVerdictText(AppLocalizations l, WeekVerdict v) => switch (v.code) {
  WeekVerdictCode.empty => l.p6VerdictEmpty,
  WeekVerdictCode.great => l.p6VerdictGreat,
  WeekVerdictCode.steady => l.p6VerdictSteady,
  WeekVerdictCode.absences => l.p6VerdictAbsences,
  WeekVerdictCode.overdue => l.p6VerdictOverdue,
  WeekVerdictCode.dip =>
    (v.courseName ?? '').isEmpty ? l.p6VerdictDipPlain : l.p6VerdictDip(v.courseName!),
};

/// Weekly summary (P6): verdict first, then the facts; swipe or arrows to go
/// back in time. Opened from «Сегодня», «Семья», the `digest.weekly` push.
class WeeklySummaryScreen extends ConsumerStatefulWidget {
  const WeeklySummaryScreen({super.key, this.studentId, this.week});
  final String? studentId;
  final String? week;

  @override
  ConsumerState<WeeklySummaryScreen> createState() => _State();
}

class _State extends ConsumerState<WeeklySummaryScreen> {
  final _pages = PageController();
  late final String _base = (widget.week != null && mondayOfIsoWeek(widget.week!) != null)
      ? widget.week!
      : isoWeekId(DateTime.now());
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i < 0 || i > summaryWeeksBack) return;
    GHaptics.selection();
    _pages.animateToPage(i, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final id = widget.studentId ?? ref.watch(learnerIdProvider);
    final week = shiftIsoWeek(_base, -_index);
    final monday = mondayOfIsoWeek(week)!;
    final range = Fmt.range(monday, monday.add(const Duration(days: 6)), context.localeTag);
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back, title: l.p6Title),
      body: id == null
          ? const Center(child: GLoader())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: GSpace.gutter(context) - 8),
                  child: Row(
                    children: [
                      GIconButton(
                        icon: GIcons.back,
                        label: l.p6PrevWeek,
                        size: 40,
                        background: c.surface,
                        onPressed: _index >= summaryWeeksBack ? null : () => _go(_index + 1),
                      ),
                      Expanded(
                        child: Text(
                          range,
                          textAlign: TextAlign.center,
                          style: context.t.headline,
                          semanticsLabel: l.p6WeekOf(range),
                        ),
                      ),
                      GIconButton(
                        icon: GIcons.chevron,
                        label: l.p6NextWeek,
                        size: 40,
                        background: c.surface,
                        onPressed: _index == 0 ? null : () => _go(_index - 1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pages,
                    reverse: true,
                    itemCount: summaryWeeksBack + 1,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => _WeekPage(studentId: id, week: shiftIsoWeek(_base, -i)),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WeekPage extends ConsumerWidget {
  const _WeekPage({required this.studentId, required this.week});
  final String studentId;
  final String week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final g = GSpace.gutter(context);
    final async = ref.watch(weeklySummaryProvider((studentId: studentId, week: week)));
    final s = async.value;
    final pad = EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom);
    if (s == null) {
      return ListView(
        padding: pad,
        children: [
          async.hasError
              ? GEmpty(
                  error: true,
                  title: l.errorTitle,
                  message: l.errorOffline,
                  action: l.retry,
                  onAction: () => ref.invalidate(weeklySummaryProvider),
                )
              : const GSkeleton(),
        ],
      );
    }
    if (s.empty) {
      return ListView(padding: pad, children: [GEmpty(title: l.p6EmptyTitle, message: l.p6EmptyBody, icon: GIcons.clock)]);
    }
    return ListView(
      padding: pad,
      children: [
        _VerdictSheet(summary: s),
        _Attendance(a: s.attendance),
        if (s.subjects.isNotEmpty) _Grades(s: s),
        if (s.homework.assigned > 0) _Homework(h: s.homework),
        if (s.feedback.isNotEmpty) _Feedback(list: s.feedback),
        if (s.assessments.isNotEmpty || s.events.isNotEmpty) _Upcoming(s: s),
      ],
    );
  }
}

class _VerdictSheet extends StatelessWidget {
  const _VerdictSheet({required this.summary});
  final WeeklySummary summary;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final tone = weekVerdictTone(summary.verdict.code);
    final text = weekVerdictText(l, summary.verdict);
    return Container(
      padding: const EdgeInsets.all(GSpace.heroPad),
      decoration: ShapeDecoration(color: tone.soft(c), shape: GRadius.surface(GRadius.hero)),
      child: Semantics(
        container: true,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: tone.fill(c), shape: BoxShape.circle),
              child: GIcon(
                tone == GTone.ok ? GIcons.ok : GIcons.info,
                size: 24,
                color: GColors.onFill,
                fill: 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: context.t.title2)),
          ],
        ),
      ),
    );
  }
}

class _Attendance extends StatelessWidget {
  const _Attendance({required this.a});
  final WeekAttendance a;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    Widget row(String title, String value, {GTone? tone}) => GRow(
      minHeight: GSpace.rowCompact,
      title: Text(title),
      trailing: Text(value, style: context.t.bodyStrong.copyWith(color: tone?.fg(c))),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p6Attendance),
        GGroup(
          children: [
            row(l.p6DaysOnTime, l.p6OfDays(a.daysOnTime, a.days)),
            if (a.tardy > 0) row(l.p6Tardy, '${a.tardy}', tone: GTone.warn),
            if (a.absent > 0) row(l.p6Absent, '${a.absent}', tone: GTone.bad),
            if (a.excused > 0) row(l.p6Excused, '${a.excused}'),
          ],
        ),
      ],
    );
  }
}

class _Grades extends ConsumerWidget {
  const _Grades({required this.s});
  final WeeklySummary s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p6Grades, trailing: Text(l.p6GradesCount(s.gradesCount), style: t.footnote.copyWith(color: c.ink2))),
        GGroup(
          inset: 33,
          children: [
            for (final x in s.subjects)
              GRow(
                marker: c.subjectMarker(x.name),
                title: Text(x.name),
                subtitle: Text(x.items.map((i) => i.value).join(' · ')),
                trailing: _Delta(delta: x.delta, avg: x.avg),
              ),
          ],
        ),
      ],
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.delta, required this.avg});
  final double? delta;
  final double? avg;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final sign = deltaSign(delta);
    final (IconData icon, Color color) = switch (sign) {
      1 => (Icons.arrow_upward_rounded, c.ok),
      -1 => (Icons.arrow_downward_rounded, c.warn),
      _ => (Icons.remove_rounded, c.ink3),
    };
    final avgText = avg == null ? '—' : fmtNum(double.parse(avg!.toStringAsFixed(1)));
    final deltaText = delta == null || sign == 0
        ? null
        : '${sign > 0 ? '+' : '−'}${fmtNum(double.parse(delta!.abs().toStringAsFixed(1)))}';
    return Semantics(
      label: [
        l.p6Avg(avgText),
        if (sign > 0) l.p6Up(deltaText!) else if (sign < 0) l.p6Down(deltaText!) else l.p6Same,
      ].join(', '),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GIcon(icon, size: 18, color: color),
          if (deltaText != null)
            Padding(
              padding: const EdgeInsets.only(left: 2, right: 8),
              child: Text(deltaText, style: context.t.footnote.copyWith(color: color, fontWeight: FontWeight.w700)),
            )
          else
            const SizedBox(width: 8),
          Text(avgText, style: context.t.title2),
        ],
      ),
    );
  }
}

class _Homework extends StatelessWidget {
  const _Homework({required this.h});
  final WeekHomework h;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p6Homework),
        GGroup(
          children: [
            GRow(
              minHeight: GSpace.rowCompact,
              title: Text(l.p6HwDone),
              trailing: Text(l.p6OfTotal(h.done, h.assigned), style: context.t.bodyStrong),
            ),
            if (h.overdue > 0)
              GRow(
                minHeight: GSpace.rowCompact,
                title: Text(l.p6HwOverdue),
                trailing: Text('${h.overdue}', style: context.t.bodyStrong.copyWith(color: c.warn)),
              ),
          ],
        ),
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.list});
  final List<WeekFeedback> list;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p6Feedback),
        GGroup(
          children: [
            for (final f in list)
              GRow(
                leading: GIcon(
                  f.positive ? GIcons.ok : GIcons.info,
                  size: 22,
                  color: f.positive ? c.ok : c.warn,
                  fill: 1,
                ),
                title: Text(f.text.isEmpty ? (f.positive ? l.p6Praise : l.p6Remark) : f.text),
                titleMaxLines: 3,
                subtitle: Text([f.from, Fmt.dayMonth(DateTime.parse(f.date), context.localeTag)].where((x) => x.isNotEmpty).join(' · ')),
              ),
          ],
        ),
      ],
    );
  }
}

class _Upcoming extends StatelessWidget {
  const _Upcoming({required this.s});
  final WeeklySummary s;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final loc = context.localeTag;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p6Upcoming),
        GGroup(
          children: [
            for (final a in s.assessments)
              GRow(
                leading: GTypeBadge(label: a.kind == 'sor' ? l.kindSor : l.kindSoch, kind: a.kind),
                title: Text(a.courseName),
                subtitle: Text(
                  [Fmt.shortWeekdayDayMonth(DateTime.parse(a.date), loc), if (a.title.isNotEmpty) a.title].join(' · '),
                ),
              ),
            for (final e in s.events)
              GRow(
                leading: GIcon(GIcons.school, size: 22, color: context.c.ink2),
                title: Text(e.title),
                subtitle: Text(Fmt.shortWeekdayDayMonth(DateTime.parse(e.startDate), loc)),
              ),
          ],
        ),
      ],
    );
  }
}
