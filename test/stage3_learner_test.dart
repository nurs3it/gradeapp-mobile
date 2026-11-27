import 'package:flutter_test/flutter_test.dart';
import 'package:gradeapp/core/grading.dart';
import 'package:gradeapp/features/common/models.dart';
import 'package:gradeapp/features/learner/streaks.dart';
import 'package:gradeapp/features/learner/week_card.dart';
import 'package:gradeapp/features/learner/weekly_summary.dart';
import 'package:gradeapp/features/notifications/notification_settings_screen.dart';
import 'package:gradeapp/features/notifications/notifications.dart';
import 'package:gradeapp/features/auth/user.dart';
import 'package:gradeapp/features/parent/attendance_logic.dart';
import 'package:gradeapp/features/parent/billing_models.dart';
import 'package:gradeapp/features/parent/weekly_summary_screen.dart';
import 'package:gradeapp/l10n/gen/app_localizations_en.dart';
import 'package:gradeapp/l10n/gen/app_localizations_kk.dart';
import 'package:gradeapp/l10n/gen/app_localizations_ru.dart';
import 'package:gradeapp/ui/ui.dart';

AttRecord rec(String date, Presence p) =>
    AttRecord(id: '$date$p', lessonId: 'l', date: date, course: 'Алгебра', start: '09:00', status: p);

Lesson lesson(String date, String start, String end, {LessonStatus status = LessonStatus.scheduled}) =>
    Lesson(id: start, courseId: 'c', subject: 'S', date: date, start: start, end: end, status: status);

