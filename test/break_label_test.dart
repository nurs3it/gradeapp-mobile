import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/features/common/lesson_widgets.dart';
import 'package:gradeapp/l10n/gen/app_localizations.dart';

void main() {
  final ru = lookupAppLocalizations(const Locale('ru'));
  test('a break up to an hour; longer is a free window', () {
    expect(breakLabel(ru, 20), 'перемена 20 мин');
    expect(breakLabel(ru, 345), 'окно 5 ч 45 мин');
    expect(breakLabel(ru, 120), 'окно 2 ч');
  });
}
