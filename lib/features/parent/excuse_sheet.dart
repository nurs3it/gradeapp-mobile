import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/models.dart';
import '../learner/learner_providers.dart';

/// Requests of one child (newest first).
final excusesProvider = StreamProvider.family<List<Excuse>, String>(
  (ref, studentId) => cachedGet(
    ref,
    '/excuses/',
    query: {'student': studentId, 'page_size': 50},
    parse: (d) => parseList(d, Excuse.fromJson)..sort((a, b) => b.startDate.compareTo(a.startDate)),
  ),
);

String categoryName(AppLocalizations l, String c) => switch (c) {
  'illness' => l.catIllness,
  'family' => l.catFamily,
  'appointment' => l.catAppointment,
  _ => l.catOther,
};

/// «Отпросить» (P4, §4.3): sensible defaults (today, whole day, illness), one
/// screen, optional note photo. [lesson] preselects «Уроки» with it.
Future<void> showExcuseSheet(BuildContext context, {required String studentId, Lesson? lesson}) {
  return showGSheet<void>(
    context,
    full: true,
    scrollable: false,
    closeLabel: context.l10n.cancel,
    builder: (_) => _ExcuseForm(studentId: studentId, lesson: lesson),
  );
}

enum _When { today, tomorrow, dates, lessons }

class _ExcuseForm extends ConsumerStatefulWidget {
  const _ExcuseForm({required this.studentId, this.lesson});
  final String studentId;
  final Lesson? lesson;

  @override
  ConsumerState<_ExcuseForm> createState() => _ExcuseFormState();
}

class _ExcuseFormState extends ConsumerState<_ExcuseForm> {
  late _When _when = widget.lesson == null ? _When.today : _When.lessons;
  String _category = 'illness';
  final _comment = TextEditingController();
  late DateTime _from = DateTime.now();
  late DateTime _to = DateTime.now();
  late final Set<String> _lessons = {?widget.lesson?.id};
  XFile? _proof;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final photo = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 80);
    if (photo != null) setState(() => _proof = photo);
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? _from : _to,
      firstDate: now.subtract(const Duration(days: 14)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
  }

  Future<void> _send() async {
    final l = context.l10n;
    if (_when == _When.lessons && _lessons.isEmpty) {
      setState(() => _error = l.excusePickLessons);
      return;
    }
    final now = DateTime.now();
    final lessonDate = widget.lesson?.date ?? isoDate(now);
    final (from, to) = switch (_when) {
      _When.today => (isoDate(now), isoDate(now)),
      _When.tomorrow => (isoDate(now.add(const Duration(days: 1))), isoDate(now.add(const Duration(days: 1)))),
      _When.dates => (isoDate(_from), isoDate(_to)),
      _When.lessons => (lessonDate, lessonDate),
    };
    final form = FormData()
      ..fields.addAll([
        MapEntry('student', widget.studentId),
        MapEntry('scope', _when == _When.lessons ? 'specific_lessons' : 'full_days'),
        MapEntry('start_date', from),
        MapEntry('end_date', to),
        MapEntry('category', _category),
        if (_comment.text.trim().isNotEmpty) MapEntry('reason', _comment.text.trim()),
        if (_when == _When.lessons)
          for (final id in _lessons) MapEntry('lesson_ids', id),
      ]);
    if (_proof != null) {
      form.files.add(MapEntry('attachment', await MultipartFile.fromFile(_proof!.path, filename: 'note.jpg')));
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(dioProvider).post<void>('/excuses/', data: form);
      GHaptics.success();
      ref
        ..invalidate(excusesProvider(widget.studentId))
        ..invalidate(learnerDayProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      GToast.show(context, l.excuseSent);
    } on DioException catch (e) {
      GHaptics.error();
      final body = e.response?.data;
      setState(
        () => _error = isOffline(e)
            ? l.excuseOffline
            : body is Json
            ? '${l.excuseFailed}: ${body.values.map((v) => v is List ? v.join(' ') : '$v').join(' ')}'
            : l.excuseFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final children = ref.watch(childrenProvider).value ?? const <Child>[];
    final child = children.where((x) => x.id == widget.studentId).firstOrNull;
    final day = ref.watch(
      learnerDayProvider((studentId: widget.studentId, date: widget.lesson?.date ?? isoDate(DateTime.now()))),
    );
    final dayLessons = (day.value?.lessons ?? const <Lesson>[]).where((x) => !x.isCancelled).toList();
    Widget label(String s) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(s, style: t.subhead.copyWith(color: c.ink2)),
    );
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            children: [
              Text(l.excuseTitle(child?.shortName ?? ''), style: t.title1),
              label(l.excuseWhen),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final (w, text) in [
                    (_When.today, l.todayWord),
                    (_When.tomorrow, l.tomorrow),
                    (_When.dates, l.excuseDates),
                    (_When.lessons, l.excuseLessons),
                  ])
                    GChip(label: text, selected: _when == w, onTap: () => setState(() => _when = w)),
                ],
              ),
              if (_when == _When.dates) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(label: l.excuseFrom, date: _from, onTap: () => _pickDate(true)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DateButton(label: l.excuseTo, date: _to, onTap: () => _pickDate(false)),
                    ),
                  ],
                ),
              ],
              if (_when == _When.lessons) ...[
                const SizedBox(height: 8),
                GGroup(
                  inset: 60,
                  children: [
                    for (final lesson in dayLessons)
                      GRow(
                        minHeight: GSpace.rowCompact,
                        leading: SizedBox.square(
                          dimension: 28,
                          child: Checkbox.adaptive(
                            value: _lessons.contains(lesson.id),
                            onChanged: (v) => setState(() => v! ? _lessons.add(lesson.id) : _lessons.remove(lesson.id)),
                          ),
                        ),
                        marker: c.subjectMarker(lesson.colorKey),
                        title: Text(lesson.subject),
                        subtitle: Text('${hm(lesson.start)}–${hm(lesson.end)}'),
                        onTap: () => setState(
                          () => _lessons.contains(lesson.id) ? _lessons.remove(lesson.id) : _lessons.add(lesson.id),
                        ),
                      ),
                  ],
                ),
              ],
              label(l.excuseReason),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final cat in const ['illness', 'family', 'appointment', 'other'])
                    GChip(
                      label: categoryName(l, cat),
                      selected: _category == cat,
                      onTap: () => setState(() => _category = cat),
                    ),
                ],
              ),
              label(l.excuseComment),
              GField(
                controller: _comment,
                hint: l.excuseCommentHint,
                maxLines: 4,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              label(l.excuseProof),
              if (_proof == null)
                Row(
                  children: [
                    GButton(
                      label: l.excuseCamera,
                      icon: GIcons.camera,
                      size: GButtonSize.s,
                      variant: GButtonVariant.secondary,
                      onPressed: () => _pick(ImageSource.camera),
                    ),
                    const SizedBox(width: 8),
                    GButton(
                      label: l.excuseGallery,
                      icon: GIcons.image,
                      size: GButtonSize.s,
                      variant: GButtonVariant.secondary,
                      onPressed: () => _pick(ImageSource.gallery),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(File(_proof!.path), width: 72, height: 72, fit: BoxFit.cover, cacheWidth: 216),
                    ),
                    const SizedBox(width: 8),
                    GIconButton(
                      icon: GIcons.close,
                      label: l.excuseRemoveProof,
                      background: c.surface2,
                      onPressed: () => setState(() => _proof = null),
                    ),
                  ],
                ),
              if (_error != null) ...[const SizedBox(height: 16), GStateRow(title: _error!, tone: GTone.bad)],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: GButton(label: l.excuseSend, size: GButtonSize.l, expand: true, loading: _busy, onPressed: _send),
        ),
      ],
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GCard(
    color: context.c.surface2,
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.t.footnote.copyWith(color: context.c.ink2)),
        Text(Fmt.dayMonth(date, context.localeTag), style: context.t.bodyStrong),
      ],
    ),
  );
}

