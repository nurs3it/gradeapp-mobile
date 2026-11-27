import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import 'teacher_models.dart';
import 'teacher_providers.dart';

/// T6: template tags of a feedback. The first tag of a feedback is its tone
/// (`positive` / `negative`), the rest are these templates; the app turns
/// them into words (the backend keeps only the codes).
const positiveFeedbackTags = ['active', 'helped', 'progress', 'great_answer'];
const negativeFeedbackTags = ['late', 'no_homework', 'distracted', 'no_materials'];

List<String> feedbackTemplates(String tone) => tone == 'negative' ? negativeFeedbackTags : positiveFeedbackTags;

/// Words for a template tag in the app language; null for tags the app does
/// not know (the tone itself, tags of a newer version).
String? feedbackTagLabel(AppLocalizations l, String tag) => switch (tag) {
  'active' => l.t6TagActive,
  'helped' => l.t6TagHelped,
  'progress' => l.t6TagProgress,
  'great_answer' => l.t6TagGreatAnswer,
  'late' => l.t6TagLate,
  'no_homework' => l.t6TagNoHomework,
  'distracted' => l.t6TagDistracted,
  'no_materials' => l.t6TagNoMaterials,
  _ => null,
};

/// The tags to send: the tone first, then the chosen templates that belong
/// to it (switching the tone drops the other tone's templates).
List<String> feedbackTags(String? tone, Iterable<String> templates) => [
  ?tone,
  if (tone != null) ...templates.where(feedbackTemplates(tone).contains),
];

/// Can the form be sent: a tone or some words. Text alone is a plain
/// feedback, tags alone are a quick one.
bool canSendFeedback({required String? tone, required String text}) => tone != null || text.trim().isNotEmpty;

/// Quick feedback (T6): swipe a roster row, tap «Похвалить» / «Замечание» —
/// a compact sheet with four template tags and optional words.
Future<void> showQuickFeedbackSheet(
  BuildContext context, {
  required RosterStudent student,
  required LessonActions actions,
  required bool positive,
}) {
  final l = context.l10n;
  return showGSheet<void>(
    context,
    title: positive ? l.t6PraiseTitle(student.name) : l.t6RemarkTitle(student.name),
    builder: (_) => FeedbackForm(student: student, actions: actions, tone: positive ? 'positive' : 'negative'),
  );
}

/// Feedback to one student from the lesson. With a fixed [tone] (the swipe
/// actions) only that tone's templates show; without one (long press) the
/// teacher picks praise or remark first, or sends plain words.
class FeedbackForm extends ConsumerStatefulWidget {
  const FeedbackForm({super.key, required this.student, required this.actions, this.tone});
  final RosterStudent student;
  final LessonActions actions;
  final String? tone;

  @override
  ConsumerState<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends ConsumerState<FeedbackForm> {
  final _text = TextEditingController();
  late String? _tone = widget.tone;
  final _picked = <String>{};
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    _sending = true;
    final toast = context.l10n.feedbackSent(
      widget.student.firstName.isEmpty ? widget.student.name : widget.student.firstName,
    );
    final nav = Navigator.of(context);
    final host = nav.context;
    await widget.actions.feedback(
      widget.student.id,
      _text.text.trim(),
      tone: _tone,
      templates: _picked,
      name: widget.student.name,
    );
    GHaptics.success();
    ref.read(analyticsProvider).track(AnalyticsEvents.feedbackSent);
    nav.pop();
    if (host.mounted) GToast.show(host, toast, bottomOffset: 100);
  }

  void _setTone(String tone) => setState(() {
    _tone = _tone == tone ? null : tone;
    _picked.clear();
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tone = _tone;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.tone == null) ...[
            Wrap(
              spacing: 8,
              children: [
                GChip(label: l.feedbackPraise, selected: tone == 'positive', onTap: () => _setTone('positive')),
                GChip(label: l.feedbackRemark, selected: tone == 'negative', onTap: () => _setTone('negative')),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (tone != null) ...[
            Wrap(
              spacing: 8,
              children: [
                for (final tag in feedbackTemplates(tone))
                  GChip(
                    label: feedbackTagLabel(l, tag) ?? tag,
                    selected: _picked.contains(tag),
                    onTap: () => setState(() => _picked.contains(tag) ? _picked.remove(tag) : _picked.add(tag)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          GField(
            controller: _text,
            hint: tone == null ? l.feedbackHint : l.t6TextHint,
            maxLines: 5,
            minLines: tone == null ? 3 : 2,
            autofocus: tone == null,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          GButton(
            label: l.feedbackSend,
            size: GButtonSize.l,
            expand: true,
            onPressed: canSendFeedback(tone: tone, text: _text.text) ? () => unawaited(_send()) : null,
          ),
        ],
      ),
    );
  }
}

/// One revealed action of [SwipeActions].
class SwipeAction {
  const SwipeAction({required this.label, required this.icon, required this.tone, required this.onTap});
  final String label;
  final IconData icon;
  final GTone tone;
  final VoidCallback onTap;
}

/// Swipe a row to the left to reveal actions (T6). The row slides over the
/// buttons; a tap on the row or a swipe back closes them. No ripple — the
/// buttons are [GPressable]s like everywhere else.
class SwipeActions extends StatefulWidget {
  const SwipeActions({super.key, required this.child, required this.actions, this.enabled = true});
  final Widget child;
  final List<SwipeAction> actions;
  final bool enabled;

  static const actionWidth = 88.0;

  @override
  State<SwipeActions> createState() => _SwipeActionsState();
}

class _SwipeActionsState extends State<SwipeActions> {
  double _dx = 0;
  bool _dragging = false;

  double get _full => SwipeActions.actionWidth * widget.actions.length;
  bool get _open => _dx <= -_full + 1;

  void _close() => setState(() => _dx = 0);

  void _settle(double velocity) {
    final open = velocity < -400 || (velocity <= 400 && _dx < -_full / 2);
    setState(() {
      _dragging = false;
      _dx = open ? -_full : 0;
    });
    if (open) GHaptics.selection();
  }

  @override
  void didUpdateWidget(SwipeActions old) {
    super.didUpdateWidget(old);
    if (!widget.enabled && _dx != 0) _dx = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final c = context.c;
    final t = context.t;
    final reduce = GMotion.reduce(context);
    final moving = _dx != 0;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) => setState(() => _dragging = true),
      onHorizontalDragUpdate: (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(-_full, 0.0)),
      onHorizontalDragEnd: (d) => _settle(d.primaryVelocity ?? 0),
      onHorizontalDragCancel: () => _settle(0),
      child: ClipRect(
        child: Stack(
          children: [
            if (moving)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: _full,
                    child: Row(
                      children: [
                        for (final a in widget.actions)
                          Expanded(
                            child: GPressable(
                              onTap: _open
                                  ? () {
                                      _close();
                                      a.onTap();
                                    }
                                  : null,
                              semanticLabel: a.label,
                              excludeChildSemantics: true,
                              child: Container(
                                color: a.tone.soft(c),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GIcon(a.icon, size: 22, color: a.tone.fg(c), fill: 1),
                                    const SizedBox(height: 2),
                                    Text(
                                      a.label,
                                      style: t.caption.copyWith(color: a.tone.fg(c)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            AnimatedContainer(
              duration: _dragging || reduce ? Duration.zero : GMotion.quick,
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_dx, 0, 0),
              color: moving ? c.surface : Colors.transparent,
              child: _open
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _close,
                      child: AbsorbPointer(child: widget.child),
                    )
                  : widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
