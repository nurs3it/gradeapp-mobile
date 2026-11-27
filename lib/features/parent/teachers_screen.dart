import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/presence.dart';
import '../learner/learner_providers.dart';

/// Web chat (P9, stage 3): «Написать» opens it in the browser.
const chatWebUrl = 'https://grade-app.kz/chat';

class ChildTeacher {
  const ChildTeacher({
    required this.userId,
    required this.name,
    required this.subjects,
    required this.isHomeroom,
    this.avatarUrl,
  });
  final String userId;
  final String name;
  final List<String> subjects;
  final bool isHomeroom;
  final String? avatarUrl;

  factory ChildTeacher.fromJson(Json j) => ChildTeacher(
    userId: j.str('user_id'),
    name: j.str('full_name'),
    avatarUrl: j.strOrNull('avatar_url'),
    isHomeroom: j.flag('is_homeroom'),
    subjects: [
      for (final s in (j['subjects'] as List<dynamic>? ?? const []))
        if (s is String) s else if (s is Map<String, dynamic>) s.str('name'),
    ].where((s) => s.isNotEmpty).toList(),
  );
}

/// Homeroom teacher first, then by name (the server does not sort).
List<ChildTeacher> sortTeachers(Iterable<ChildTeacher> list) => [...list]
  ..sort((a, b) {
    if (a.isHomeroom != b.isHomeroom) return a.isHomeroom ? -1 : 1;
    return a.name.compareTo(b.name);
  });

final childTeachersProvider = StreamProvider.family<List<ChildTeacher>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/students/$studentId/teachers/',
    parse: (d) => sortTeachers(parseList(d, ChildTeacher.fromJson)),
  ),
);

Future<void> openChat() => launchUrl(Uri.parse(chatWebUrl), mode: LaunchMode.externalApplication);

class _TeacherRow extends StatelessWidget {
  const _TeacherRow({required this.t});
  final ChildTeacher t;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GRow(
      minHeight: 68,
      leading: PersonAvatar(presence: t.userId.isEmpty ? null : PresenceRef.user(t.userId), name: t.name, url: t.avatarUrl, size: 44),
      title: Text(t.name),
      subtitle: Text(
        [if (t.isHomeroom) l.p9Homeroom, ...t.subjects].join(' · '),
      ),
      subtitleMaxLines: 2,
      trailing: GButton(
        label: l.p9Write,
        size: GButtonSize.s,
        variant: GButtonVariant.tinted,
        semanticLabel: l.p9WriteTo(t.name),
        onPressed: () => unawaited(openChat()),
      ),
    );
  }
}

/// «Учителя» in «Семья»: the homeroom teacher and a link to everyone.
class TeachersSection extends ConsumerWidget {
  const TeachersSection({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(childTeachersProvider(studentId)).value;
    if (list == null || list.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GSectionTitle(title: l.p9Title),
        GGroup(
          inset: 72,
          children: [
            if (list.first.isHomeroom) _TeacherRow(t: list.first),
            GRow(
              minHeight: GSpace.rowCompact,
              leading: GIcon(GIcons.teachers, size: 24, color: context.c.ink2),
              title: Text(l.p9AllTeachers(list.length)),
              chevron: true,
              onTap: () => context.push('/teachers?student=$studentId'),
            ),
          ],
        ),
      ],
    );
  }
}

class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key, this.studentId});
  final String? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final id = studentId ?? ref.watch(learnerIdProvider);
    final async = id == null ? null : ref.watch(childTeachersProvider(id));
    final list = async?.value;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: ListView(
        padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Semantics(header: true, child: Text(l.p9Title, style: context.t.title1)),
          ),
          if (list == null)
            async != null && async.hasError
                ? GEmpty(
                    error: true,
                    title: l.errorTitle,
                    message: l.errorOffline,
                    action: l.retry,
                    onAction: () => ref.invalidate(childTeachersProvider),
                  )
                : const GSkeleton(hero: false)
          else if (list.isEmpty)
            GCard(child: GEmpty(title: l.p9Empty, icon: GIcons.teachers))
          else
            GGroup(inset: 72, children: [for (final t in list) _TeacherRow(t: t)]),
        ],
      ),
    );
  }
}
