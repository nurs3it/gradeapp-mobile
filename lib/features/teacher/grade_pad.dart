import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/grading.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../common/lesson_widgets.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

/// Dock pad for scales of 6–10 marks (design-system §3.10, decision № 5):
/// 2 × 5 keys of 60 pt, 1–5 on top and 6–10 under the thumb; the class list
/// stays visible above. A mark moves to the next present student.
class GradePad extends StatefulWidget {
  const GradePad({
    super.key,
    required this.students,
    required this.cells,
    required this.grading,
    required this.index,
    required this.typeLabel,
    required this.onIndex,
    required this.onPick,
    required this.onClose,
    required this.onType,
    this.selected = const {},
    this.onPickMany,
  });

  final List<RosterStudent> students;
  final Map<String, RollCell> cells;
  final Grading grading;
  final int index;
  final String typeLabel;
  final ValueChanged<int> onIndex;

  /// value null = remove the mark.
  final void Function(RosterStudent student, num? value, String comment) onPick;
  final VoidCallback onClose;
  final VoidCallback onType;

  /// Multi-select mode: one mark for all of them.
  final Set<String> selected;
  final void Function(num value)? onPickMany;

  static const height = 404.0;

  @override
  State<GradePad> createState() => _GradePadState();
}

class _GradePadState extends State<GradePad> {
  num? _flash;
  num? _confirmAbsent;
  bool _comment = false;
  final _commentCtrl = TextEditingController();
  Timer? _advance;

  RosterStudent get _student => widget.students[widget.index];
  RollCell? get _cell => widget.cells[_student.id];
  bool get _multi => widget.selected.isNotEmpty;