void main() {
  group('ISO weeks', () {
    test('week id of a date', () {
      expect(isoWeekId(DateTime(2026, 11, 27)), '2026-W48');
      expect(isoWeekId(DateTime(2026, 11, 23)), '2026-W48');
      expect(isoWeekId(DateTime(2026, 11, 29)), '2026-W48');
      expect(isoWeekId(DateTime(2027, 1, 1)), '2026-W53');
      expect(isoWeekId(DateTime(2024, 12, 30)), '2025-W01');
    });

    test('monday of a week and navigation across a year', () {
      expect(mondayOfIsoWeek('2026-W48'), DateTime(2026, 11, 23));
      expect(mondayOfIsoWeek('bad'), isNull);
      expect(shiftIsoWeek('2026-W48', -1), '2026-W47');
      expect(shiftIsoWeek('2026-W48', 1), '2026-W49');
      expect(shiftIsoWeek('2026-W01', -1), '2025-W52');
      expect(shiftIsoWeek('2026-W53', 1), '2027-W01');
      expect(shiftIsoWeek('2026-W48', 0), '2026-W48');
    });
  });

  group('week card', () {
    final fri = DateTime(2026, 11, 27, 16);
    test('Friday only after the last lesson; weekends always', () {
      expect(weekCardVisible(fri, [lesson('2026-11-27', '09:00', '09:45'), lesson('2026-11-27', '15:00', '15:45')]), isTrue);
      expect(weekCardVisible(fri, [lesson('2026-11-27', '09:00', '09:45'), lesson('2026-11-27', '17:00', '17:45')]), isFalse);
      expect(weekCardVisible(fri, const []), isTrue);
      expect(weekCardVisible(DateTime(2026, 11, 26, 20), const []), isFalse);
      expect(weekCardVisible(DateTime(2026, 11, 28, 9), const []), isTrue);
      expect(weekCardVisible(DateTime(2026, 11, 29, 9), const []), isTrue);
    });

    test('cancelled lessons do not hold the card back', () {
      expect(
        weekCardVisible(fri, [lesson('2026-11-27', '17:00', '17:45', status: LessonStatus.cancelled)]),
        isTrue,
      );
    });

    final summary = WeeklySummary.fromJson({
      'week': '2026-W48',
      'date_from': '2026-11-23',
      'date_to': '2026-11-29',
      'empty': false,
      'verdict': {'code': 'great'},
      'attendance': {'days': 5, 'days_on_time': 4},
      'grades': {
        'count': 2,
        'by_subject': [
          {'course_id': 'a', 'name': 'Алгебра', 'avg': 8.5, 'prev_avg': 7.9, 'items': []},
        ],
      },
      'homework': {'assigned': 9, 'done': 7, 'overdue': 0},
    });

    test('by default the picture has no marks (legal)', () {
      final f = weekCardFacts(summary, null, withMarks: false);
      expect(f.hasMarks, isFalse);
      expect(f.subjects, isEmpty);
      expect((f.daysOnTime, f.days, f.hwDone, f.hwAssigned), (4, 5, 7, 9));
    });

    test('marks only with the explicit switch; milestone of this week only', () {
      final streaks = Streaks.fromJson({
        'enabled': true,
        'milestones': [
          {'kind': 'checkin', 'days': 5, 'reached_at': '2026-11-10'},
          {'kind': 'checkin', 'days': 10, 'reached_at': '2026-11-25'},
        ],
      });
      final f = weekCardFacts(summary, streaks, withMarks: true);
      expect(f.hasMarks, isTrue);
      expect(f.milestone, 10);
      expect(weekCardFacts(summary, null, withMarks: false).milestone, isNull);
    });
  });

  group('weekly verdict', () {
    test('codes map, unknown reads as steady', () {
      expect(weekVerdictCodeOf('dip'), WeekVerdictCode.dip);
      expect(weekVerdictCodeOf('absences'), WeekVerdictCode.absences);
      expect(weekVerdictCodeOf('whatever'), WeekVerdictCode.steady);
    });

    test('tone and sentence in every language', () {
      expect(weekVerdictTone(WeekVerdictCode.great), GTone.ok);
      expect(weekVerdictTone(WeekVerdictCode.dip), GTone.warn);
      expect(weekVerdictTone(WeekVerdictCode.empty), GTone.neutral);
      for (final l in [AppLocalizationsRu(), AppLocalizationsKk(), AppLocalizationsEn()]) {
        for (final code in WeekVerdictCode.values) {
          expect(weekVerdictText(l, WeekVerdict(code: code, courseName: 'Физика')), isNotEmpty);
        }
      }
      expect(
        weekVerdictText(AppLocalizationsRu(), const WeekVerdict(code: WeekVerdictCode.dip, courseName: 'Физика')),
        contains('Физика'),
      );
      expect(
        weekVerdictText(AppLocalizationsEn(), const WeekVerdict(code: WeekVerdictCode.dip)),
        isNot(contains('null')),
      );
    });

    test('delta arrow ignores noise', () {
      expect(deltaSign(0.6), 1);
      expect(deltaSign(-0.5), -1);
      expect(deltaSign(0.05), 0);
      expect(deltaSign(null), 0);
    });

    test('parses the contract payload', () {
      final s = WeeklySummary.fromJson({
        'week': '2026-W48',
        'date_from': '2026-11-23',
        'date_to': '2026-11-29',
        'empty': false,
        'verdict': {'code': 'dip', 'course_id': 'p', 'course_name': 'Физика'},
        'attendance': {'days': 5, 'days_on_time': 4, 'absent': 1, 'tardy': 1, 'excused': 0},
        'grades': {
          'count': 6,
          'by_subject': [
            {
              'course_id': 'a',
              'name': 'Алгебра',
              'avg': 8.5,
              'prev_avg': 7.9,
              'items': [
                {'id': '1', 'date': '2026-11-24', 'value': '9', 'kind': 'fo'},
              ],
            },
          ],
        },
        'homework': {'assigned': 9, 'done': 7, 'overdue': 1},
        'feedback': [
          {'id': 'f', 'date': '2026-11-25', 'text': 'Молодец', 'tags': ['positive'], 'from_name': 'Анна'},
        ],
        'upcoming': {
          'assessments': [
            {'course_name': 'Алгебра', 'kind': 'sor', 'date': '2026-12-02', 'title': 'СОР 2'},
          ],
          'events': [
            {'id': 'e', 'title': 'Праздник', 'start_date': '2026-12-01'},
          ],
        },
        'streaks': null,
      });
      expect(s.verdict.code, WeekVerdictCode.dip);
      expect(s.subjects.single.delta, closeTo(0.6, 1e-9));
      expect(s.feedback.single.positive, isTrue);
      expect(s.assessments.single.kind, 'sor');
      expect(s.checkinStreak, isNull);
    });
  });

  group('streaks', () {
    final json = {
      'enabled': true,
      'checkin': {'current': 12, 'best': 20, 'today': 'done', 'freezes_left': 2},
      'homework': {'current': 4, 'best': 9, 'today': 'pending', 'freezes_left': 0},
      'milestones': [
        {'kind': 'checkin', 'days': 5, 'reached_at': '2026-11-12'},
        {'kind': 'checkin', 'days': 10, 'reached_at': '2026-11-27'},
      ],
      'missed': [
        {'kind': 'checkin', 'date': '2026-11-26', 'freeze_until': '2026-11-27T23:59:59+05:00'},
        {'kind': 'homework', 'date': '2026-11-26', 'freeze_until': '2026-11-27T23:59:59+05:00'},
      ],
    };
    final s = Streaks.fromJson(json);

    test('state mapping', () {
      expect(streakTodayOf('done'), StreakToday.done);
      expect(streakTodayOf('excused'), StreakToday.excused);
      expect(streakTodayOf('frozen'), StreakToday.frozen);
      expect(streakTodayOf('???'), StreakToday.off);
      expect(s.checkin.today, StreakToday.done);
      expect(s.homework.today, StreakToday.pending);
      expect((s.checkin.current, s.checkin.best, s.checkin.freezesLeft), (12, 20, 2));
    });

    test('pages of the four-page mark follow the milestones 5/10/20/50', () {
      expect([for (final d in [0, 4, 5, 9, 10, 19, 20, 49, 50, 80]) pagesOf(d)], [0, 0, 1, 1, 2, 2, 3, 3, 4, 4]);
    });

    test('milestone of today, highest first', () {
      expect(milestoneReachedOn(s, '2026-11-27')?.days, 10);
      expect(milestoneReachedOn(s, '2026-11-26'), isNull);
    });

    test('freeze needs a freeze left and an open window', () {
      final now = DateTime.parse('2026-11-27T10:00:00+05:00');
      expect(canFreeze(s, s.missed.first, now), isTrue);
      expect(canFreeze(s, s.missed.last, now), isFalse); // homework: no freezes left
      expect(canFreeze(s, s.missed.first, DateTime.parse('2026-11-28T00:30:00+05:00')), isFalse);
    });

    test('disabled by the parent or the school', () {
      final off = Streaks.fromJson({'enabled': false, 'disabled_by_parent': true});
      expect(off.enabled, isFalse);
      expect(off.disabledByParent, isTrue);
      expect(Streaks.fromJson({'enabled': false}).disabledByParent, isFalse);
    });

    test('copy has no pressure words', () {
      for (final l in [AppLocalizationsRu(), AppLocalizationsKk(), AppLocalizationsEn()]) {
        for (final t in StreakToday.values) {
          for (final k in StreakKind.values) {
            final text = todayLine(l, t, k).toLowerCase();
            expect(text, isNot(contains('сгор')));
            expect(text, isNot(contains('не подведи')));
          }
        }
      }
      expect(AppLocalizationsRu().s10SickNote, 'Болеешь — оставайся дома: заявка серию не прерывает.');
    });
  });

  group('attendance calendar', () {
    test('worst mark of the day wins', () {
      expect(classifyDay([rec('d', Presence.present), rec('d', Presence.tardy)]), DayClass.tardy);
      expect(classifyDay([rec('d', Presence.present), rec('d', Presence.absent), rec('d', Presence.tardy)]), DayClass.absent);
      expect(classifyDay([rec('d', Presence.present), rec('d', Presence.excused)]), DayClass.excused);
      expect(classifyDay([rec('d', Presence.present)]), DayClass.present);
      expect(classifyDay(const []), DayClass.none);
      expect(classifyDay([rec('d', Presence.excused), rec('d', Presence.tardy)]), DayClass.tardy);
    });

    test('days are grouped by date', () {
      final m = classifyDays([rec('2026-11-02', Presence.present), rec('2026-11-03', Presence.absent), rec('2026-11-03', Presence.present)]);
      expect(m, {'2026-11-02': DayClass.present, '2026-11-03': DayClass.absent});
    });

    test('month grid starts on Monday', () {
      final cells = monthCells(DateTime(2026, 11, 1)); // Sunday
      expect(cells.take(6).every((c) => c == null), isTrue);
      expect(cells[6], DateTime(2026, 11, 1));
      expect(cells.whereType<DateTime>().length, 30);
      expect(monthCells(DateTime(2026, 6, 1)).first, DateTime(2026, 6, 1)); // Monday
      expect(shiftMonth(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 1));
    });

    test('absences list: newest first, only absent and excused', () {
      final l = absencesOf([rec('2026-11-02', Presence.absent), rec('2026-11-09', Presence.excused), rec('2026-11-05', Presence.present)]);
      expect(l.map((r) => r.date), ['2026-11-09', '2026-11-02']);
    });

    test('stats: no lessons means no percent', () {
      expect(AttStats.fromJson({'total': 0, 'attendance_rate': 0}).rate, isNull);
      expect(AttStats.fromJson({'total': 40, 'attendance_rate': 92.5, 'absent': 2}).rate, 92.5);
    });
  });

  group('billing', () {
    Invoice inv({String status = 'sent', String due = '2026-12-01', double paid = 0}) => Invoice.fromJson({
      'id': 'i',
      'number': 'A-1',
      'amount': '85000.00',
      'paid_total': '$paid',
      'due_date': due,
      'status': status,
    });

    test('overdue is shown for a sent invoice past due', () {
      expect(displayStatus(inv(), '2026-11-27'), InvoiceStatus.sent);
      expect(displayStatus(inv(due: '2026-11-20'), '2026-11-27'), InvoiceStatus.overdue);
      expect(displayStatus(inv(status: 'paid', due: '2026-11-20'), '2026-11-27'), InvoiceStatus.paid);
    });

    test('payment counts only when the server says so', () {
      expect(paymentArrived(paidBefore: 0, after: inv()), isFalse);
      expect(paymentArrived(paidBefore: 0, after: inv(status: 'paid', paid: 85000)), isTrue);
      expect(paymentArrived(paidBefore: 0, after: inv(status: 'partially_paid', paid: 30000)), isTrue);
      expect(paymentArrived(paidBefore: 30000, after: inv(status: 'partially_paid', paid: 30000)), isFalse);
    });

    test('money format and remaining amount', () {
      expect(fmtMoney(85000), '85 000');
      expect(fmtMoney(1234567), '1 234 567');
      expect(fmtMoney(900), '900');
      expect(fmtMoney(1500.5), '1 500,50');
      expect(inv(paid: 30000).remaining, 55000);
      expect(inv(paid: 90000).remaining, 0);
      expect(inv(status: 'cancelled').payable, isFalse);
    });

    test('list answer with requisites', () {
      final d = MyInvoices.fromJson({
        'results': [
          {'id': 'a', 'amount': '10', 'paid_total': '0', 'due_date': '2026-12-10', 'status': 'sent'},
          {'id': 'b', 'amount': '10', 'paid_total': '0', 'due_date': '2026-12-01', 'status': 'overdue'},
          {'id': 'c', 'amount': '10', 'paid_total': '10', 'due_date': '2026-11-01', 'status': 'paid'},
        ],
        'payment_requisites': {'recipient': 'НИШ ТОО', 'bin': '123456789012', 'iban': 'KZ1', 'junk': {'a': 1}},
        'kaspi_enabled': true,
      });
      expect(d.nextPayable?.id, 'b');
      expect(d.requisites.recipient, 'НИШ ТОО');
      expect(d.requisites.bin, '123456789012');
      expect(d.requisites.values.containsKey('junk'), isFalse);
      expect(d.kaspiEnabled, isTrue);
      expect(MyInvoices.fromJson({'results': [], 'kaspi_enabled': false}).requisites.isEmpty, isTrue);
    });

    test('confirmation text carries school, BIN, amount and the disclaimer', () {
      final ru = AppLocalizationsRu().p8Confirm('НИШ', '123', '85 000');
      expect(ru, contains('«НИШ», БИН 123'));
      expect(ru, contains('Сумма: 85 000 ₸'));
      expect(ru, contains('GradeApp не получает и не передаёт деньги'));
      expect(ru, contains('Фискальный чек формирует школа или платёжный сервис'));
      expect(AppLocalizationsRu().p8PdfTitle, 'Счёт на оплату');
      expect(AppLocalizationsRu().p8PdfCaption, 'Информационный документ, не является фискальным чеком');
      expect(AppLocalizationsEn().p8Confirm('S', '1', '2'), contains('does not receive or transfer money'));
      expect(AppLocalizationsKk().p8Confirm('S', '1', '2'), contains('GradeApp'));
    });
  });

  group('notifications', () {
    AppNotification n(String type, {Map<String, dynamic> payload = const {}}) => AppNotification(
      id: '1',
      type: type,
      payload: payload,
      read: false,
      createdAt: DateTime(2026, 11, 27),
    );

    test('digest.weekly opens the summary of the pushed week', () {
      final route = notificationRoute(n('digest.weekly', payload: {'student_id': 's1', 'week': '2026-W48'}), AppRole.parent);
      expect(route, '/week-summary?student=s1&week=2026-W48');
      expect(notificationRoute(n('digest.weekly'), AppRole.parent), '/week-summary');
      expect(notificationRoute(n('digest.weekly', payload: {'student_id': 's1'}), AppRole.teacher), isNull);
    });

    test('consent.requested lands on the parent Today', () {
      expect(notificationRoute(n('consent.requested'), AppRole.parent), '/p/today');
      expect(notificationRoute(n('consent.requested'), AppRole.student), isNull);
    });

    test('digest prefs have the contract defaults', () {
      expect(digestPrefsOf(const {}), (push: true, day: 'fri', hour: 18));
      expect(
        digestPrefsOf({'digest': {'push': false, 'day': 'sun', 'hour': 20}}),
        (push: false, day: 'sun', hour: 20),
      );
      expect(digestPrefsOf({'digest': {'day': 'mon', 'hour': 99}}), (push: true, day: 'fri', hour: 18));
    });
  });
}
