import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import 'streaks.dart';
import 'weekly_summary.dart';

/// What the shared picture says. By default no marks: only days on time,
/// homework and a milestone (legal amendment to S11). Never a name, photo or
/// school.
class WeekCardFacts {
  const WeekCardFacts({
    required this.daysOnTime,
    required this.days,
    required this.hwDone,
    required this.hwAssigned,
    this.milestone,
    this.subjects = const [],
  });

  final int daysOnTime;
  final int days;
  final int hwDone;
  final int hwAssigned;

  /// Milestone reached this week (days).
  final int? milestone;

  /// «Алгебра · 8,5»; only when the learner switched marks on.
  final List<({String name, double avg})> subjects;

  bool get hasMarks => subjects.isNotEmpty;
}

/// Facts of the card from the weekly summary and the streaks.
WeekCardFacts weekCardFacts(WeeklySummary s, Streaks? streaks, {required bool withMarks}) {
  final reached = streaks?.milestones
      .where((m) => m.reachedAt.compareTo(s.from) >= 0 && m.reachedAt.compareTo(s.to) <= 0)
      .map((m) => m.days)
      .fold<int?>(null, (a, b) => a == null || b > a ? b : a);
  return WeekCardFacts(
    daysOnTime: s.attendance.daysOnTime,
    days: s.attendance.days,
    hwDone: s.homework.done,
    hwAssigned: s.homework.assigned,
    milestone: reached,
    subjects: withMarks
        ? [
            for (final x in s.subjects)
              if (x.avg != null) (name: x.name, avg: x.avg!),
          ]
        : const [],
  );
}

/// «Твоя неделя» on the student's «Сегодня» (S11): Friday after the last
/// lesson and weekends. Nothing is compared with other students.
class WeekCard extends ConsumerStatefulWidget {
  const WeekCard({super.key, required this.studentId, required this.lessons, required this.now});
  final String studentId;
  final List<Lesson> lessons;
  final DateTime now;

  @override
  ConsumerState<WeekCard> createState() => _WeekCardState();
}

class _WeekCardState extends ConsumerState<WeekCard> {
  final _art = GlobalKey();
  bool _marks = false;
  bool _busy = false;

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      final boundary = _art.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/gradeapp-week.png');
      await file.writeAsBytes(data!.buffer.asUint8List(), flush: true);
      GHaptics.success();
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'image/png', name: 'gradeapp-week.png')], sharePositionOrigin: origin),
      );
    } catch (_) {
      GHaptics.error();
      if (mounted) GToast.show(context, l.errorGeneric, icon: GIcons.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!weekCardVisible(widget.now, widget.lessons)) return const SizedBox.shrink();
    final week = isoWeekId(widget.now);
    final async = ref.watch(weeklySummaryProvider((studentId: widget.studentId, week: week)));
    final s = async.value;
    if (s == null || s.empty) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final streaks = ref.watch(streaksOfLearnerProvider);
    final facts = weekCardFacts(s, streaks, withMarks: _marks);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(key: _art, child: WeekCardArt(facts: facts)),
          const SizedBox(height: 8),
          GCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l.s11WithMarks, style: context.t.body)),
                    Switch.adaptive(
                      value: _marks,
                      activeTrackColor: GColors.brand,
                      onChanged: (v) => setState(() => _marks = v),
                    ),
                  ],
                ),
                if (_marks)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(l.s11MarksWarning, style: context.t.footnote.copyWith(color: c.warn)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GButton(
                  label: l.s11Save,
                  icon: GIcons.image,
                  variant: GButtonVariant.tinted,
                  loading: _busy,
                  onPressed: _share,
                ),
              ),
              const SizedBox(width: 8),
              GButton(
                label: l.p6OpenSummary,
                variant: GButtonVariant.plain,
                onPressed: () => context.push('/week-summary?student=${widget.studentId}&week=$week'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The picture itself: brand colour in both themes, no personal data.
class WeekCardArt extends StatelessWidget {
  const WeekCardArt({super.key, required this.facts});
  final WeekCardFacts facts;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = context.t;
    const on = GColors.onFill;
    final soft = on.withValues(alpha: 0.88);
    Widget stat(String big, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(big, style: t.title1.copyWith(color: on, fontSize: 34)),
          Text(label, style: t.footnote.copyWith(color: soft), maxLines: 2),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(GSpace.heroPad),
      decoration: ShapeDecoration(color: GColors.brand, shape: GRadius.surface(GRadius.hero)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GMark(size: 28, color: on),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.s11Title.toUpperCase(), style: t.eyebrow.copyWith(color: soft)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              stat('${facts.daysOnTime}/${facts.days}', l.s11DaysOnTime),
              stat('${facts.hwDone}/${facts.hwAssigned}', l.s11Homework),
            ],
          ),
          if (facts.milestone != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                GFanProgress(earned: pagesOf(facts.milestone!).toDouble(), size: 28, color: on),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.s11Milestone(facts.milestone!), style: t.bodyStrong.copyWith(color: on)),
                ),
              ],
            ),
          ],
          if (facts.hasMarks) ...[
            const SizedBox(height: 14),
            for (final x in facts.subjects.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text('${x.name} · ${fmtNum(double.parse(x.avg.toStringAsFixed(1)))}', style: t.callout.copyWith(color: on)),
              ),
          ],
        ],
      ),
    );
  }
}
