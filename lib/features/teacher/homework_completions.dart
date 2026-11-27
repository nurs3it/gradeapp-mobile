import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';

/// One student in `GET /homework/{id}/completions/`.
class CompletionRow {
  const CompletionRow({required this.studentId, required this.name, required this.done, this.doneAt});
  final String studentId;
  final String name;
  final bool done;
  final DateTime? doneAt;

  factory CompletionRow.fromJson(Json j) => CompletionRow(
    studentId: j.str('student_id'),
    name: j.str('name'),
    done: j.flag('done'),
    doneAt: DateTime.tryParse(j.str('done_at'))?.toLocal(),
  );
}

/// T12 «Выполнили 18 из 26».
class HomeworkCompletions {
  const HomeworkCompletions({
    required this.homeworkId,
    required this.done,
    required this.total,
    this.students = const [],
  });
  final String homeworkId;
  final int done;
  final int total;
  final List<CompletionRow> students;

  /// Who has not done it, by name.
  List<CompletionRow> get notDone => students.where((s) => !s.done).toList()..sort((a, b) => a.name.compareTo(b.name));

  bool get allDone => total > 0 && done >= total;

  factory HomeworkCompletions.fromJson(Json j) {
    final rows = j.list('students', CompletionRow.fromJson);
    return HomeworkCompletions(
      homeworkId: j.str('homework_id'),
      done: (j.number('done_count') ?? rows.where((r) => r.done).length).toInt(),
      total: (j.number('students_count') ?? rows.length).toInt(),
      students: rows,
    );
  }
}

final homeworkCompletionsProvider = StreamProvider.family<HomeworkCompletions, String>(
  (ref, id) => cachedGet(ref, '/homework/$id/completions/', parse: (d) => HomeworkCompletions.fromJson(d as Json)),
);

/// What came of «Напомнить».
sealed class RemindResult {
  const RemindResult();
}

class Reminded extends RemindResult {
  const Reminded(this.notified);
  final int notified;
}

/// 429 `reminder_too_soon`: once an hour per homework.
class RemindTooSoon extends RemindResult {
  const RemindTooSoon();
}

class RemindFailed extends RemindResult {
  const RemindFailed();
}

/// Reads the answer of `POST /homework/{id}/remind/` (or its error).
RemindResult remindResultOf({Object? data, Object? error}) {
  if (error != null) {
    if (error is DioException && error.response?.statusCode == 429) return const RemindTooSoon();
    return const RemindFailed();
  }
  final n = data is Map ? (data['notified'] as num?)?.toInt() : null;
  return n == null ? const RemindFailed() : Reminded(n);
}

Future<RemindResult> remindHomework(Dio dio, String homeworkId) async {
  try {
    final res = await dio.post<Object?>('/homework/$homeworkId/remind/');
    return remindResultOf(data: res.data);
  } catch (e) {
    return remindResultOf(error: e);
  }
}

/// «Выполнили 18 из 26», the list of who has not done it and «Напомнить».
/// Sits under a homework of the lesson in the ДЗ sheet.
class HomeworkCompletionsCard extends ConsumerStatefulWidget {
  const HomeworkCompletionsCard({super.key, required this.homework});
  final Homework homework;

  @override
  ConsumerState<HomeworkCompletionsCard> createState() => _HomeworkCompletionsCardState();
}

class _HomeworkCompletionsCardState extends ConsumerState<HomeworkCompletionsCard> {
  bool _open = false;
  bool _busy = false;

  Future<void> _remind() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l = context.l10n;
    final result = await remindHomework(ref.read(dioProvider), widget.homework.id);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Reminded(:final notified):
        GHaptics.success();
        GToast.show(context, l.t12Reminded(notified), bottomOffset: 100);
      case RemindTooSoon():
        GHaptics.warning();
        GToast.show(context, l.t12TooSoon, icon: GIcons.clock, bottomOffset: 100);
      case RemindFailed():
        GHaptics.error();
        GToast.show(context, l.t12RemindFailed, icon: GIcons.error, bottomOffset: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final async = ref.watch(homeworkCompletionsProvider(widget.homework.id));
    final data = async.value;
    if (data == null) {
      // Loading is a quiet line; a failure keeps the sheet usable without it.
      return async.hasError
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(l.t12Loading, style: t.footnote.copyWith(color: c.ink3)),
            );
    }
    final missing = data.notDone;
    final summary = l.t12Done(data.done, data.total);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GCard(
        color: c.surface2,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              container: true,
              label: summary,
              child: GPressable(
                onTap: missing.isEmpty
                    ? null
                    : () {
                        GHaptics.selection();
                        setState(() => _open = !_open);
                      },
                semanticLabel: missing.isEmpty ? summary : '$summary, ${l.t12NotDone(missing.length)}',
                excludeChildSemantics: true,
                scale: 0.99,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Row(
                    children: [
                      GIcon(
                        data.allDone ? GIcons.ok : GIcons.homework,
                        size: 22,
                        color: data.allDone ? c.ok : c.ink2,
                        fill: data.allDone ? 1 : 0,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(summary, style: t.bodyStrong),
                            if (data.total > 0) ...[
                              const SizedBox(height: 6),
                              GBar(value: data.done / data.total, color: data.allDone ? c.ok : GColors.brand),
                            ],
                          ],
                        ),
                      ),
                      if (missing.isNotEmpty)
                        AnimatedRotation(
                          turns: _open ? 0.5 : 0,
                          duration: GMotion.reduce(context) ? Duration.zero : GMotion.quick,
                          child: GIcon(GIcons.expand, size: 22, color: c.ink3),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (_open && missing.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
                child: Text(l.t12NotDone(missing.length), style: t.subhead.copyWith(color: c.ink2)),
              ),
              for (final s in missing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 3, 14, 3),
                  child: Text(s.name, style: t.body),
                ),
              const SizedBox(height: 6),
            ],
            if (missing.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: GButton(
                  label: l.t12Remind,
                  icon: GIcons.bell,
                  size: GButtonSize.s,
                  variant: GButtonVariant.tinted,
                  loading: _busy,
                  expand: true,
                  onPressed: () => unawaited(_remind()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