  @override
  void didUpdateWidget(GradePad old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      _confirmAbsent = null;
      _flash = null;
    }
  }

  @override
  void dispose() {
    _advance?.cancel();
    _commentCtrl.dispose();
    super.dispose();
  }

  /// Next student who is in class (absent and excused are skipped).
  int? _nextIndex(int from, int step) {
    for (var i = from + step; i >= 0 && i < widget.students.length; i += step) {
      if (!(widget.cells[widget.students[i].id]?.isOut ?? false)) return i;
    }
    return null;
  }

  void _go(int step) {
    final i = widget.index + step;
    if (i < 0 || i >= widget.students.length) return;
    GHaptics.selection();
    widget.onIndex(i);
  }

  void _press(num v) {
    if (_multi) {
      GHaptics.medium();
      widget.onPickMany?.call(v);
      return;
    }
    final cell = _cell;
    if (cell != null && cell.isOut && _confirmAbsent != v) {
      GHaptics.warning();
      setState(() => _confirmAbsent = v);
      return;
    }
    _put(v);
  }

  void _put(num v) {
    final l = context.l10n;
    final cell = _cell;
    final student = _student;
    _confirmAbsent = null;
    // Second tap on the same mark takes it off (with undo).
    if (cell?.grade == v) {
      GHaptics.light();
      widget.onPick(student, null, '');
      GToast.show(
        context,
        l.padRemoved,
        actionLabel: l.undo,
        bottomOffset: GradePad.height + 12,
        onAction: () => widget.onPick(student, v, ''),
      );
      setState(() {});
      return;
    }
    GHaptics.medium();
    widget.onPick(student, v, _comment ? _commentCtrl.text.trim() : '');
    _commentCtrl.clear();
    setState(() {
      _flash = v;
      _comment = false;
    });
    _advance?.cancel();
    _advance = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      final next = _nextIndex(widget.index, 1);
      if (next != null) widget.onIndex(next);
      setState(() => _flash = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final g = widget.grading;
    final s = _student;
    final cell = _cell;
    final marks = g.marks;
    final cols = marks.length <= 5 ? marks.length : (marks.length / 2).ceil();
    final current = cell?.grade;
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) > 300) widget.onClose();
      },
      child: Container(
        height: GradePad.height + MediaQuery.paddingOf(context).bottom,
        decoration: ShapeDecoration(
          color: c.surface,
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(GRadius.sheet)),
          ),
          shadows: GDepth.sheet(c),
        ),
        padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.paddingOf(context).bottom + 4),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: ShapeDecoration(color: c.surface3, shape: const StadiumBorder()),
            ),
            const SizedBox(height: 10),
            // Student strip: swipe to flip students.
            GestureDetector(
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v.abs() > 200) _go(v < 0 ? 1 : -1);
              },
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    _multi
                        ? Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(color: GColors.brand, shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                '${widget.selected.length}',
                                style: t.headline.copyWith(color: GColors.onFill),
                              ),
                            ),
                          )
                        : GAvatar(name: s.name, url: s.avatarUrl, size: 44, tone: GAvatarTone.active),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        liveRegion: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _multi ? l.padSelected(widget.selected.length) : s.name,
                              style: t.headline.copyWith(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!_multi)
                              Text(
                                l.padOf(widget.index + 1, widget.students.length),
                                style: t.footnote.copyWith(color: c.ink2),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!_multi) ...[
                      GIconButton(
                        icon: GIcons.back,
                        label: l.padPrev,
                        background: c.surface2,
                        onPressed: widget.index > 0 ? () => _go(-1) : null,
                      ),
                      const SizedBox(width: 6),
                      GIconButton(
                        icon: GIcons.chevron,
                        label: l.padNext,
                        background: c.surface2,
                        onPressed: widget.index < widget.students.length - 1 ? () => _go(1) : null,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: GChip(label: '${widget.typeLabel} ▾', onTap: widget.onType),
                  ),
                  const SizedBox(width: 8),
                  GChip(
                    label: l.padComment,
                    icon: GIcons.chat,
                    selected: _comment,
                    onTap: () => setState(() => _comment = !_comment),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_confirmAbsent != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GStateRow(
                  title: l.padAbsentWarn(s.name),
                  tone: GTone.warn,
                  action: l.padPut,
                  onAction: () => _put(_confirmAbsent!),
                ),
              )
            else if (_comment)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GField(
                  controller: _commentCtrl,
                  hint: l.padCommentHint,
                  autofocus: true,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  final rows = (marks.length / cols).ceil();
                  final keyH = ((box.maxHeight - 8 * (rows - 1)) / rows).clamp(44.0, 60.0);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (var r = 0; r < rows; r++) ...[
                        if (r > 0) const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var k = 0; k < cols; k++) ...[
                              if (k > 0) const SizedBox(width: 8),
                              Expanded(
                                child: r * cols + k < marks.length
                                    ? _Key(
                                        value: marks[r * cols + k],
                                        height: keyH,
                                        tone: g.tone(marks[r * cols + k]),
                                        solid:
                                            _flash == marks[r * cols + k] ||
                                            (!_multi && current == marks[r * cols + k]),
                                        label: l.padKey(
                                          '${marks[r * cols + k]}',
                                          toneWord(l, g.tone(marks[r * cols + k])),
                                        ),
                                        onTap: () => _press(marks[r * cols + k]),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            Row(
              children: [
                GButton(
                  label: l.skip,
                  icon: GIcons.undo,
                  variant: GButtonVariant.plain,
                  foreground: c.ink2,
                  onPressed: _multi
                      ? null
                      : () {
                          final next = _nextIndex(widget.index, 1);
                          if (next != null) {
                            GHaptics.selection();
                            widget.onIndex(next);
                          }
                        },
                ),
                const Spacer(),
                GButton(label: l.done, variant: GButtonVariant.plain, onPressed: widget.onClose),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.value,
    required this.height,
    required this.tone,
    required this.solid,
    required this.label,
    required this.onTap,
  });

  final int value;
  final double height;
  final GradeTone tone;
  final bool solid;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg) = tone.soft(c);
    return GPressable(
      onTap: onTap,
      scale: 0.94,
      semanticLabel: label,
      excludeChildSemantics: true,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(GRadius.key)),
            ),
            // Solid layer cross-fades in (§2.6: colour by opacity, not by animating the colour).
            AnimatedOpacity(
              opacity: solid ? 1 : 0,
              duration: GMotion.quick,
              child: DecoratedBox(
                decoration: BoxDecoration(color: tone.solid(), borderRadius: BorderRadius.circular(GRadius.key)),
              ),
            ),
            Center(
              child: Text(
                '$value',
                style: context.t.key.copyWith(
                  color: solid ? GColors.onFill : fg,
                  fontSize: GScale.large(context) ? 30 : 26,
                ),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