/// P7: allow selfie check-in for a child, with what it means.
Future<void> showConsentSheet(BuildContext context, WidgetRef ref, {required String studentId, required String name}) {
  final l = context.l10n;
  return showGSheet<void>(
    context,
    builder: (ctx) {
      final c = ctx.c;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 78,
                decoration: ShapeDecoration(color: c.primarySoft, shape: const OvalBorder()),
                child: GIcon(GIcons.checkIn, size: 30, color: c.primarySoftText),
              ),
            ),
            const SizedBox(height: 16),
            Text(l.consentSheetTitle, style: ctx.t.title1, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            for (final (icon, text) in [
              (GIcons.lock, l.consentWho),
              (GIcons.clock, l.consentKeep),
              (GIcons.undo, l.consentWhere),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    GIcon(icon, size: 22, color: c.primaryText),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text, style: ctx.t.body)),
                  ],
                ),
              ),
          ],
        ),
      );
    },
    actions: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GButton(
            label: l.actAllow,
            size: GButtonSize.l,
            expand: true,
            onPressed: () async {
              try {
                await ref.read(dioProvider).post<void>('/students/$studentId/photo-consent/', data: {'consent': true});
                ref
                  ..invalidate(childrenProvider)
                  ..invalidate(learnerDayProvider);
                GHaptics.success();
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) GToast.show(context, l.consentAllowed(name));
              } catch (_) {
                GHaptics.error();
                if (ctx.mounted) GToast.show(ctx, l.consentFailed, icon: GIcons.error);
              }
            },
          ),
          const SizedBox(height: 4),
          GButton(label: l.notNow, variant: GButtonVariant.plain, onPressed: () => Navigator.of(ctx).pop()),
        ],
      ),
    ),
  );
}
