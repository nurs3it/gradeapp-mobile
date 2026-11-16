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
  });

  final String name;
  final String? url;
  final double size;
  final GAvatarTone tone;

  /// Fill for [GAvatarTone.colored]; defaults to a stable subject colour.
  final Color? color;

  /// Child switcher ring (2 pt, 2 pt canvas gap).
  final Color? ring;

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
    return ExcludeSemantics(child: circle);
  }
}
