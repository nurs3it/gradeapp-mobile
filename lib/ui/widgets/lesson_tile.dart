import 'package:flutter/material.dart';

import '../../features/learner/models.dart';
import '../../l10n/l10n.dart';
import '../tokens.dart';
import 'badges.dart';

/// One lesson in a day list: time column, subject colour bar, details.
/// The running lesson is lifted (primary tint + «Сейчас»).
class GLessonTile extends StatelessWidget {
  const GLessonTile({
    super.key,
    required this.subject,
    required this.start,
    required this.end,
    this.subtitle,
    this.status,
    this.now = false,
    this.past = false,
    this.cancelled = false,
    this.trailing,
    this.onTap,
  });

  final String subject;
  final String start;
  final String end;
  final String? subtitle;
  final Widget? status;
  final bool now;
  final bool past;
  final bool cancelled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final accent = c.subject(subject);
    final dim = past || cancelled;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpace.page, vertical: 4),
      child: Material(
        color: now ? c.primarySoft : c.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GRadius.card),
          side: BorderSide(color: now ? c.primary.withValues(alpha: 0.35) : c.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: GSpace.md),
                    child: Column(
                      children: [
                        Text(
                          hm(start),
                          style: context.t.titleSmall!.copyWith(
                            color: dim ? c.mutedForeground : null,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hm(end),
                          style: context.t.bodySmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(vertical: GSpace.md),
                  decoration: BoxDecoration(
                    color: dim ? accent.withValues(alpha: 0.4) : accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(GSpace.md, GSpace.md, GSpace.md, GSpace.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.t.titleSmall!.copyWith(
                                  fontSize: 16,
                                  color: dim ? c.mutedForeground : null,
                                  decoration: cancelled ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                            if (now) GPill(context.l10n.now, tone: GTone.primary),
                          ],
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.t.bodySmall),
                        ],
                        if (status != null) ...[const SizedBox(height: 6), status!],
                      ],
                    ),
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: GSpace.md),
                    child: Center(child: trailing),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal week strip: Mon..Sun with today dot. Swipe the list for weeks.
class GWeekStrip extends StatelessWidget {
  const GWeekStrip({super.key, required this.monday, required this.selected, required this.onSelect});
  final DateTime monday;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final today = DateTime.now();
    final loc = Localizations.localeOf(context).toLanguageTag();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpace.page - 4),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Builder(
              builder: (context) {
                final d = monday.add(Duration(days: i));
                final isSel = isoDate(d) == isoDate(selected);
                final isToday = isoDate(d) == isoDate(today);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: isSel ? c.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(GRadius.control),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(GRadius.control),
                        onTap: () => onSelect(d),
                        child: SizedBox(
                          height: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weekdayShort(d, loc),
                                style: context.t.labelMedium!.copyWith(
                                  fontSize: 12,
                                  color: isSel ? Colors.white70 : c.mutedForeground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${d.day}',
                                style: context.t.titleMedium!.copyWith(
                                  color: isSel ? Colors.white : (isToday ? c.primaryText : null),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isToday && !isSel ? c.primary : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
