import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/json.dart';
import '../core/providers.dart';

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});
  final ThemeMode themeMode;

  /// null = follow the phone's language.
  final Locale? locale;
}

/// Theme and language; device-level, survive sign-out. Read before the first
/// frame (boot prefs) so the app never flashes the wrong theme.
class SettingsController extends Notifier<AppSettings> {
  static const key = 'settings';

  @override
  AppSettings build() {
    final raw = ref.read(bootPrefsProvider)[key];
    if (raw is! Json) return const AppSettings();
    final lang = raw.strOrNull('locale');
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[raw.str('theme')] ?? ThemeMode.system,
      locale: lang == null ? null : Locale(lang),
    );
  }

  void setTheme(ThemeMode m) => _save(AppSettings(themeMode: m, locale: state.locale));
  void setLocale(Locale? l) => _save(AppSettings(themeMode: state.themeMode, locale: l));

  void _save(AppSettings s) {
    state = s;
    unawaited(ref.read(prefsProvider).write(key, {'theme': s.themeMode.name, 'locale': s.locale?.languageCode}));
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
