import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/grading.dart';
import 'package:gradeapp/features/teacher/grade_pad.dart';
import 'package:gradeapp/features/teacher/lesson_screen.dart';
import 'package:gradeapp/features/teacher/teacher_models.dart';
import 'package:gradeapp/features/teacher/teacher_providers.dart';
import 'package:gradeapp/l10n/l10n.dart';
import 'package:gradeapp/ui/ui.dart';

Widget host(Widget child) => MaterialApp(
  theme: buildTheme(Brightness.light),
  locale: const Locale('ru'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('attendance toggle survives rapid flips (v0 red screen regression)', (tester) async {
    var cell = const RollCell(status: Presence.present);
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return Center(
              child: AttendanceToggle(cell: cell, absentCode: 'Н', enabled: true, onTap: () {}, onLongPress: () {}),
            );
          },
        ),
      ),
    );
    // Flip faster than the 160 ms cross-fade, many times over, through every state.
    const states = [Presence.absent, Presence.present, Presence.absent, Presence.tardy, Presence.present];
    for (var i = 0; i < 40; i++) {
      set(() => cell = RollCell(status: states[i % states.length], code: i.isEven ? 'Н' : ''));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Н'), findsWidgets);
  });

  testWidgets('grade pad 1–10: two rows of five, 6–10 at the bottom', (tester) async {
    const grading = Grading(min: 1, max: 10, passing: 4, qualityMin: 8, workTypes: [], attendanceCodes: []);
    final students = [
      for (var i = 0; i < 3; i++) RosterStudent(id: '$i', firstName: 'Имя$i', lastName: 'Фамилия$i', classId: 'c'),
    ];
    final picked = <num?>[];
    tester.view.physicalSize = const Size(375 * 3, 667 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        Align(
          alignment: Alignment.bottomCenter,
          child: GradePad(
            students: students,
            cells: {for (final s in students) s.id: const RollCell(status: Presence.present)},
            grading: grading,
            index: 0,
            typeLabel: 'ФО',
            onIndex: (_) {},
            onPick: (_, v, _) => picked.add(v),
            onClose: () {},
            onType: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final one = tester.getCenter(find.text('1'));
    final six = tester.getCenter(find.text('6'));
    final ten = tester.getCenter(find.text('10'));
    expect(six.dy, greaterThan(one.dy), reason: '6–10 under the thumb');
    expect(ten.dx, greaterThan(six.dx));
    await tester.tap(find.text('9'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(picked, [9]);
  });
}
