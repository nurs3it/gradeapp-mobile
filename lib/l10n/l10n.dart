import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'gen/app_localizations.dart';

export 'gen/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String get localeTag => Localizations.localeOf(this).toLanguageTag();
}

/// Backend speaks `kz`, Flutter/ICU speak `kk`.
String apiLang(Locale l) => l.languageCode == 'kk' ? 'kz' : l.languageCode;
Locale localeFromApi(String lang) => Locale(lang == 'kz' ? 'kk' : lang);

/// Date formats used across the app; [loc] is `context.localeTag`.
abstract final class Fmt {
  /// «Понедельник, 16 ноября».
  static String weekdayDayMonth(DateTime d, String loc) => _cap(DateFormat('EEEE, d MMMM', loc).format(d));

  /// «16 ноября».
  static String dayMonth(DateTime d, String loc) => DateFormat('d MMMM', loc).format(d);

  /// «чт, 21 ноября».
  static String shortWeekdayDayMonth(DateTime d, String loc) => DateFormat('E, d MMMM', loc).format(d);

  /// «Пн».
  static String weekdayShort(DateTime d, String loc) => _cap(DateFormat.E(loc).format(d));

  /// «Вторник».
  static String weekday(DateTime d, String loc) => _cap(DateFormat.EEEE(loc).format(d));

  /// «16–21 ноября».
  static String range(DateTime a, DateTime b, String loc) => a.month == b.month
      ? '${a.day}–${DateFormat('d MMMM', loc).format(b)}'
      : '${DateFormat('d MMM', loc).format(a)} – ${DateFormat('d MMM', loc).format(b)}';

  /// «янв».
  static String monthShort(DateTime d, String loc) => DateFormat.MMM(loc).format(d).replaceAll('.', '');

  /// «Ноябрь 2026».
  static String monthYear(DateTime d, String loc) => _cap(DateFormat('LLLL y', loc).format(d));

  static String clock(DateTime d) => DateFormat.Hm().format(d);

  static String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
