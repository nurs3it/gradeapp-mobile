import 'package:flutter/material.dart';

import 'tokens/colors.dart';
import 'tokens/type.dart';

/// Thin Material theme around the «Веер» tokens: Onest, no ripple, platform
/// page transitions. Components read `context.c` / `context.t`, not Material.
ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.dark ? GColors.dark : GColors.light;
  final t = b == Brightness.dark ? GType.dark : GType.light;
  final scheme = ColorScheme.fromSeed(seedColor: GColors.brand, brightness: b).copyWith(
    primary: GColors.brand,
    onPrimary: GColors.onFill,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.ink2,
    error: c.bad,
    outline: c.hairline,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    fontFamily: GType.family,
    scaffoldBackgroundColor: c.canvas,
    canvasColor: c.canvas,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    dividerColor: c.hairline,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: GColors.brand,
      selectionColor: GColors.brand.withValues(alpha: 0.25),
      selectionHandleColor: GColors.brand,
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? GColors.brand : null),
    ),
    textTheme: TextTheme(bodyMedium: t.body, bodyLarge: t.body, titleMedium: t.headline, labelLarge: t.bodyStrong),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
    extensions: [c, t],
  );
}

extension GThemeX on BuildContext {
  GColors get c => Theme.of(this).extension<GColors>()!;
  GType get t => Theme.of(this).extension<GType>()!;
}
