import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/grading.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import 'homework_upload.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

/// Picked attendance from the codes sheet.
typedef CodePick = ({Presence status, String code, String reason});

/// Codes sheet (§3.11): long press on a student. «Опоздал» asks for minutes;
/// then «Болеет», «Уважительная» and the school's own codes.
Future<CodePick?> showCodesSheet(
  BuildContext context, {
  required String name,
  required Grading grading,
  required RollCell cell,
  VoidCallback? onFeedback,
}) {
  final l = context.l10n;
  String codeFor(Presence p) => grading.attendanceCodes.where((c) => c.status == p).firstOrNull?.code ?? '';
  return showGSheet<CodePick>(
    context,
    title: name,
    builder: (ctx) => _CodesBody(grading: grading, cell: cell, codeFor: codeFor, l: l, onFeedback: onFeedback),
  );
}

class _CodesBody extends StatefulWidget {
  const _CodesBody({
    required this.grading,
    required this.cell,
    required this.codeFor,
    required this.l,
    this.onFeedback,
  });
  final VoidCallback? onFeedback;
  final Grading grading;
  final RollCell cell;
  final String Function(Presence) codeFor;
  final AppLocalizations l;

  @override
  State<_CodesBody> createState() => _CodesBodyState();
}

class _CodesBodyState extends State<_CodesBody> {
  bool _late = false;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _pick(Presence p, String code, [String reason = '']) {
    GHaptics.light();
    Navigator.of(context).pop((status: p, code: code, reason: reason));
  }

  void _lateBy(int m) => _pick(Presence.tardy, widget.codeFor(Presence.tardy), widget.l.lateBy(m));

