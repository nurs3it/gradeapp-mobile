import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/school_providers.dart';
import '../learner/weekly_summary.dart';

/// Parent «Сегодня» entries: attendance of the child, and the weekly summary
/// from Friday to Sunday (P5, P6).
class ParentTodayEntries extends ConsumerWidget {
  const ParentTodayEntries({super.key, required this.studentId, required this.now});
  final String studentId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final digest = ref.watch(mobileFlagsProvider).weeklyDigestEnabled;
    final weekend = now.weekday >= DateTime.friday;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: GSpace.stackGap),
        GGroup(
          inset: 52,
          children: [
            if (digest && weekend)
              GRow(
                leading: GIcon(GIcons.summary, size: 22, color: c.primaryText),
                title: Text(l.p6TodayCard),
                subtitle: Text(l.p6TodayCardHint),
                chevron: true,
                onTap: () => context.push('/week-summary?student=$studentId&week=${isoWeekId(now)}'),
              ),
            GRow(
              leading: GIcon(GIcons.week, size: 22, color: c.primaryText),
              title: Text(l.p5Title),
              subtitle: Text(l.p5RowHint),
              chevron: true,
              onTap: () => context.push('/attendance?student=$studentId'),
            ),
          ],
        ),
      ],
    );
  }
}
