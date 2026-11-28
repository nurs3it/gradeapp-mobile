import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'lesson_widgets.dart';
import 'models.dart';
import 'school_providers.dart';

const _daysPerWeek = 6; // Mon–Sat
const _origin = 600 * _daysPerWeek; // page index of the anchor Monday

/// From this width (landscape, tablets) the week shows as day columns —
/// «Неделя целиком» (S4 variant B) — instead of one day per page.
const weekGridMinWidth = 700.0;

/// Width of one day column: a sixth of the screen, never narrower than a
/// readable lesson row (narrower screens scroll the columns sideways).
double weekColumnWidth(double available) => math.max(250, available / _daysPerWeek);

/// Week (S4, §3.3): strip of days with dots, then day pages in a PageView
/// (horizontal swipe never fights the vertical list). Shared by learners and
/// teachers; the caller supplies the data and the row.
class WeekView extends ConsumerStatefulWidget {
  const WeekView({
    super.key,
    required this.watchWeek,
    required this.rowBuilder,
    required this.onRefresh,
    this.homeworkDays,
    this.actions = const [],
  });

  final AsyncValue<List<Lesson>> Function(WidgetRef ref, String monday) watchWeek;
  final Widget Function(BuildContext context, Lesson lesson, List<Lesson> day, DateTime now) rowBuilder;
  final Future<void> Function(String monday) onRefresh;

  /// Dates (ISO) that have homework due, for the primary dot.
  final Set<String> Function(WidgetRef ref, String monday)? homeworkDays;
  final List<Widget> actions;

  @override
  ConsumerState<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends ConsumerState<WeekView> {
  late final DateTime _anchor = mondayOf(DateTime.now());
  late PageController _pages = PageController(initialPage: _todayPage);
  late int _page = _todayPage;
  final _columns = ScrollController();
  bool _wide = false;

  int get _todayPage {
    final now = DateTime.now();
    final wd = now.weekday == DateTime.sunday ? 0 : now.weekday - 1;
    // Sunday shows next Monday.
    return _origin + (now.weekday == DateTime.sunday ? _daysPerWeek : wd);
  }

  DateTime _dateOf(int page) {
    final i = page - _origin;
    final week = (i / _daysPerWeek).floor();
    final d = i - week * _daysPerWeek;
    return _anchor.add(Duration(days: week * 7 + d));
  }

  void _go(int page) {
    GHaptics.selection();
    if (_wide || !_pages.hasClients) {
      // Columns: the strip picks the week; the picked day scrolls into view.
      setState(() => _page = page);
      WidgetsBinding.instance.addPostFrameCallback((_) => _showColumn(page));
      return;
    }
    if (GMotion.reduce(context)) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(page, duration: SpringCurve.smooth.duration, curve: SpringCurve.smooth);
    }
  }

  void _showColumn(int page) {
    if (!_columns.hasClients) return;
    final i = (page - _origin) % _daysPerWeek;
    final w = weekColumnWidth(_columns.position.viewportDimension);
    final target = (i * w).clamp(0.0, _columns.position.maxScrollExtent);
    _columns.animateTo(target, duration: SpringCurve.smooth.duration, curve: SpringCurve.smooth);
  }

