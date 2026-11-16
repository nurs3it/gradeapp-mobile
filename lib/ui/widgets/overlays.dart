import 'dart:async';

import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme.dart';
import '../tokens/colors.dart';
import '../tokens/layout.dart';
import 'buttons.dart';

/// Bottom sheet (§3.18): `surface`, 38 pt top corners, handle, title with a
/// close button, content, action bar above the safe area. Springs in on
/// `sheet`; scrim fades in 240 ms. [full] = full detent.
///
/// [hero]: the sheet opens as a page route instead of a modal-sheet route, so
/// a [Hero] inside it can fly in from the card that was tapped (a modal sheet
/// route is not a `PageRoute`, so Flutter never flies heroes into it). The
/// sheet itself fades in with a short rise and is dragged down by its handle.
Future<T?> showGSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  String? title,
  String? closeLabel,
  bool full = false,
  Widget? actions,
  bool scrollable = true,
  bool bigTitle = false,
  bool hero = false,
}) {
  final c = context.c;
  Widget content(BuildContext ctx, {GestureDragUpdateCallback? onDrag, GestureDragEndCallback? onDragEnd}) =>
      _sheetContent<T>(
        ctx,
        builder: builder,
        title: title,
        closeLabel: closeLabel,
        full: full,
        actions: actions,
        scrollable: scrollable,
        bigTitle: bigTitle,
        onDrag: onDrag,
        onDragEnd: onDragEnd,
      );
  if (hero) {
    return Navigator.of(context, rootNavigator: true).push(
      _HeroSheetRoute<T>(
        scrim: c.scrim,
        label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        builder: (outer) => Theme(
          data: Theme.of(outer).copyWith(extensions: [outer.c.raised(), outer.t]),
          child: _HeroSheetFrame(
            color: c.surface,
            builder: (ctx, onDrag, onDragEnd) => content(ctx, onDrag: onDrag, onDragEnd: onDragEnd),
          ),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: c.surface,
    barrierColor: c.scrim,
    elevation: 0,
    shape: const RoundedSuperellipseBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(GRadius.sheet))),
    clipBehavior: Clip.antiAlias,
    sheetAnimationStyle: AnimationStyle(
      curve: SpringCurve.sheet,
      duration: SpringCurve.sheet.duration,
      reverseCurve: GMotion.exit,
      reverseDuration: GMotion.base,
    ),
    builder: (outer) => Theme(
      data: Theme.of(outer).copyWith(extensions: [outer.c.raised(), outer.t]),
      child: Builder(builder: content),
    ),
  );
}

Widget _sheetContent<T>(
  BuildContext ctx, {
  required WidgetBuilder builder,
  required String? title,
  required String? closeLabel,
  required bool full,
  required Widget? actions,
  required bool scrollable,
  required bool bigTitle,
  GestureDragUpdateCallback? onDrag,
  GestureDragEndCallback? onDragEnd,
}) {
  final media = MediaQuery.of(ctx);
  final maxH = media.size.height * (full ? 0.94 : 0.62);
  final body = builder(ctx);
  Widget head = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const _Handle(),
      if (title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: bigTitle ? ctx.t.title1 : ctx.t.headline, maxLines: 2),
                ),
              ),
              GIconButton(
                icon: GIcons.close,
                label: closeLabel ?? MaterialLocalizations.of(ctx).closeButtonLabel,
                size: 36,
                background: ctx.c.surface2,
                color: ctx.c.ink2,
                onPressed: () => Navigator.of(ctx).maybePop(),
              ),
            ],
          ),
        ),
    ],
  );
  if (onDrag != null) {
    head = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: onDrag,
      onVerticalDragEnd: onDragEnd,
      child: head,
    );
  }
  return AnimatedPadding(
    duration: GMotion.quick,
    padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: full ? maxH : media.size.height * 0.9, minHeight: full ? maxH : 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          head,
          if (scrollable) Flexible(child: SingleChildScrollView(child: body)) else Flexible(child: body),
          if (actions != null)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + (media.viewInsets.bottom > 0 ? 0 : media.padding.bottom)),
              child: actions,
            )
          else
            SizedBox(height: media.padding.bottom + 8),
        ],
      ),
    ),
  );
}

/// Page route that looks like a bottom sheet over a scrim, so heroes fly in.
class _HeroSheetRoute<T> extends PageRoute<T> {
  _HeroSheetRoute({required this.scrim, required this.label, required this.builder});

  final Color scrim;
  final String label;
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => scrim;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => label;
  @override
  bool get opaque => false;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => const Duration(milliseconds: 420);
  @override
  Duration get reverseTransitionDuration => GMotion.base;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    final rise = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeIn);
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(rise),
        child: child,
      ),
    );
  }
}

