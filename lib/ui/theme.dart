import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Material 3 themed with GradeApp tokens. Touch density: controls 44pt+,
/// body 16/24 (web `pointer: coarse`).
ThemeData buildTheme(Brightness b) {
  final c = b == Brightness.light ? GColors.light : GColors.dark;
  final scheme = ColorScheme(
    brightness: b,
    primary: c.primary,
    onPrimary: Colors.white,
    primaryContainer: c.primarySoft,
    onPrimaryContainer: c.primarySoftForeground,
    secondary: c.primary,
    onSecondary: Colors.white,
    secondaryContainer: c.primarySoft,
    onSecondaryContainer: c.primarySoftForeground,
    error: c.destructive,
    onError: Colors.white,
    surface: c.card,
    onSurface: c.foreground,
    onSurfaceVariant: c.mutedForeground,
    surfaceContainerLowest: c.card,
    surfaceContainerLow: c.card,
    surfaceContainer: c.surfaceMuted,
    surfaceContainerHigh: c.popover,
    surfaceContainerHighest: c.surfaceSunken,
    outline: c.inputBorder,
    outlineVariant: c.border,
    scrim: c.overlay,
    shadow: Colors.black,
  );

  TextStyle s(double size, double height, FontWeight w, {double ls = 0, Color? color}) =>
      TextStyle(fontSize: size, height: height / size, fontWeight: w, letterSpacing: ls, color: color ?? c.foreground);

  final text = TextTheme(
    displaySmall: s(34, 40, FontWeight.w700, ls: -0.6), // large title
    headlineMedium: s(32, 38, FontWeight.w700, ls: -0.6), // SliverAppBar.large title
    headlineSmall: s(24, 30, FontWeight.w700, ls: -0.4),
    titleLarge: s(20, 26, FontWeight.w600, ls: -0.3),
    titleMedium: s(17, 22, FontWeight.w600, ls: -0.2),
    titleSmall: s(15, 20, FontWeight.w600),
    bodyLarge: s(16, 24, FontWeight.w400),
    bodyMedium: s(15, 22, FontWeight.w400),
    bodySmall: s(13, 18, FontWeight.w400, color: c.mutedForeground),
    labelLarge: s(16, 20, FontWeight.w600),
    labelMedium: s(13, 16, FontWeight.w500, color: c.mutedForeground),
    labelSmall: s(11, 14, FontWeight.w600, ls: 0.4, color: c.mutedForeground), // overline
  );

  final control = RoundedRectangleBorder(borderRadius: BorderRadius.circular(GRadius.control));
  const minSize = Size(44, 48);

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    textTheme: text,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    dividerTheme: DividerThemeData(color: c.divider, thickness: 1, space: 1),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: b == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: c.primarySoft,
      height: 64,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (st) => IconThemeData(
          size: 24,
          color: st.contains(WidgetState.selected) ? c.primarySoftForeground : c.mutedForeground,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (st) => text.labelMedium!.copyWith(
          fontSize: 11,
          color: st.contains(WidgetState.selected) ? c.primaryText : c.mutedForeground,
          fontWeight: st.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: minSize,
        shape: control,
        textStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: GSpace.lg),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: control,
        textStyle: text.labelLarge,
        foregroundColor: c.foreground,
        side: BorderSide(color: c.border),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: control,
        textStyle: text.labelLarge,
        foregroundColor: c.primaryText,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(minimumSize: const Size(44, 44), foregroundColor: c.foreground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.card,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: text.bodyLarge!.copyWith(color: c.subtleForeground),
      labelStyle: text.bodyLarge!.copyWith(color: c.mutedForeground),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GRadius.control),
        borderSide: BorderSide(color: c.inputBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GRadius.control),
        borderSide: BorderSide(color: c.inputBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GRadius.control),
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.popover,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: c.border,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(GRadius.overlay))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.popover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GRadius.overlay)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: b == Brightness.light ? c.foreground : c.popover,
      contentTextStyle: text.bodyMedium!.copyWith(color: b == Brightness.light ? c.card : c.foreground),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GRadius.card)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: c.surfaceMuted,
        selectedBackgroundColor: c.card,
        selectedForegroundColor: c.foreground,
        foregroundColor: c.mutedForeground,
        side: BorderSide.none,
        shape: control,
        textStyle: text.titleSmall,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary, linearTrackColor: c.surfaceMuted),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (st) => st.contains(WidgetState.selected) ? c.success : c.surfaceSunken,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    cupertinoOverrideTheme: CupertinoThemeData(primaryColor: c.primary, brightness: b),
  );
}