  @override
  void dispose() {
    _pages.dispose();
    _columns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final now = ref.now;
    final date = _dateOf(_page);
    final monday = mondayOf(date);
    final mondayIso = isoDate(monday);
    final week = widget.watchWeek(ref, mondayIso);
    final lessons = week.value ?? const <Lesson>[];
    final hwDays = widget.homeworkDays?.call(ref, mondayIso) ?? const <String>{};
    final terms = ref.watch(termsProvider).value ?? const <Term>[];
    final term = terms.where((t) => t.contains(isoDate(date))).firstOrNull;
    final range = Fmt.range(monday, monday.add(const Duration(days: _daysPerWeek - 1)), context.localeTag);
    final isToday = isoDate(date) == isoDate(now);
    final top = MediaQuery.paddingOf(context).top;
    final wide = MediaQuery.sizeOf(context).width >= weekGridMinWidth;
    if (_wide && !wide) {
      // Back to pages (rotation): open on the day the columns were showing.
      _pages.dispose();
      _pages = PageController(initialPage: _page);
    }
    _wide = wide;

    return Scaffold(
      backgroundColor: c.canvas,
      body: Padding(
        padding: EdgeInsets.only(top: top),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(g, 8, g - 2, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (term == null ? range : l.weekEyebrow(range, term.name)).toUpperCase(),
                          style: context.t.eyebrow.copyWith(color: c.ink2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Semantics(header: true, child: Text(l.tabWeek, style: context.t.largeTitle)),
                      ],
                    ),
                  ),
                  if (!isToday)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, bottom: 2),
                      child: GButton(
                        label: l.weekGoToday,
                        variant: GButtonVariant.tinted,
                        size: GButtonSize.s,
                        onPressed: () => _go(_todayPage),
                      ),
                    ),
                  for (final a in widget.actions) Padding(padding: const EdgeInsets.only(left: 6), child: a),
                ],
              ),
            ),
            _DayStrip(
              monday: monday,
              selected: date,
              today: now,
              lessons: lessons,
              hwDays: hwDays,
              onPick: (d) => _go(_page + d.difference(date).inDays),
              onWeek: (step) => _go(_page + step * _daysPerWeek),
            ),
            Expanded(
              child: wide
                  ? LayoutBuilder(
                      builder: (context, box) {
                        final w = weekColumnWidth(box.maxWidth);
                        return ListView.builder(
                          controller: _columns,
                          scrollDirection: Axis.horizontal,
                          itemCount: _daysPerWeek,
                          itemBuilder: (context, i) {
                            final d = monday.add(Duration(days: i));
                            return Container(
                              width: w,
                              decoration: isoDate(d) == isoDate(now)
                                  ? BoxDecoration(color: c.primarySoft.withValues(alpha: 0.35))
                                  : null,
                              child: _DayPage(
                                date: d,
                                now: now,
                                watchWeek: widget.watchWeek,
                                rowBuilder: widget.rowBuilder,
                                onRefresh: widget.onRefresh,
                              ),
                            );
                          },
                        );
                      },
                    )
                  : PageView.builder(
                      controller: _pages,
                      onPageChanged: (p) => setState(() => _page = p),
                      itemBuilder: (context, page) => _DayPage(
                        date: _dateOf(page),
                        now: now,
                        watchWeek: widget.watchWeek,
                        rowBuilder: widget.rowBuilder,
                        onRefresh: widget.onRefresh,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({
    required this.monday,
    required this.selected,
    required this.today,
    required this.lessons,
    required this.hwDays,
    required this.onPick,
    required this.onWeek,
  });

  final DateTime monday;
  final DateTime selected;
  final DateTime today;
  final List<Lesson> lessons;
  final Set<String> hwDays;
  final ValueChanged<DateTime> onPick;
  final ValueChanged<int> onWeek;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final t = context.t;
    final l = context.l10n;
    final g = GSpace.gutter(context);
    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() > 250) onWeek(v < 0 ? 1 : -1);
      },
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l.weekPrev): () => onWeek(-1),
          CustomSemanticsAction(label: l.weekNext): () => onWeek(1),
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(g - 4, 0, g - 4, 8),
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                for (var i = 0; i < _daysPerWeek; i++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final d = monday.add(Duration(days: i));
                        final iso = isoDate(d);
                        final sel = iso == isoDate(selected);
                        final isToday = iso == isoDate(today);
                        final dayLessons = lessons.where((x) => x.date == iso);
                        final dots = [
                          if (dayLessons.any((x) => x.isCancelled)) c.warn,
                          if (hwDays.contains(iso)) GColors.brand,
                        ];
                        final fg = sel ? c.canvas : (isToday ? c.primaryText : c.ink);
                        return GPressable(
                          onTap: () => onPick(d),
                          scale: 0.94,
                          selected: sel,
                          semanticLabel: [
                            Fmt.weekdayDayMonth(d, context.localeTag),
                            if (dots.contains(c.warn)) l.dotChanges,
                            if (hwDays.contains(iso)) l.dotHomework,
                          ].join(', '),
                          excludeChildSemantics: true,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: ShapeDecoration(
                              color: sel ? c.ink : Colors.transparent,
                              shape: GRadius.surface(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Fmt.weekdayShort(d, context.localeTag).toUpperCase(),
                                  style: t.caption.copyWith(color: sel ? c.canvas : c.ink2),
                                  textScaler: TextScaler.noScaling,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${d.day}',
                                  style: t.title2.copyWith(fontWeight: FontWeight.w800, color: fg),
                                  textScaler: TextScaler.noScaling,
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 5,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      for (final dot in dots)
                                        Container(
                                          width: 5,
                                          height: 5,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                          decoration: BoxDecoration(
                                            color: sel ? c.canvas : dot,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPage extends ConsumerWidget {
  const _DayPage({
    required this.date,
    required this.now,
    required this.watchWeek,
    required this.rowBuilder,
    required this.onRefresh,
  });

  final DateTime date;
  final DateTime now;
  final AsyncValue<List<Lesson>> Function(WidgetRef ref, String monday) watchWeek;
  final Widget Function(BuildContext context, Lesson lesson, List<Lesson> day, DateTime now) rowBuilder;
  final Future<void> Function(String monday) onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final monday = isoDate(mondayOf(date));
    final week = watchWeek(ref, monday);
    final iso = isoDate(date);
    final day = (week.value ?? const <Lesson>[]).where((x) => x.date == iso).toList();
    final active = day.where((x) => !x.isCancelled).toList();
    final bottom = GSpace.contentBottom + MediaQuery.paddingOf(context).bottom;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        GRefreshControl(onRefresh: () => onRefresh(monday)),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(g, 8, g, bottom),
          sliver: SliverList.list(
            children: [
              Text(Fmt.weekdayDayMonth(date, context.localeTag), style: context.t.title2),
              if (active.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 10),
                  child: Text(
                    l.weekDaySpan(l.lessonsCount(active.length), hm(active.first.start), hm(active.last.end)),
                    style: context.t.footnote.copyWith(color: c.ink2),
                  ),
                )
              else
                const SizedBox(height: 10),
              if (week.isLoading && !week.hasValue)
                const GSkeleton(hero: false, rows: 5)
              else if (week.hasError && !week.hasValue)
                GEmpty(
                  error: true,
                  title: l.errorTitle,
                  message: l.errorOffline,
                  action: l.retry,
                  onAction: () => onRefresh(monday),
                )
              else if (day.isEmpty)
                GEmpty(title: l.weekNoLessons, message: l.weekNoLessonsHint)
              else
                // Today's running lesson is tinted and carries «сейчас».
                GGroup(inset: 76, children: lessonRowsWithBreaks(day, (x) => rowBuilder(context, x, day, now))),
            ],
          ),
        ),
      ],
    );
  }
}
