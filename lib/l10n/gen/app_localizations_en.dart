// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'GradeApp';

  @override
  String get loginTitle => 'Sign in to GradeApp';

  @override
  String get loginSubtitle => 'Use the email and password of your school account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get otpCode => 'Authenticator app code';

  @override
  String get otpHint => '6 digits';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginInvalid => 'Wrong email or password';

  @override
  String get loginOtpInvalid => 'Wrong code';

  @override
  String get loginNoRole => 'The mobile app currently supports student, parent and teacher accounts';

  @override
  String get signOut => 'Sign out';

  @override
  String get errorTitle => 'Couldn\'t load';

  @override
  String get errorMessage => 'Check your connection and try again';

  @override
  String get retry => 'Retry';

  @override
  String get offlineSaved => 'Saved on the phone — will be sent when you\'re back online';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting to sync',
      one: '$count change waiting to sync',
    );
    return '$_temp0';
  }

  @override
  String get syncRejected => 'The server didn\'t accept a change. Please check and mark it again';

  @override
  String get synced => 'Everything is synced';

  @override
  String get tabToday => 'Today';

  @override
  String get tabSchedule => 'Schedule';

  @override
  String get tabGrades => 'Grades';

  @override
  String get tabHomework => 'Homework';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabLessons => 'Lessons';

  @override
  String get now => 'Now';

  @override
  String get next => 'Next';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingDay(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '$count lesson',
      zero: 'No lessons',
    );
    return '$_temp0';
  }

  @override
  String get noLessonsTitle => 'No lessons';

  @override
  String get noLessonsMessage => 'There are no classes on this day';

  @override
  String room(String room) {
    return 'room $room';
  }

  @override
  String lessonEndsIn(int minutes) {
    return 'Ends in $minutes min';
  }

  @override
  String lessonStartsIn(int minutes) {
    return 'Starts in $minutes min';
  }

  @override
  String get dayDone => 'No more lessons today';

  @override
  String get presencePresent => 'Present';

  @override
  String get presenceAbsent => 'Absent';

  @override
  String get presenceTardy => 'Late';

  @override
  String get presenceExcused => 'Excused';

  @override
  String get presenceAbsentLong => 'Absent';

  @override
  String get presenceExcusedLong => 'Excused absence';

  @override
  String get checkInTitle => 'I\'m at school';

  @override
  String get checkInAction => 'Check in';

  @override
  String get checkInHint => 'Take a selfie at the entrance so your teacher sees you\'ve arrived';

  @override
  String checkInDone(String time) {
    return 'Checked in at $time';
  }

  @override
  String get checkInLate => 'Late';

  @override
  String checkInWindow(String from, String to) {
    return 'Check-in is open from $from to $to';
  }

  @override
  String get checkInNoConsent => 'A parent hasn\'t allowed photo check-in yet';

  @override
  String get checkInSending => 'Sending…';

  @override
  String get checkInSuccess => 'Done, you\'re checked in';

  @override
  String get checkInLocationDenied => 'Allow location access — the school checks that you\'re on site';

  @override
  String checkInOutside(int meters) {
    return 'You\'re outside the school area ($meters m)';
  }

  @override
  String get checkInStale => 'Take a new photo right now';

  @override
  String get checkInAlready => 'You\'ve already checked in today';

  @override
  String get checkInClosed => 'Check-in is closed';

  @override
  String childCheckedIn(String time) {
    return 'Arrived at school at $time';
  }

  @override
  String get childNotCheckedIn => 'Hasn\'t checked in yet';

  @override
  String get homeworkDue => 'Homework';

  @override
  String get homeworkEmptyTitle => 'No homework';

  @override
  String get homeworkEmptyMessage => 'New assignments will show up here';

  @override
  String get homeworkActive => 'To do';

  @override
  String get homeworkDoneTab => 'Done';

  @override
  String homeworkMinutes(int minutes) {
    return '≈ $minutes min';
  }

  @override
  String get dueToday => 'Due today';

  @override
  String get dueTomorrow => 'Due tomorrow';

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get attachments => 'Files';

  @override
  String get markDone => 'Mark as done';

  @override
  String get markUndone => 'Move back to to-do';

  @override
  String get recentGrades => 'Recent grades';

  @override
  String get gradesEmptyTitle => 'No grades yet';

  @override
  String get gradesEmptyMessage => 'Grades for all subjects will appear here';

  @override
  String get average => 'Average';

  @override
  String gradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count grades', one: '$count grade');
    return '$_temp0';
  }

  @override
  String get all => 'All';

  @override
  String get weekPrev => 'Previous week';

  @override
  String get weekNext => 'Next week';

  @override
  String get today => 'Today';

  @override
  String get profileChildren => 'Children';

  @override
  String get photoConsent => 'Photo check-in «I\'m at school»';

  @override
  String get photoConsentHint => 'Your child can check in with a selfie at the entrance';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get role => 'Account';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleStudent => 'Student';

  @override
  String get signOutConfirm => 'Sign out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get noChildrenTitle => 'No children linked';

  @override
  String get noChildrenMessage => 'Ask the school to link your child to your account';

  @override
  String get teacherTodayEmpty => 'No lessons today';

  @override
  String get overdueTitle => 'Not filled in';

  @override
  String get overdueHint => 'Lessons of the last two weeks without attendance or topic';

  @override
  String get missingAttendance => 'Attendance';

  @override
  String get missingTopic => 'Topic';

  @override
  String get missingHomework => 'Homework';

  @override
  String get missingGrades => 'Grades';

  @override
  String get allFilled => 'All filled in';

  @override
  String get lessonStart => 'Start lesson';

  @override
  String get lessonFinish => 'Finish lesson';

  @override
  String get lessonFinished => 'Lesson finished';

  @override
  String get lessonCancelled => 'Lesson cancelled';

  @override
  String get topic => 'Lesson topic';

  @override
  String get topicHint => 'e.g. Quadratic equations';

  @override
  String get allPresent => 'Everyone\'s here';

  @override
  String presentCount(int present, int total) {
    return '$present of $total present';
  }

  @override
  String get fromCheckIn => 'Checked in';

  @override
  String get fromHomeroom => 'Homeroom mark';

  @override
  String get workType => 'Work type';

  @override
  String gradeFor(String name) {
    return 'Grade: $name';
  }

  @override
  String get removeGrade => 'Remove';

  @override
  String gradeAbsentWarn(String name) {
    return '$name is absent. Grade anyway?';
  }

  @override
  String get rosterEmpty => 'No students in this class';

  @override
  String get autoNext => 'Jump to next student';

  @override
  String get done => 'Done';

  @override
  String get attendanceCodes => 'Attendance code';

  @override
  String get save => 'Save';
}
