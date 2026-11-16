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

String weekdayShort(DateTime d, String loc) => DateFormat.E(loc).format(d);

/// «16 ноября» / «понедельник, 16 ноября».
String dayMonth(DateTime d, String loc, {bool weekday = false}) =>
    (weekday ? DateFormat('EEEE, d MMMM', loc) : DateFormat('d MMMM', loc)).format(d);

String clock(DateTime d) => DateFormat.Hm().format(d);
