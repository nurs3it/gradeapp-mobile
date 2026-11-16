import 'package:flutter/material.dart';

import '../theme.dart';
import '../tokens/colors.dart';

enum GAvatarTone {
  /// Coloured fill with white initials (users, children).
  colored,

  /// `surface2` / `ink2` — roster students (no rainbow lists).
  neutral,

  /// `primary` — the current student in the grade pad.
  active,
}

/// Round avatar (§3.21): photo or initials.
class GAvatar extends StatelessWidget {
  const GAvatar({
    super.key,
    required this.name,
    this.url,
    this.size = 40,
    this.tone = GAvatarTone.colored,
    this.color,
    this.ring,
    this.online = false,
    this.onlineLabel,
    this.dotRing,
    this.dotTop = false,
  });

  final String name;
  final String? url;
  final double size;
  final GAvatarTone tone;

  /// Fill for [GAvatarTone.colored]; defaults to a stable subject colour.
  final Color? color;

  /// Child switcher ring (2 pt, 2 pt canvas gap).
  final Color? ring;

  /// Green «в сети» dot at the bottom right, cut out with [dotRing].
  final bool online;

  /// Spoken label of the dot; the avatar is otherwise decorative.
  final String? onlineLabel;

  /// Colour of the dot's ring: the surface the avatar sits on (`surface`).
  final Color? dotRing;

  /// Dot at the top right when the bottom right is taken by a badge.
  final bool dotTop;

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts.first.characters.first;
    final b = parts.length > 1 ? parts[1].characters.first : '';
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final (bg, fg) = switch (tone) {
      GAvatarTone.colored => (color ?? subjectOf(name).fill, GColors.onFill),
      GAvatarTone.neutral => (c.surface2, c.ink2),
      GAvatarTone.active => (GColors.brand, GColors.onFill),
    };
    final dpr = MediaQuery.devicePixelRatioOf(context);
    Widget circle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null
          ? Text(
              initials(name),
              style: context.t.subhead.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: size * 0.34),
              textScaler: TextScaler.noScaling,
            )
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              cacheWidth: (size * dpr).round(),
              errorBuilder: (_, _, _) => Text(initials(name), style: context.t.subhead.copyWith(color: fg)),
            ),
    );
    if (ring != null) {
      circle = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring!, width: 2),
        ),
        child: circle,
      );
    }
    if (online) {
      final d = (size * 0.28).clamp(10.0, 16.0);
      circle = Stack(
        clipBehavior: Clip.none,
        children: [
          circle,
          Positioned(
            right: ring == null ? -1 : 1,
            bottom: dotTop ? null : (ring == null ? -1 : 1),
            top: dotTop ? 1 : null,
            child: Container(
              width: d + 4,
              height: d + 4,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: dotRing ?? c.surface, shape: BoxShape.circle),
              child: DecoratedBox(
                decoration: BoxDecoration(color: c.ok, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      );
    }
    return Semantics(label: online ? onlineLabel : null, excludeSemantics: true, child: circle);
  }
}