/// Bottom-aligned sheet surface of a [_HeroSheetRoute], dragged down by its
/// handle (past 120 pt or a fast flick closes it, otherwise it springs back).
class _HeroSheetFrame extends StatefulWidget {
  const _HeroSheetFrame({required this.color, required this.builder});
  final Color color;
  final Widget Function(BuildContext, GestureDragUpdateCallback, GestureDragEndCallback) builder;

  @override
  State<_HeroSheetFrame> createState() => _HeroSheetFrameState();
}

class _HeroSheetFrameState extends State<_HeroSheetFrame> with SingleTickerProviderStateMixin {
  double _dy = 0;
  double _from = 0;
  late final AnimationController _back = AnimationController(vsync: this, duration: GMotion.base)
    ..addListener(() => setState(() => _dy = _from * (1 - Curves.easeOut.transform(_back.value))));

  @override
  void dispose() {
    _back.dispose();
    super.dispose();
  }

  void _update(DragUpdateDetails d) {
    _back.stop();
    setState(() => _dy = (_dy + d.delta.dy).clamp(0, double.infinity));
  }

  void _end(DragEndDetails d) {
    if (_dy > 120 || d.velocity.pixelsPerSecond.dy > 700) {
      Navigator.of(context).maybePop();
      return;
    }
    _from = _dy;
    _back.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: Transform.translate(
      offset: Offset(0, _dy),
      child: Material(
        color: widget.color,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(GRadius.sheet)),
        ),
        child: SafeArea(bottom: false, child: widget.builder(context, _update, _end)),
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      width: 40,
      height: 5,
      decoration: ShapeDecoration(color: context.c.surface3, shape: const StadiumBorder()),
    ),
  );
}

/// Toast (§3.17): only for reversible actions and short confirmations.
/// Inverted capsule above the tab bar / dock; a new one replaces the old.
abstract final class GToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    IconData icon = GIcons.ok,
    double bottomOffset = GSpace.tabbarH + GSpace.tabbarBottom + 12,
  }) {
    hide();
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final key = GlobalKey<_ToastState>();
    _entry = OverlayEntry(
      builder: (_) => _Toast(
        key: key,
        message: message,
        actionLabel: actionLabel,
        icon: icon,
        bottomOffset: bottomOffset,
        onAction: onAction == null
            ? null
            : () {
                hide();
                onAction();
              },
        onDismiss: hide,
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(Duration(milliseconds: actionLabel == null ? 2500 : 5000), () async {
      await key.currentState?.out();
      hide();
    });
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    super.key,
    required this.message,
    required this.icon,
    required this.bottomOffset,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final double bottomOffset;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: SpringCurve.smooth.duration)..forward();

  Future<void> out() async {
    if (mounted) await _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final curved = CurvedAnimation(parent: _ctrl, curve: SpringCurve.smooth, reverseCurve: GMotion.exit);
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.paddingOf(context).bottom + widget.bottomOffset,
      child: SafeArea(
        top: false,
        bottom: false,
        child: FadeTransition(
          opacity: _ctrl,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(curved),
            child: GestureDetector(
              onVerticalDragEnd: (d) {
                if ((d.primaryVelocity ?? 0) > 0) widget.onDismiss();
              },
              child: Semantics(
                liveRegion: true,
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    decoration: ShapeDecoration(color: c.ink, shape: const StadiumBorder(), shadows: GDepth.level2(c)),
                    child: Row(
                      children: [
                        GIcon(widget.icon, size: 20, color: c.isDark ? GColors.okFill : GColors.light.okSoft, fill: 1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: context.t.callout.copyWith(color: c.canvas, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.actionLabel != null)
                          GButton(
                            label: widget.actionLabel!,
                            onPressed: widget.onAction,
                            variant: GButtonVariant.plain,
                            size: GButtonSize.s,
                            foreground: c.isDark ? GColors.brand : GColors.toastAction,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation sheet with a destructive or primary choice.
Future<bool> confirmSheet(
  BuildContext context, {
  required String title,
  String? message,
  required String confirm,
  required String cancel,
  bool destructive = false,
}) async {
  final ok = await showGSheet<bool>(
    context,
    title: title,
    builder: (ctx) => message == null
        ? const SizedBox(height: 8)
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(message, style: ctx.t.body.copyWith(color: ctx.c.ink2)),
          ),
    actions: Builder(
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GButton(
            label: confirm,
            expand: true,
            size: GButtonSize.l,
            variant: destructive ? GButtonVariant.destructive : GButtonVariant.primary,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
          const SizedBox(height: 8),
          GButton(
            label: cancel,
            expand: true,
            variant: GButtonVariant.plain,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ],
      ),
    ),
  );
  return ok ?? false;
}
