import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../common/presence.dart';
import '../shell/header.dart';

/// A teacher's word to the student (`/feedback/`): praise, a remark or plain.
class TeacherFeedback {
  const TeacherFeedback({
    required this.id,
    required this.fromUserId,
    required this.fromName,
    required this.text,
    required this.date,
    this.fromAvatarUrl,
    this.praise = false,
    this.remark = false,
  });

  final String id;
  final String fromUserId;
  final String fromName;
  final String? fromAvatarUrl;
  final String text;
  final String date;
  final bool praise;
  final bool remark;

  factory TeacherFeedback.fromJson(Json j) {
    final tags = j.strings('tags');
    return TeacherFeedback(
      id: j.str('id'),
      fromUserId: j.str('from_user'),
      fromName: j.str('from_user_name'),
      fromAvatarUrl: j.strOrNull('from_user_avatar_url'),
      text: j.str('text'),
      date: j.str('date'),
      praise: tags.contains('positive'),
      remark: tags.contains('negative'),
    );
  }
}

/// Newest first; students and parents get only their own (server-scoped).
final feedbackProvider = StreamProvider.family<List<TeacherFeedback>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/feedback/',
    query: {'student_id': studentId, 'page_size': 100},
    parse: (d) => parseList(d, TeacherFeedback.fromJson)..sort((a, b) => b.date.compareTo(a.date)),
  ),
);

/// Feedback inside a quarter, newest first.
List<TeacherFeedback> feedbackIn(List<TeacherFeedback> all, Term term) =>
    all.where((f) => term.contains(f.date)).toList();

/// «Отзывы учителей»: the last few words of the quarter in view.
class FeedbackSection extends ConsumerWidget {
  const FeedbackSection({super.key, required this.studentId, required this.term, this.limit = 5});
  final String studentId;
  final Term term;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(feedbackProvider(studentId)).value ?? const <TeacherFeedback>[];
    final list = feedbackIn(all, term);
    if (list.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GSectionTitle(title: l.feedbackTitle),
        GGroup(
          inset: 68,
          children: [
            for (final f in list.take(limit))
              GRow(
                minHeight: GSpace.rowCompact,
                titleMaxLines: 1,
                subtitleMaxLines: 6,
                leading: PersonAvatar(
                  presence: PresenceRef.user(f.fromUserId),
                  name: f.fromName,
                  url: f.fromAvatarUrl,
                  size: 40,
                  color: childColor(f.fromUserId),
                ),
                title: Text(
                  '${f.fromName} · ${Fmt.dayMonth(DateTime.parse(f.date), context.localeTag)}',
                  style: t.footnote.copyWith(color: c.ink2),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.text, style: t.callout.copyWith(color: c.ink)),
                    if (f.praise || f.remark) ...[
                      const SizedBox(height: 6),
                      GStatusPill(
                        label: f.praise ? l.feedbackPraise : l.feedbackRemark,
                        tone: f.praise ? GTone.ok : GTone.warn,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
