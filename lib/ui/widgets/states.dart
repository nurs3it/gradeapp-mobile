import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../tokens.dart';

/// Initials on a tinted circle, photo when there is one.
class GAvatar extends StatelessWidget {
  const GAvatar({super.key, required this.name, this.url, this.size = 40});
  final String name;
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0])
        .join()
        .toUpperCase();
    final fallback = Text(
      initials,
      style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w600, color: c.primarySoftForeground),
    );
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: c.primarySoft,
        alignment: Alignment.center,
        child: url == null
            ? fallback
            : Image.network(
                url!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
                errorBuilder: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class GEmptyState extends StatelessWidget {
  const GEmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GSpace.xl, vertical: GSpace.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: BorderRadius.circular(GRadius.card)),
            child: Icon(icon, color: c.mutedForeground, size: 28),
          ),
          const SizedBox(height: GSpace.md),
          Text(title, style: context.t.titleMedium, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: GSpace.xs),
            Text(
              message!,
              style: context.t.bodyMedium!.copyWith(color: c.mutedForeground),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[const SizedBox(height: GSpace.lg), action!],
        ],
      ),
    );
  }
}

/// Grey placeholder block; pulses gently while data loads.
class GSkeleton extends StatefulWidget {
  const GSkeleton({super.key, this.height = 16, this.width, this.radius = GRadius.control});
  final double height;
  final double? width;
  final double radius;

  @override
  State<GSkeleton> createState() => _GSkeletonState();
}

class _GSkeletonState extends State<GSkeleton> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 0.55, end: 1.0).animate(_ctrl),
    child: Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(color: context.c.surfaceSunken, borderRadius: BorderRadius.circular(widget.radius)),
    ),
  );
}

/// Skeleton list of card-shaped rows.
class GSkeletonList extends StatelessWidget {
  const GSkeletonList({super.key, this.count = 4, this.height = 72});
  final int count;
  final double height;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: GSpace.page, vertical: GSpace.sm),
    child: Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: GSpace.sm),
            child: GSkeleton(height: height, radius: GRadius.card),
          ),
      ],
    ),
  );
}

/// Renders an [AsyncValue]: data whenever there is any (also while
/// refreshing or after a failed refresh), skeleton on first load, error with
/// retry only when nothing is known.
class GAsync<T> extends StatelessWidget {
  const GAsync({super.key, required this.value, required this.data, this.loading, this.onRetry});
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (value.hasValue) return data(value.requireValue);
    if (value.hasError) {
      final l = context.l10n;
      return GEmptyState(
        icon: Icons.cloud_off_rounded,
        title: l.errorTitle,
        message: l.errorMessage,
        action: onRetry == null ? null : FilledButton.tonal(onPressed: onRetry, child: Text(l.retry)),
      );
    }
    return loading ?? const GSkeletonList();
  }
}
