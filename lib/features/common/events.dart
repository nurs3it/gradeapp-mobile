import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/json.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../ui/ui.dart';
import '../auth/auth_controller.dart';
import 'models.dart';

/// School event or announcement (`/engagement/events/`).
class SchoolEvent {
  const SchoolEvent({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.description = '',
    this.type = '',
    this.location = '',
    this.startTime,
    this.isRead = false,
    this.allDay = false,
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final String startDate;
  final String endDate;
  final String? startTime;
  final String location;
  final bool isRead;
  final bool allDay;

  factory SchoolEvent.fromJson(Json j) => SchoolEvent(
    id: j.str('id'),
    title: j.str('title'),
    description: j.str('description'),
    type: j.str('event_type'),
    startDate: j.str('start_date'),
    endDate: j.strOrNull('end_date') ?? j.str('start_date'),
    startTime: j.strOrNull('start_time'),
    location: j.str('location'),
    isRead: j.flag('is_read'),
    allDay: j.flag('all_day'),
  );
}

/// How far ahead the events list looks.
const eventsAheadDays = 28;

final pinnedEventsProvider = StreamProvider<List<SchoolEvent>>((ref) {
  ref.watch(schoolIdProvider);
  return cachedGet(
    ref,
    '/engagement/events/',
    query: const {'pinned': 1},
    parse: (d) => parseList(d, SchoolEvent.fromJson),
  );
});

final upcomingEventsProvider = StreamProvider<List<SchoolEvent>>((ref) {
  ref.watch(schoolIdProvider);
  final now = DateTime.now();
  return cachedGet(
    ref,
    '/engagement/events/',
    query: {
      'date_from': isoDate(now),
      'date_to': isoDate(now.add(const Duration(days: eventsAheadDays))),
      'page_size': 100,
    },
    parse: (d) => parseList(d, SchoolEvent.fromJson)..sort((a, b) => a.startDate.compareTo(b.startDate)),
  );
});

/// Ids marked read in this session (the server list refreshes later).
class ReadEvents extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Sends «read» once per event; failures are silent (retried on next open).
  Future<void> mark(Iterable<SchoolEvent> events) async {
    final todo = events.where((e) => !e.isRead && !state.contains(e.id)).map((e) => e.id).toList();
    if (todo.isEmpty) return;
    state = {...state, ...todo};
    final dio = ref.read(dioProvider);
    for (final id in todo) {
      try {
        await dio.post<void>('/engagement/events/$id/read/');
      } catch (_) {
        state = {...state}..remove(id);
      }
    }
  }
}

final readEventsProvider = NotifierProvider<ReadEvents, Set<String>>(ReadEvents.new);

/// Pinned announcements as one collapsible line at the top of «Сегодня»
/// (P10). Opening it marks them read. Nothing when there are none.
class PinnedEventsLine extends ConsumerStatefulWidget {
  const PinnedEventsLine({super.key});

  @override
  ConsumerState<PinnedEventsLine> createState() => _PinnedState();
}

class _PinnedState extends ConsumerState<PinnedEventsLine> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(pinnedEventsProvider).value ?? const <SchoolEvent>[];
    if (list.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    final c = context.c;
    final t = context.t;
    final read = ref.watch(readEventsProvider);
    final unread = list.where((e) => !e.isRead && !read.contains(e.id)).length;
    final first = list.first;
    final title = list.length == 1 ? first.title : l.p10PinnedMany(first.title, list.length - 1);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GCard(
        color: c.goldSoft,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GPressable(
              onTap: () {
                setState(() => _open = !_open);
                if (_open) unawaited(ref.read(readEventsProvider.notifier).mark(list));
              },
              semanticLabel: '${l.p10Pinned}: $title. ${_open ? l.p10Collapse : l.p10Expand}',
              excludeChildSemantics: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GIcon(GIcons.bell, size: 20, color: c.goldText, fill: 1),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: t.subhead.copyWith(color: c.goldText),
                        maxLines: _open ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unread > 0) const Padding(padding: EdgeInsets.only(right: 6), child: GNewDot()),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: GMotion.instant,
                      child: GIcon(GIcons.expand, size: 22, color: c.goldText),
                    ),
                  ],
                ),
              ),
            ),
            if (_open)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in list) ...[
                      Text(e.title, style: t.bodyStrong.copyWith(color: c.goldText)),
                      if (e.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(e.description, style: t.body.copyWith(color: c.goldText)),
                        ),
                      const SizedBox(height: 10),
                    ],
                    GButton(
                      label: l.p10AllEvents,
                      size: GButtonSize.s,
                      variant: GButtonVariant.surface,
                      onPressed: () => context.push('/events'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Events of the next weeks.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.c;
    final g = GSpace.gutter(context);
    final async = ref.watch(upcomingEventsProvider);
    final loc = context.localeTag;
    return Scaffold(
      backgroundColor: c.canvas,
      appBar: GNavBar(backLabel: l.back),
      body: ListView(
        padding: EdgeInsets.fromLTRB(g, 8, g, 32 + MediaQuery.paddingOf(context).bottom),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 14),
            child: Semantics(header: true, child: Text(l.p10Events, style: context.t.title1)),
          ),
          if (!async.hasValue)
            async.hasError
                ? GEmpty(
                    error: true,
                    title: l.errorTitle,
                    message: l.errorOffline,
                    action: l.retry,
                    onAction: () => ref.invalidate(upcomingEventsProvider),
                  )
                : const GSkeleton(hero: false)
          else if (async.value!.isEmpty)
            GCard(child: GEmpty(title: l.p10EventsEmpty, message: l.p10EventsEmptyHint, icon: GIcons.school))
          else
            GGroup(
              children: [
                for (final e in async.value!)
                  GRow(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: ShapeDecoration(color: c.primarySoft, shape: GRadius.surface(14)),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${DateTime.parse(e.startDate).day}',
                            style: context.t.bodyStrong.copyWith(color: c.primarySoftText),
                          ),
                          Text(
                            Fmt.monthShort(DateTime.parse(e.startDate), loc),
                            style: context.t.caption.copyWith(color: c.primarySoftText),
                          ),
                        ],
                      ),
                    ),
                    title: Text(e.title),
                    titleMaxLines: 2,
                    subtitle: Text(
                      [
                        if (e.startTime != null && !e.allDay) hm(e.startTime!),
                        if (e.location.isNotEmpty) e.location,
                        if (e.description.isNotEmpty) e.description,
                      ].join(' · '),
                    ),
                    subtitleMaxLines: 2,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
