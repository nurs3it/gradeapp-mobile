import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../haptics.dart';
import '../icons.dart';
import '../theme.dart';
import '../tokens/layout.dart';
import 'mark.dart';
import 'pressable.dart';

/// Lets the tab bar ask the root page of a tab to scroll to the top.
class TabScope extends InheritedWidget {
  const TabScope({super.key, required this.reselect, required super.child});
  final Listenable reselect;

  static Listenable? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<TabScope>()?.reselect;

  @override
  bool updateShouldNotify(TabScope old) => old.reselect != reselect;
}

/// Root screen of a tab (§3.2): 56 pt header with eyebrow over a 34 pt title
/// and up to two 44 buttons on the right; collapses into a 44 pt bar after
/// 40 pt of scroll. Pull-to-refresh draws the fan of the mark.
class GRootPage extends StatefulWidget {
  const GRootPage({
    super.key,
    required this.title,
    required this.slivers,
    this.eyebrow,
    this.actions = const [],
    this.onRefresh,
    this.below,
    this.bottomPadding = GSpace.contentBottom,
  });

  final String title;
  final String? eyebrow;
  final List<Widget> actions;
  final List<Widget> slivers;
  final Future<void> Function()? onRefresh;

  /// Under the title: freshness line, offline bar.
  final Widget? below;
  final double bottomPadding;

  @override
  State<GRootPage> createState() => _GRootPageState();
}

class _GRootPageState extends State<GRootPage> {
  final _scroll = ScrollController();
  final _compact = ValueNotifier(false);
  Listenable? _reselect;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _compact.value = _scroll.offset > 40);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = TabScope.of(context);
    if (r != _reselect) {
      _reselect?.removeListener(_toTop);
      _reselect = r?..addListener(_toTop);
    }
  }

  void _toTop() {
    if (!mounted || !_scroll.hasClients || ModalRoute.of(context)?.isCurrent != true) return;
    unawaited(_scroll.animateTo(0, duration: SpringCurve.smooth.duration, curve: SpringCurve.smooth));
  }

  @override
  void dispose() {
    _reselect?.removeListener(_toTop);
    _scroll.dispose();
    _compact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final top = MediaQuery.paddingOf(context).top;
    final g = GSpace.gutter(context);
    return Scaffold(
      backgroundColor: c.canvas,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: top),
            child: CustomScrollView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                if (widget.onRefresh != null) GRefreshControl(onRefresh: widget.onRefresh!),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(g, 8, g - 2, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.eyebrow != null)
                                Text(
                                  widget.eyebrow!.toUpperCase(),
                                  style: context.t.eyebrow.copyWith(color: c.ink2),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Semantics(
                                header: true,
                                child: Text(
                                  widget.title,
                                  style: context.t.largeTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final a in widget.actions) Padding(padding: const EdgeInsets.only(left: 6), child: a),
                      ],
                    ),
                  ),
                ),
                if (widget.below != null) SliverToBoxAdapter(child: widget.below),
                ...widget.slivers,
                SliverToBoxAdapter(
                  child: SizedBox(height: widget.bottomPadding + MediaQuery.paddingOf(context).bottom),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ValueListenableBuilder(
              valueListenable: _compact,
              builder: (context, compact, _) => IgnorePointer(
                ignoring: !compact,
                child: AnimatedOpacity(
                  opacity: compact ? 1 : 0,
                  duration: GMotion.quick,
                  child: Container(
                    padding: EdgeInsets.only(top: top),
                    height: top + 44,
                    decoration: BoxDecoration(
                      color: c.canvas,
                      border: Border(bottom: BorderSide(color: c.hairline)),
                    ),
                    alignment: Alignment.center,
                    child: ExcludeSemantics(
                      child: GestureDetector(
                        onTap: _toTop,
                        child: Text(widget.title, style: context.t.headline, maxLines: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Fade-out of the content under the capsule (no blur, §2.5).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 150,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [c.canvas.withValues(alpha: 0), c.canvas],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pull-to-refresh: mark pages appear one per quarter of the 80 pt threshold,
/// then the loader turns pages while refreshing (§3.25).
class GRefreshControl extends StatelessWidget {
  const GRefreshControl({super.key, required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    var lastMode = RefreshIndicatorMode.inactive;
    return CupertinoSliverRefreshControl(
      refreshTriggerPullDistance: 80,
      refreshIndicatorExtent: 56,
      onRefresh: onRefresh,
      builder: (context, mode, pulled, trigger, extent) {
        if (mode == RefreshIndicatorMode.armed && lastMode == RefreshIndicatorMode.drag) GHaptics.selection();
        lastMode = mode;
        final busy = mode == RefreshIndicatorMode.refresh || mode == RefreshIndicatorMode.armed;
        return Center(
          child: Opacity(
            opacity: (pulled / 24).clamp(0.0, 1.0),
            child: busy ? const GLoader(size: 32) : GFanProgress(earned: 4 * pulled / trigger, size: 32),
          ),
        );
      },
    );
  }
}

/// Nested screen (§3.2): 48 pt bar with «‹ Back», optional centred title and
/// up to two 40 pt buttons. No large title.
class GNavBar extends StatelessWidget implements PreferredSizeWidget {
  const GNavBar({super.key, this.title, this.backLabel, this.actions = const [], this.onBack, this.background});
  final String? title;
  final String? backLabel;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final Color? background;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final canPop = onBack != null || Navigator.of(context).canPop();
    return Container(
      color: background ?? c.canvas,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 110),
                child: Semantics(
                  header: true,
                  child: Text(title!, style: context.t.headline, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            if (canPop)
              Align(
                alignment: Alignment.centerLeft,
                child: GPressable(
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  semanticLabel: backLabel ?? MaterialLocalizations.of(context).backButtonTooltip,
                  excludeChildSemantics: true,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44, minWidth: 44, maxWidth: 140),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 6),
                        GIcon(GIcons.back, size: 28, color: c.primaryText),
                        if (backLabel != null)
                          Flexible(
                            child: Text(
                              backLabel!,
                              style: context.t.headline.copyWith(color: c.primaryText, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(mainAxisSize: MainAxisSize.min, children: actions),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