  @override
  Widget build(BuildContext context) {
    final l = widget.l;
    final c = context.c;
    final cell = widget.cell;
    final std = {'Н', 'Б', 'О', 'У', 'П'};
    final own = widget.grading.attendanceCodes
        .where((x) => !std.contains(x.code) || x.status == Presence.excused)
        .toList();
    Widget row(String title, String letter, GTone tone, bool selected, VoidCallback onTap) => GRow(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: ShapeDecoration(color: tone.soft(c), shape: const StadiumBorder()),
        child: Text(
          letter,
          style: context.t.bodyStrong.copyWith(color: tone.fg(c), fontWeight: FontWeight.w800),
        ),
      ),
      title: Text(title),
      trailing: selected ? GIcon(GIcons.check, size: 20, color: c.primaryText) : null,
    );
    final list = Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GGroup(
        inset: 68,
        children: [
          row(l.codePresent, '✓', GTone.ok, cell.status == Presence.present, () => _pick(Presence.present, '')),
          row(
            l.codeAbsent,
            widget.codeFor(Presence.absent).isEmpty ? l.stateAbsent : widget.codeFor(Presence.absent),
            GTone.bad,
            cell.status == Presence.absent,
            () => _pick(Presence.absent, widget.codeFor(Presence.absent)),
          ),
          row(
            l.codeLate,
            widget.codeFor(Presence.tardy),
            GTone.warn,
            cell.status == Presence.tardy,
            () => setState(() => _late = !_late),
          ),
          if (_late)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.codeLateMinutes, style: context.t.footnote.copyWith(color: c.ink2)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final m in const [5, 10, 15]) GChip(label: l.minutesShort(m), onTap: () => _lateBy(m)),
                      SizedBox(
                        width: 96,
                        child: GField(
                          controller: _custom,
                          hint: l.codeCustom,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onSubmitted: (v) => _lateBy(int.tryParse(v) ?? 0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          for (final code in own)
            row(
              code.name,
              code.code,
              code.status == Presence.absent ? GTone.bad : GTone.warn,
              cell.code == code.code,
              () => _pick(code.status, code.code),
            ),
          if (own.every((x) => x.status != Presence.excused))
            row(l.codeExcused, 'У', GTone.info, cell.status == Presence.excused, () => _pick(Presence.excused, '')),
        ],
      ),
    );
    final feedback = widget.onFeedback;
    return feedback == null
        ? list
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              list,
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: GGroup(
                  children: [
                    GRow(
                      leading: GIcon(GIcons.chat, size: 22, color: c.primaryText),
                      title: Text(l.feedbackAction),
                      chevron: true,
                      onTap: () {
                        Navigator.of(context).pop();
                        feedback();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

/// Work type of the lesson (chosen once, remembered per course).
Future<String?> showWorkTypeSheet(BuildContext context, {required Grading grading, required String current}) {
  final types = grading.lessonTypes.isEmpty
      ? [const WorkType(code: 'fo', name: 'ФО', kind: WorkKind.formative)]
      : grading.lessonTypes;
  return showGSheet<String>(
    context,
    title: context.l10n.workType,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GGroup(
        children: [
          for (final w in types)
            GRow(
              minHeight: GSpace.rowCompact,
              title: Text(w.name),
              trailing: w.code == current ? GIcon(GIcons.check, size: 20, color: ctx.c.primaryText) : null,
              onTap: () => Navigator.of(ctx).pop(w.code),
            ),
        ],
      ),
    ),
  );
}

/// ДЗ из урока (T5, §5.2): text, due date (next lesson of the course by
/// default), time, class load against the norm. Sent through the queue.
Future<void> showHomeworkSheet(BuildContext context, {required Lesson lesson, required LessonActions actions}) {
  return showGSheet<void>(
    context,
    full: true,
    scrollable: false,
    builder: (_) => _HomeworkForm(lesson: lesson, actions: actions),
  );
}

class _HomeworkForm extends ConsumerStatefulWidget {
  const _HomeworkForm({required this.lesson, required this.actions});
  final Lesson lesson;
  final LessonActions actions;

  @override
  ConsumerState<_HomeworkForm> createState() => _HomeworkFormState();
}

class _HomeworkFormState extends ConsumerState<_HomeworkForm> {
  final _text = TextEditingController();
  DateTime? _due;
  int? _minutes = 20;
  bool _busy = false;
  final _files = <HomeworkFile>[];
  int? _uploading;

  static const _maxFiles = 10;
  static const _maxBytes = 10 * 1024 * 1024;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add(Iterable<HomeworkFile> picked) async {
    final l = context.l10n;
    for (final f in picked) {
      if (_files.length >= _maxFiles || _files.any((x) => x.path == f.path)) continue;
      if (await File(f.path).length() > _maxBytes) {
        if (mounted) GToast.show(context, l.hwFileTooBig(f.name), icon: GIcons.error);
        continue;
      }
      _files.add(f);
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickCamera() async {
    final x = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 2000, imageQuality: 85);
    if (x != null) await _add([HomeworkFile(path: x.path, name: x.name)]);
  }

  Future<void> _pickPhotos() async {
    final xs = await ImagePicker().pickMultiImage(maxWidth: 2000, imageQuality: 85);
    await _add([for (final x in xs) HomeworkFile(path: x.path, name: x.name)]);
  }

  Future<void> _pickFiles() async {
    final fs = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt', 'mp3', 'm4a', 'ogg', 'wav'],
    );
    await _add([
      for (final f in fs)
        if (f.path != null) HomeworkFile(path: f.path!, name: f.name),
    ]);
  }

  Future<void> _submit(DateTime due) async {
    final text = _text.text.trim();
    if (text.isEmpty || _busy) return;
    final l = context.l10n;
    final nav = Navigator.of(context);
    final host = nav.context;
    final target = widget.lesson.classGroupName ?? widget.lesson.subject;
    setState(() => _busy = true);
    final lines = text.split('\n');
    final title = lines.first.length > 120 ? '${lines.first.substring(0, 117)}…' : lines.first;
    String message = l.hwAssigned(target);
    var icon = GIcons.ok;
    if (_files.isEmpty) {
      await widget.actions.assignHomework(title: title, description: text, due: isoDate(due), minutes: _minutes);
    } else {
      setState(() => _uploading = 0);
      try {
        final out = await createHomeworkWithFiles(
          ref.read(dioProvider),
          widget.lesson,
          title: title,
          description: text,
          due: isoDate(due),
          minutes: _minutes,
          files: _files,
          onProgress: (sent, _) {
            if (mounted) setState(() => _uploading = sent);
          },
        );
        switch (out.state) {
          case HomeworkUpload.done:
            break;
          case HomeworkUpload.filesFailed:
            message = l.hwFilesFailed(out.failedFiles.length);
            icon = GIcons.error;
          case HomeworkUpload.offline:
            // Files cannot wait in the queue; the text can.
            await widget.actions.assignHomework(title: title, description: text, due: isoDate(due), minutes: _minutes);
            message = l.hwFilesOffline;
            icon = GIcons.error;
        }
        ref
          ..invalidate(courseHomeworkProvider(widget.lesson.courseId))
          ..invalidate(dailyLoadProvider);
      } catch (_) {
        GHaptics.error();
        if (mounted) {
          setState(() {
            _busy = false;
            _uploading = null;
          });
          GToast.show(context, l.hwFilesError, icon: GIcons.error);
        }
        return;
      }
    }
    GHaptics.success();
    nav.pop();
    if (host.mounted) GToast.show(host, message, icon: icon, bottomOffset: 100);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final lesson = widget.lesson;
    final around =
        ref.watch(courseLessonsProvider((courseId: lesson.courseId, date: lesson.date))).value ?? const <Lesson>[];
    final next = around.where((x) => x.date.compareTo(lesson.date) > 0 && !x.isCancelled).firstOrNull;
    final fallback = DateTime.parse(lesson.date).add(const Duration(days: 1));
    final due = _due ?? (next == null ? fallback : DateTime.parse(next.date));
    final previous = (ref.watch(courseHomeworkProvider(lesson.courseId)).value ?? const <Homework>[])
        .where((h) => h.dueDate.compareTo(lesson.date) <= 0)
        .fold<Homework?>(null, (best, h) => best == null || h.dueDate.compareTo(best.dueDate) > 0 ? h : best);
    final existing = (ref.watch(courseHomeworkProvider(lesson.courseId)).value ?? const <Homework>[]).where(
      (h) => h.lessonId == lesson.id,
    );
    final load = lesson.classGroupId == null
        ? null
        : ref.watch(dailyLoadProvider((classId: lesson.classGroupId!, date: isoDate(due)))).value;
    final usedWithThis = (load?.total ?? 0) + (_minutes ?? 0);
    final dayName = Fmt.weekday(due, context.localeTag);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            children: [
              Text(l.hwSheetTitle(lesson.classGroupName ?? lesson.subject), style: t.title1),
              if (existing.isNotEmpty) ...[
                const SizedBox(height: 12),
                GStateRow(
                  title: l.hwExisting,
                  message: existing.map((h) => h.title).join('; '),
                  tone: GTone.info,
                  icon: GIcons.homework,
                ),
              ],
              const SizedBox(height: 16),
              if (previous != null && _text.text.isEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: GSuggestChip(
                    label: l.sameAsLast,
                    icon: GIcons.undo,
                    onTap: () => setState(
                      () => _text.text = previous.description.isEmpty ? previous.title : previous.description,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              GField(
                controller: _text,
                hint: l.hwTextHint,
                maxLines: 6,
                minLines: 4,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GChip(
                    label: l.hwAttachCamera,
                    icon: GIcons.camera,
                    onTap: _busy ? null : () => unawaited(_pickCamera()),
                  ),
                  GChip(
                    label: l.hwAttachPhoto,
                    icon: GIcons.image,
                    onTap: _busy ? null : () => unawaited(_pickPhotos()),
                  ),
                  GChip(
                    label: l.hwAttachFile,
                    icon: GIcons.attach,
                    onTap: _busy ? null : () => unawaited(_pickFiles()),
                  ),
                ],
              ),
              if (_files.isNotEmpty) ...[
                const SizedBox(height: 8),
                GGroup(
                  inset: 48,
                  children: [
                    for (final f in _files)
                      GRow(
                        minHeight: GSpace.rowCompact,
                        leading: GIcon(_isImage(f.name) ? GIcons.image : GIcons.file, size: 20, color: c.ink2),
                        title: Text(f.name),
                        trailing: GIconButton(
                          icon: GIcons.close,
                          label: l.hwRemoveFile(f.name),
                          size: 32,
                          color: c.ink2,
                          onPressed: _busy ? null : () => setState(() => _files.remove(f)),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text(l.hwDue, style: t.subhead.copyWith(color: c.ink2)),
              const SizedBox(height: 8),
              GGroup(
                children: [
                  GRow(
                    minHeight: GSpace.rowCompact,
                    leading: GIcon(GIcons.week, size: 20, color: c.ink2),
                    title: Text(
                      _due == null && next != null
                          ? l.hwDueNextLesson(Fmt.shortWeekdayDayMonth(due, context.localeTag))
                          : Fmt.shortWeekdayDayMonth(due, context.localeTag),
                    ),
                    trailing: Text(l.hwOtherDate, style: t.callout.copyWith(color: c.primaryText)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: due,
                        firstDate: DateTime.parse(lesson.date),
                        lastDate: DateTime.parse(lesson.date).add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => _due = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(l.hwTime, style: t.subhead.copyWith(color: c.ink2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in const [10, 20, 30, 45])
                    GChip(
                      label: l.minutesShort(m),
                      selected: _minutes == m,
                      onTap: () => setState(() => _minutes = _minutes == m ? null : m),
                    ),
                ],
              ),
              if (load != null && load.norm > 0) ...[
                const SizedBox(height: 20),
                GBar(
                  value: usedWithThis / load.norm,
                  color: usedWithThis > load.norm ? GColors.warnFill : GColors.brand,
                  height: 8,
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    l.hwLoad(dayName, usedWithThis, load.norm),
                    if (usedWithThis > load.norm) l.hwOverNorm(usedWithThis - load.norm),
                  ].join(' · '),
                  style: t.footnote.copyWith(color: usedWithThis > load.norm ? c.warn : c.ink2),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: GButton(
            label: _uploading == null ? l.hwAssign : l.hwUploading(_uploading!, _files.length),
            size: GButtonSize.l,
            expand: true,
            loading: _busy,
            onPressed: _text.text.trim().isEmpty ? null : () => _submit(due),
          ),
        ),
      ],
    );
  }
}

bool _isImage(String name) => RegExp(r'\.(png|jpe?g|webp|heic)$', caseSensitive: false).hasMatch(name);

/// Итог урока (T7): what is filled, an optional note, «Завершить урок».
/// Returns true when the lesson was finished.
Future<bool> showSummarySheet(
  BuildContext context, {
  required Lesson lesson,
  required LessonActions actions,
  required int present,
  required int total,
  required bool rollSaved,
  required int grades,
  required bool hasTopic,
  required bool hasHomework,
  required VoidCallback onAddTopic,
  required VoidCallback onAddHomework,
}) async {
  final l = context.l10n;
  final note = TextEditingController(text: lesson.summary);
  final done = await showGSheet<bool>(
    context,
    title: l.sumTitle,
    bigTitle: true,
    full: true,
    builder: (ctx) {
      final c = ctx.c;
      Widget line(String title, bool ok, {VoidCallback? onAdd}) => GRow(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: ok ? c.okSoft : c.surface2, shape: BoxShape.circle),
          child: GIcon(ok ? GIcons.check : GIcons.add, size: 18, color: ok ? c.ok : c.ink3),
        ),
        title: Text(title),
        trailing: ok || onAdd == null
            ? null
            : GButton(
                label: l.add,
                size: GButtonSize.s,
                variant: GButtonVariant.tinted,
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                  onAdd();
                },
              ),
      );
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GGroup(
              inset: 60,
              children: [
                line(l.sumAttendance(present, total), rollSaved),
                line(l.sumTopic, hasTopic, onAdd: onAddTopic),
                line(l.sumHomework, hasHomework, onAdd: onAddHomework),
                line(l.sumGrades(grades), grades > 0),
              ],
            ),
            const SizedBox(height: 16),
            GField(
              controller: note,
              label: l.sumField,
              maxLines: 4,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      );
    },
    actions: Builder(
      builder: (ctx) =>
          GButton(label: l.dockFinish, size: GButtonSize.l, expand: true, onPressed: () => Navigator.of(ctx).pop(true)),
    ),
  );
  if (done != true) {
    note.dispose();
    return false;
  }
  if (note.text.trim() != lesson.summary) await actions.setSummary(note.text.trim());
  note.dispose();
  await actions.finish();
  GHaptics.success();
  return true;
}

/// Feedback to one student from the lesson: a few words, optionally marked
/// as praise or a remark. Goes through the queue like the rest.
Future<void> showFeedbackSheet(BuildContext context, {required RosterStudent student, required LessonActions actions}) {
  return showGSheet<void>(
    context,
    title: context.l10n.feedbackSheetTitle(student.name),
    builder: (_) => _FeedbackForm(student: student, actions: actions),
  );
}

class _FeedbackForm extends StatefulWidget {
  const _FeedbackForm({required this.student, required this.actions});
  final RosterStudent student;
  final LessonActions actions;

  @override
  State<_FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<_FeedbackForm> {
  final _text = TextEditingController();
  String? _tone;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final toast = context.l10n.feedbackSent(
      widget.student.firstName.isEmpty ? widget.student.name : widget.student.firstName,
    );
    final nav = Navigator.of(context);
    final host = nav.context;
    await widget.actions.feedback(widget.student.id, text, tone: _tone, name: widget.student.name);
    GHaptics.success();
    nav.pop();
    if (host.mounted) GToast.show(host, toast, bottomOffset: 100);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GField(
            controller: _text,
            hint: l.feedbackHint,
            maxLines: 5,
            minLines: 3,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              GChip(
                label: l.feedbackPraise,
                selected: _tone == 'positive',
                onTap: () => setState(() => _tone = _tone == 'positive' ? null : 'positive'),
              ),
              GChip(
                label: l.feedbackRemark,
                selected: _tone == 'negative',
                onTap: () => setState(() => _tone = _tone == 'negative' ? null : 'negative'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GButton(
            label: l.feedbackSend,
            size: GButtonSize.l,
            expand: true,
            onPressed: _text.text.trim().isEmpty ? null : () => unawaited(_send()),
          ),
        ],
      ),
    );
  }
}
