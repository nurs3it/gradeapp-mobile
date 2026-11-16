import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/json.dart';
import '../core/storage/json_cache.dart';

/// Device-level preferences; survive sign-out (unlike the API cache).
final prefsProvider = Provider<JsonCache>((_) => throw UnimplementedError());

class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});
  final ThemeMode themeMode;

  /// null = follow the phone's language.
  final Locale? locale;
}

class SettingsController extends Notifier<AppSettings> {
  static const _key = 'settings';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    final raw = await ref.read(prefsProvider).read(_key);
    if (raw is! Json) return;
    final lang = raw.strOrNull('locale');
    state = AppSettings(
      themeMode: ThemeMode.values.asNameMap()[raw.str('theme')] ?? ThemeMode.system,
      locale: lang == null ? null : Locale(lang),
    );
  }

  void setTheme(ThemeMode m) => _save(AppSettings(themeMode: m, locale: state.locale));
  void setLocale(Locale? l) => _save(AppSettings(themeMode: state.themeMode, locale: l));

  void _save(AppSettings s) {
    state = s;
    ref.read(prefsProvider).write(_key, {'theme': s.themeMode.name, 'locale': s.locale?.languageCode});
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
