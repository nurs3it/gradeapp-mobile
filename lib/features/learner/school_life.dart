import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../chat/chat_screens.dart' show absoluteMediaUrl;
import '../common/models.dart';
import 'learner_providers.dart';

/// S13 «Школьная жизнь» (cafeteria menu, class birthdays) and S12 points.
/// Each block shows only when the school has data for it: the role
/// permissions (`nav.menu`, `nav.gamification`) are on for every school.

class CafeteriaMenu {
  const CafeteriaMenu({required this.title, required this.items, this.fileUrl});
  final String title;
  final List<String> items;

  /// The first attachment (a photo or PDF of the menu), when there is one.
  final String? fileUrl;

  factory CafeteriaMenu.fromJson(Json j) => CafeteriaMenu(
    title: j.str('title'),
    items: j.str('items').split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    fileUrl: (j['attachments'] as List<dynamic>? ?? const []).whereType<Json>().map((a) => a.str('file_url')).firstOrNull,
  );

  bool get isEmpty => items.isEmpty && fileUrl == null && title.isEmpty;
}

final menuProvider = StreamProvider.family<CafeteriaMenu?, String>(
  (ref, date) => cachedGet(
    ref,
    '/engagement/menu/',
    query: {'date_from': date, 'date_to': date},
    parse: (d) => parseList(d, CafeteriaMenu.fromJson).where((m) => !m.isEmpty).firstOrNull,
  ),
);

class Birthday {
  const Birthday({required this.studentId, required this.name, required this.inDays});
  final String studentId;
  final String name;
  final int inDays;

  factory Birthday.fromJson(Json j) =>
      Birthday(studentId: j.str('student_id'), name: j.str('name'), inDays: (j.number('in_days') ?? 99).toInt());

  /// The server's `get_full_name()` is «Имя Отчество Фамилия».
  String get firstName => name.split(' ').firstWhere((s) => s.isNotEmpty, orElse: () => name);
}

/// Classmates' birthdays today and tomorrow (the server sends day and month only).
final birthdaysProvider = StreamProvider<List<Birthday>>(
  (ref) => cachedGet(
    ref,
    '/engagement/birthdays/',
    query: const {'days': 1},
    parse: (d) => parseList(d, Birthday.fromJson),
  ),
);

class PointsEntry {
  const PointsEntry({required this.points, required this.reason, this.at});
  final int points;
  final String reason;
  final DateTime? at;

  factory PointsEntry.fromJson(Json j) => PointsEntry(
    points: (j.number('points') ?? 0).toInt(),
    reason: j.str('reason'),
    at: DateTime.tryParse(j.str('created_at'))?.toLocal(),
  );
}

final pointsProvider = StreamProvider.family<List<PointsEntry>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/engagement/points/',
    query: {'student': studentId, 'page_size': 200},
    parse: (d) => parseList(d, PointsEntry.fromJson)..sort((a, b) => (b.at ?? DateTime(2000)).compareTo(a.at ?? DateTime(2000))),
  ),
);

/// The student's place in the class rating — shown to the student only.
final classRankProvider = StreamProvider.family<int?, ({String studentId, String classGroupId})>(
  (ref, a) => cachedGet(
    ref,
    '/engagement/leaderboard/',
    query: {'class_group_id': a.classGroupId, 'limit': 200},
    parse: (d) => resultsOf(d).where((r) => r.str('student_id') == a.studentId).map((r) => r.number('rank')?.toInt()).firstOrNull,
  ),
);

/// The learner's own class: the class most of the week's lessons belong to
/// (a joint lesson can carry another class first).
String? mainClassOf(List<Lesson> lessons) {
  final counts = <String, int>{};
  for (final l in lessons) {
    final id = l.classGroupId;
    if (id != null) counts[id] = (counts[id] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
}

/// «Столовая сегодня» on «Сегодня».
class MenuCard extends ConsumerWidget {
  const MenuCard({super.key, required this.date});
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menu = ref.watch(menuProvider(date)).value;
    if (menu == null) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final file = menu.fileUrl;
    return Padding(
      padding: const EdgeInsets.only(top: GSpace.stackGap),
      child: GCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.slMenuTitle.toUpperCase(), style: t.eyebrow.copyWith(color: c.ink2)),
            if (menu.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(menu.title, style: t.headline),
            ],
            if (menu.items.isNotEmpty) ...[
              const SizedBox(height: 6),
              for (final item in menu.items.take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text('· $item', style: t.body.copyWith(color: c.ink)),
                ),
            ],
            if (file != null) ...[
              const SizedBox(height: 8),
              GButton(
                label: l.slMenuFile,
                icon: GIcons.file,
                variant: GButtonVariant.tinted,
                size: GButtonSize.s,
                onPressed: () => unawaited(launchUrl(Uri.parse(absoluteMediaUrl(file)), mode: LaunchMode.externalApplication)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One line about classmates' birthdays today or tomorrow.
class BirthdayLine extends ConsumerWidget {
  const BirthdayLine({super.key, required this.myStudentId});
  final String? myStudentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(birthdaysProvider).value ?? const <Birthday>[];
    if (list.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final mine = list.any((b) => b.studentId == myStudentId && b.inDays == 0);
    final others = list.where((b) => b.studentId != myStudentId);
    final today = others.where((b) => b.inDays == 0).map((b) => b.firstName).toList();
    final tomorrow = others.where((b) => b.inDays == 1).map((b) => b.firstName).toList();
    final text = mine
        ? l.slBirthdayMine
        : today.isNotEmpty
        ? l.slBirthdayToday(today.join(', '))
        : tomorrow.isNotEmpty
        ? l.slBirthdayTomorrow(tomorrow.join(', '))
        : null;
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: GSpace.stackGap),
      child: GCard(
        color: context.c.goldSoft,
        child: Row(
          children: [
            const Text('🎂', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: context.t.bodyStrong.copyWith(color: context.c.goldText))),
          ],
        ),
      ),
    );
  }
}

/// S12: total points (and, for the student, the place in class) with the history.
class PointsCard extends ConsumerWidget {
  const PointsCard({super.key, required this.studentId, this.showRank = false});
  final String studentId;
  final bool showRank;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(pointsProvider(studentId)).value ?? const <PointsEntry>[];
    if (entries.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final total = entries.fold<int>(0, (s, e) => s + e.points);
    final monday = isoDate(mondayOf(DateTime.now()));
    final classId = showRank
        ? mainClassOf(ref.watch(weekLessonsProvider((studentId: studentId, monday: monday))).value ?? const [])
        : null;
    final rank = classId == null ? null : ref.watch(classRankProvider((studentId: studentId, classGroupId: classId))).value;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GGroup(
        children: [
          GRow(
            minHeight: 64,
            leading: const Text('⭐', style: TextStyle(fontSize: 24)),
            title: Text(l.slPointsTotal(total)),
            subtitle: Text(rank == null ? l.slPoints : l.slRank(rank)),
            chevron: true,
            onTap: () => showGSheet<void>(
              context,
              title: l.slPointsHistory,
              builder: (ctx) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: GGroup(
                  children: [
                    for (final e in entries.take(50))
                      GRow(
                        title: Text(e.reason.isEmpty ? l.slPoints : e.reason),
                        subtitle: e.at == null ? null : Text(Fmt.dayMonth(e.at!, ctx.localeTag)),
                        trailing: Text(
                          e.points > 0 ? '+${e.points}' : '${e.points}',
                          style: ctx.t.headline.copyWith(color: e.points >= 0 ? c.ok : c.bad),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
