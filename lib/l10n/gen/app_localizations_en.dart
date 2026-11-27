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
  String get tabToday => 'Today';

  @override
  String get tabWeek => 'Week';

  @override
  String get tabGrades => 'Grades';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabFamily => 'Family';

  @override
  String get tabInbox => 'Inbox';

  @override
  String tabWithBadge(String tab, int count) {
    return '$tab, $count new';
  }

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get undo => 'Undo';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get skip => 'Skip';

  @override
  String get notNow => 'Not now';

  @override
  String get continueAction => 'Continue';

  @override
  String get change => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get send => 'Send';

  @override
  String get errorTitle => 'Couldn’t load';

  @override
  String get errorOffline => 'No connection. Check the internet and try again';

  @override
  String get errorGeneric => 'Something went wrong. Please try again';

  @override
  String offlineBar(String time) {
    return 'Offline. Showing data from $time';
  }

  @override
  String get offlineBarNoTime => 'Offline. Showing saved data';

  @override
  String updatedAt(String time) {
    return 'Updated at $time';
  }

  @override
  String minutesShort(int m) {
    return '$m min';
  }

  @override
  String approxMinutes(int m) {
    return '≈ $m min';
  }

  @override
  String inMinutes(int m) {
    return 'in $m min';
  }

  @override
  String room(String room) {
    return 'room $room';
  }

  @override
  String nOfM(int n, int m) {
    return '$n of $m';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get todayWord => 'Today';

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
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count tasks', one: '$count task');
    return '$_temp0';
  }

  @override
  String tasksUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'tasks', one: 'task');
    return '$_temp0';
  }

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleParent => 'Parent';

  @override
  String get roleStudent => 'Student';

  @override
  String get notifications => 'Notifications';

  @override
  String notificationsUnread(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get profile => 'Profile';

  @override
  String switchChild(String name) {
    return 'Switch child, now $name';
  }

  @override
  String get profileSchools => 'Schools';

  @override
  String get profileChildren => 'Children';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get langSystem => 'System';

  @override
  String get langKk => 'Қазақша';

  @override
  String get langRu => 'Русский';

  @override
  String get langEn => 'English';

  @override
  String get openWeb => 'Open the web version';

  @override
  String get about => 'About';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutConfirm => 'Sign out?';

  @override
  String signOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records are',
      one: '$count record is',
    );
    return '$_temp0 not sent yet. They will be lost if you sign out';
  }

  @override
  String get signOutSendFirst => 'Send and sign out';

  @override
  String get signOutAnyway => 'Sign out without sending';

  @override
  String get signOutWaitNet => 'Offline — records are not sent yet';

  @override
  String get photoConsent => 'Selfie check-in';

  @override
  String get consentOn => 'allowed';

  @override
  String get consentOff => 'not allowed';

  @override
  String get consentRevoke => 'Turn off selfie check-in?';

  @override
  String get consentRevokeBody => 'Your child won’t be able to check in with a photo';

  @override
  String get consentRevokeAction => 'Turn off';

  @override
  String get switchSchoolFailed => 'Couldn’t switch school';

  @override
  String get noChildrenTitle => 'No children linked';

  @override
  String get noChildrenMessage => 'Ask your school to link your child to your account';

  @override
  String get allFamily => 'Whole family';

  @override
  String className(String name) {
    return 'class $name';
  }

  @override
  String get loginTagline => 'Schedule, grades and the school journal in one app';

  @override
  String get loginHow => 'How will you sign in?';

  @override
  String get loginWithPassword => 'Login and password';

  @override
  String get loginWithPasswordHint => 'The email or login from your school';

  @override
  String get loginWithCode => 'School code';

  @override
  String get loginWithCodeHint => 'A slip with a code like ABCDE-12345';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginField => 'Email or login';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get loginInvalid => 'Wrong login or password';

  @override
  String get loginBlocked => 'The account is locked — contact your school';

  @override
  String get loginThrottled => 'Too many attempts. Wait a minute';

  @override
  String get loginNoRole => 'The app supports student, parent and teacher accounts for now';

  @override
  String get otpTitle => 'Verification code';

  @override
  String get otpHint => 'Enter the 6 digits from your authenticator app';

  @override
  String get otpInvalid => 'Wrong code';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetHint => 'We’ll email you a link to set a new password';

  @override
  String get resetEmail => 'Email';

  @override
  String get resetSend => 'Send link';

  @override
  String get resetSentTitle => 'Check your email';

  @override
  String resetSentBody(String email) {
    return 'If $email is registered in GradeApp, a link is on its way';
  }

  @override
  String get resetOtherEmail => 'Use another address';

  @override
  String get codeTitle => 'School code';

  @override
  String get codeHint => 'The code is printed on the slip your school gave you';

  @override
  String get codeInvalid => 'Code not found or already used';

  @override
  String get codeIncomplete => 'The code has 10 characters';

  @override
  String get codePasswordTitle => 'Create a password';

  @override
  String get codePasswordHint => 'You’ll use it to sign in to the app and the website';

  @override
  String get codePwLength => 'At least 8 characters';

  @override
  String get codePwMixed => 'Letters and digits';

  @override
  String get codePwMatch => 'Passwords match';

  @override
  String get codePwRepeat => 'Repeat the password';

  @override
  String get codeLoginTitle => 'Your login';

  @override
  String get codeLoginHint => 'Use it to sign in on the web too';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String stepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get heroNow => 'Now';

  @override
  String get heroNext => 'Next';

  @override
  String heroLessonN(int n) {
    return 'lesson $n';
  }

  @override
  String get heroLast => 'last';

  @override
  String get heroPause => 'Break';

  @override
  String get heroPauseNext => 'next up';

  @override
  String get heroUntilBell => 'until the bell';

  @override
  String get heroUntilStart => 'until it starts';

  @override
  String get heroUntilLesson => 'until the lesson';

  @override
  String get heroMin => 'min';

  @override
  String get heroDayOver => 'Day is over';

  @override
  String get heroForTomorrow => 'For tomorrow';

  @override
  String get heroOpenTasks => 'Open tasks';

  @override
  String get heroNoLessons => 'No lessons today';

  @override
  String get heroRest => 'Time to rest';

  @override
  String get heroCancelled => 'cancelled';

  @override
  String get heroThen => 'Then';

  @override
  String heroInstead(String who, String whom) {
    return '$who instead of $whom';
  }

  @override
  String heroSemantic(String state, String subject, String details, String countdown) {
    return '$state $subject, $details. $countdown';
  }

  @override
  String heroCountdown(String label, int m) {
    return '$label: $m min';
  }

  @override
  String heroNextLine(String time, String subject) {
    return 'Next $time $subject';
  }

  @override
  String heroTomorrowPlan(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count lessons', one: '$count lesson');
    return 'Tomorrow $_temp0 from $time';
  }

  @override
  String heroTasksDone(int done, int total) {
    return 'Homework done: $done of $total';
  }

  @override
  String get tileTomorrow => 'For tomorrow';

  @override
  String get tileNewGrades => 'New grades';

  @override
  String get tileOverdue => 'Overdue';

  @override
  String get dayPlan => 'Today’s plan';

  @override
  String lessonsPassed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons done',
      one: '$count lesson done',
    );
    return '$_temp0';
  }

  @override
  String get pillNow => 'now';

  @override
  String get pillSubstitution => 'substitute';

  @override
  String get pillCancelled => 'cancelled';

  @override
  String get pillJoint => 'joint';

  @override
  String breakLine(int m) {
    return 'break $m min';
  }

  @override
  String get checkInTitle => 'I’m at school';

  @override
  String checkInBy(String time) {
    return 'Check in by $time';
  }

  @override
  String get checkInSubtitle => 'A selfie at the entrance — 5 seconds';

  @override
  String checkInOpensAt(String time) {
    return 'Check-in opens at $time';
  }

  @override
  String checkInDoneAt(String time) {
    return 'At school since $time';
  }

  @override
  String get checkInOnTime => 'Checked in on time';

  @override
  String checkInLateAt(String time) {
    return 'Checked in at $time · late';
  }

  @override
  String checkInClosed(String time) {
    return 'Check-in closed at $time';
  }

  @override
  String get checkInClosedHint => 'If you’re already at school, tell your homeroom teacher';

  @override
  String get checkInNoConsent => 'A parent needs to allow photos';

  @override
  String get checkInAskParent => 'How to ask a parent';

  @override
  String get checkInAskParentHint => 'A parent allows it in their GradeApp: Today → Allow. It takes a minute';

  @override
  String get checkInSending => 'Sending the photo…';

  @override
  String checkInSendingPct(int pct) {
    return 'Sending… $pct%';
  }

  @override
  String checkInOutside(int meters) {
    return 'You’re $meters m from school. Get closer to the entrance and try again';
  }

  @override
  String get checkInNeedLocation => 'Turn on location';

  @override
  String get checkInStale => 'Take a new photo';

  @override
  String get checkInOffline => 'No connection. We’ll retry without a new photo while the window is open';

  @override
  String get checkInAlready => 'You’ve already checked in today';

  @override
  String get checkInWindowClosed => 'The check-in window is closed';

  @override
  String get checkInFailed => 'Couldn’t send the photo';

  @override
  String get checkInOpenCamera => 'Open the camera';

  @override
  String get camLocating => 'Finding your location…';

  @override
  String camAtSchool(String time) {
    return 'At school · open until $time';
  }

  @override
  String camWindowUntil(String time) {
    return 'Open until $time';
  }

  @override
  String get camFar => 'Far from school';

  @override
  String get camHint => 'Face in the oval, then shoot';

  @override
  String get camPrivacy => 'Only school staff will see the photo. It’s deleted after 30 days';

  @override
  String get camShutter => 'Take photo';

  @override
  String get camFlashOn => 'Turn on screen flash';

  @override
  String get camFlashOff => 'Turn off screen flash';

  @override
  String get camRetake => 'Retake';

  @override
  String get camUnavailable => 'Camera unavailable';

  @override
  String get camDenied => 'Allow Camera for GradeApp in your phone settings';

  @override
  String get camExplainTitle => 'Selfie check-in';

  @override
  String get camExplainWhy => 'A selfie at the entrance confirms you’re at school';

  @override
  String get camExplainWho => 'Only school staff see the photo';

  @override
  String get camExplainKeep => 'The photo is deleted after 30 days';

  @override
  String get doneTitle => 'Checked in';

  @override
  String doneOnTime(String time) {
    return '$time · on time';
  }

  @override
  String doneLate(String time) {
    return '$time · late';
  }

  @override
  String doneLateMin(String time, int m) {
    return '$time · $m min late';
  }

  @override
  String doneFirstLesson(String time) {
    return 'First lesson · $time';
  }

  @override
  String get doneParents => 'Your parents will see it in the app';

  @override
  String weekEyebrow(String range, String term) {
    return '$range · $term';
  }

  @override
  String get weekGoToday => 'Today';

  @override
  String weekDaySpan(String lessons, String from, String to) {
    return '$lessons · $from–$to';
  }

  @override
  String get weekNoLessons => 'No lessons';

  @override
  String get weekNoLessonsHint => 'No classes on this day';

  @override
  String get weekPrev => 'Previous week';

  @override
  String get weekNext => 'Next week';

  @override
  String get hwShort => 'HW';

  @override
  String get dotChanges => 'changes';

  @override
  String get dotHomework => 'homework due';

  @override
  String get dotExam => 'summative test';

  @override
  String lessonOrdinal(String weekday, int n) {
    return '$weekday · lesson $n';
  }

  @override
  String get teacher => 'Teacher';

  @override
  String get topicLabel => 'Topic';

  @override
  String get lessonHomework => 'Homework for this lesson';

  @override
  String get myMarks => 'My marks';

  @override
  String get childMarks => 'Marks';

  @override
  String get notFilledYet => 'The teacher hasn’t filled this in yet';

  @override
  String get explainAbsence => 'Explain the absence';

  @override
  String get openLesson => 'Open lesson';

  @override
  String get presencePresent => 'present';

  @override
  String get presenceAbsent => 'absent';

  @override
  String get presenceTardy => 'late';

  @override
  String get presenceExcused => 'excused';

  @override
  String gradesEyebrow(String term, int week) {
    return '$term · week $week';
  }

  @override
  String termShort(int n) {
    return 'Q$n';
  }

  @override
  String get termRunning => 'now';

  @override
  String termPick(String term) {
    return 'Choose $term';
  }

  @override
  String get segSubjects => 'Subjects';

  @override
  String get segFeed => 'Feed';

  @override
  String subjectsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count subjects', one: '$count subject');
    return '$_temp0';
  }

  @override
  String get sortAttention => 'Needs attention first';

  @override
  String get sortAlpha => 'Alphabetical';

  @override
  String get prelim => 'prelim.';

  @override
  String get gradesEmpty => 'No grades this quarter yet';

  @override
  String get gradesEmptyHint => 'The first one will appear after a lesson';

  @override
  String insightStrong(String subject) {
    return 'Strongest: $subject.';
  }

  @override
  String insightWeak(String subject, int pct) {
    return '$subject needs attention: $pct%.';
  }

  @override
  String quarterResults(String term) {
    return 'Results: $term';
  }

  @override
  String get howCalculated => 'How the quarter mark is calculated';

  @override
  String get howCalcBody => 'The school and the report card use the same formula';

  @override
  String get howCalcMissing => 'If a part is missing so far, its weight goes to the others';

  @override
  String get pctToMark => '% → mark';

  @override
  String pctFrom(int pct) {
    return 'from $pct%';
  }

  @override
  String get formulaMissing => 'The school formula didn’t load, so the quarter mark is hidden';

  @override
  String subjectPrelim(String term) {
    return '$term · preliminary';
  }

  @override
  String subjectFinal(String term) {
    return '$term · final';
  }

  @override
  String worksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count works', one: '$count work');
    return '$_temp0';
  }

  @override
  String toNextMark(String mark, int pct) {
    return '$pct% short of $mark';
  }

  @override
  String get works => 'Works';

  @override
  String get newestFirst => 'newest first';

  @override
  String get kindFo => 'FA';

  @override
  String get kindSor => 'SAU';

  @override
  String get kindSoch => 'SAT';

  @override
  String gradeSemantic(String value, String tone) {
    return 'Grade $value, $tone';
  }

  @override
  String get toneExcellent => 'excellent';

  @override
  String get toneGood => 'good';

  @override
  String get toneFair => 'satisfactory';

  @override
  String get tonePoor => 'unsatisfactory';

  @override
  String get newWord => 'new';

  @override
  String tasksEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count tasks', one: '$count task');
    return 'This week: $_temp0';
  }

  @override
  String get sectionOverdue => 'Overdue';

  @override
  String get sectionToday => 'Today';

  @override
  String get sectionTomorrow => 'Tomorrow';

  @override
  String get sectionWeek => 'This week';

  @override
  String get sectionLater => 'Later';

  @override
  String sectionDone(int count) {
    return 'Done: $count';
  }

  @override
  String get allSubjects => 'All';

  @override
  String get markDone => 'Mark as done';

  @override
  String get markUndone => 'Move back to to-do';

  @override
  String get doneToast => 'Marked as done';

  @override
  String get undoneToast => 'Moved back to the list';

  @override
  String get hwDone => 'done';

  @override
  String get hwNotDone => 'not done';

  @override
  String dueBy(String date) {
    return 'by $date';
  }

  @override
  String attachmentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attachments',
      one: '$count attachment',
    );
    return '$_temp0';
  }

  @override
  String get tasksEmpty => 'No tasks';

  @override
  String get tasksEmptyHint => 'New tasks from teachers will show up here';

  @override
  String taskToggleDone(String title) {
    return 'Mark “$title” as done';
  }

  @override
  String taskToggleUndone(String title) {
    return 'Move “$title” back';
  }

  @override
  String get openFile => 'Open file';

  @override
  String loadToday(int used, int norm) {
    return 'Load $used of $norm min';
  }

  @override
  String get verdictOk => 'All good';

  @override
  String get verdictQuestion => 'Something to check';

  @override
  String get verdictAction => 'Action needed';

  @override
  String get verdictAlarm => 'Hasn’t checked in';

  @override
  String get verdictNoLessons => 'No lessons today';

  @override
  String verdictUpdated(String time) {
    return 'As of $time';
  }

  @override
  String factArrived(String time) {
    return 'At school since $time.';
  }

  @override
  String factLessons(int done, int total) {
    return '$done of $total lessons.';
  }

  @override
  String factBeforeLessons(String time) {
    return 'First lesson at $time.';
  }

  @override
  String factAbsent(String subject) {
    return 'Missed: $subject';
  }

  @override
  String get factNoReason => 'no reason given.';

  @override
  String factLate(String time) {
    return 'Late: checked in at $time.';
  }

  @override
  String factLowGrade(String subject, String value) {
    return 'Low grade: $subject $value.';
  }

  @override
  String get factExcused => 'Excused for today.';

  @override
  String factAlarm(String time) {
    return 'The first lesson started at $time. No check-in and no request.';
  }

  @override
  String get factNoConsent => 'Selfie check-in is waiting for your permission.';

  @override
  String factTomorrow(String lessons, String time) {
    return 'Tomorrow $lessons from $time.';
  }

  @override
  String factNewGrade(String subject) {
    return 'new grade · $subject';
  }

  @override
  String get actExcuse => 'Excuse';

  @override
  String get actExplain => 'Explain absence';

  @override
  String get actAllow => 'Allow';

  @override
  String get attentionTitle => 'Needs attention';

  @override
  String attAbsent(String time) {
    return 'Absent · $time';
  }

  @override
  String get attNoConsent => 'Selfie check-in';

  @override
  String get attNoConsentSub => 'Needs your permission';

  @override
  String get attRejected => 'Request declined';

  @override
  String get attPending => 'Your request is with the homeroom teacher';

  @override
  String get feedTitle => 'Today’s feed';

  @override
  String get feedNewest => 'newest first';

  @override
  String get feedArrived => 'Arrived at school';

  @override
  String feedArrivedSub(String state) {
    return 'selfie check-in · $state';
  }

  @override
  String get feedOnTime => 'on time';

  @override
  String get feedLate => 'late';

  @override
  String get feedNow => 'in progress';

  @override
  String get feedMarkedAbsent => 'marked absent';

  @override
  String get feedEmpty => 'Nothing has happened yet';

  @override
  String forTomorrowLine(String tasks, int m, int done) {
    return '$tasks · ≈ $m min · $done done';
  }

  @override
  String get familyTitle => 'Family';

  @override
  String get familyNotChecked => 'not checked in';

  @override
  String get familyAllGood => 'all good';

  @override
  String get familyQuestion => 'check';

  @override
  String get familyNoLessons => 'no lessons';

  @override
  String get familyExcuseCard => 'Excuse your child';

  @override
  String get familyExcuseHint => 'Illness, family, a doctor — the request goes to the homeroom teacher';

  @override
  String get requests => 'Requests';

  @override
  String get reqPending => 'pending';

  @override
  String get reqApproved => 'approved';

  @override
  String get reqRejected => 'declined';

  @override
  String get reqCancelled => 'withdrawn';

  @override
  String get reqWithdraw => 'Withdraw request';

  @override
  String get reqWithdrawConfirm => 'Withdraw the request?';

  @override
  String get reqEmpty => 'No requests yet';

  @override
  String get reqEmptyHint => 'When you excuse your child, the request shows up here';

  @override
  String get catIllness => 'Illness';

  @override
  String get catFamily => 'Family';

  @override
  String get catAppointment => 'Appointment';

  @override
  String get catOther => 'Other';

  @override
  String excuseTitle(String name) {
    return 'Excuse $name';
  }

  @override
  String get excuseWhen => 'When';

  @override
  String get excuseDates => 'Dates';

  @override
  String get excuseLessons => 'Lessons';

  @override
  String get excuseFrom => 'From';

  @override
  String get excuseTo => 'To';

  @override
  String get excuseReason => 'Reason';

  @override
  String get excuseComment => 'Comment';

  @override
  String get excuseCommentHint => 'Optional';

  @override
  String get excuseProof => 'Note';

  @override
  String get excuseCamera => 'Camera';

  @override
  String get excuseGallery => 'Gallery';

  @override
  String get excuseRemoveProof => 'Remove the note';

  @override
  String get excuseSend => 'Send to homeroom teacher';

  @override
  String get excuseSent => 'Request sent';

  @override
  String get excusePickLessons => 'Choose at least one lesson';

  @override
  String get excuseOffline => 'Offline. Send it when you’re back online';

  @override
  String get excuseFailed => 'Couldn’t send the request';

  @override
  String get consentSheetTitle => 'Allow selfie check-in?';

  @override
  String get consentWho => 'Only school staff see the photo';

  @override
  String get consentKeep => 'Deleted after 30 days';

  @override
  String get consentWhere => 'You can turn it off in the child’s profile';

  @override
  String consentAllowed(String name) {
    return '$name can check in now';
  }

  @override
  String get consentFailed => 'Couldn’t save the permission';

  @override
  String tUntilBell(int m) {
    return '$m min to the bell';
  }

  @override
  String tStartsIn(int m) {
    return 'in $m min';
  }

  @override
  String tFree(int m) {
    return 'free $m min';
  }

  @override
  String tStudents(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count students', one: '$count student');
    return '$_temp0';
  }

  @override
  String get tRollNotDone => 'Roll call not done';

  @override
  String get tRollDone => 'Roll call done';

  @override
  String get tTopicDone => 'topic ✓';

  @override
  String get tCloseDay => 'Close the day';

  @override
  String tActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count actions', one: '$count action');
    return '$_temp0';
  }

  @override
  String get tDayClosed => 'Day closed';

  @override
  String get tDayClosedHint => 'All lessons are filled in';

  @override
  String get tNoLessons => 'No lessons today';

  @override
  String get tUnmarked => 'unmarked';

  @override
  String get tNoTopic => 'no topic';

  @override
  String get tLessons => 'Lessons';

  @override
  String tTodayCount(int count) {
    return '$count today';
  }

  @override
  String get missingAttendance => 'attendance';

  @override
  String get missingTopic => 'topic';

  @override
  String get missingHomework => 'homework';

  @override
  String get missingGrades => 'grades';

  @override
  String tMissingWhat(String what, String lesson) {
    return '$what: $lesson';
  }

  @override
  String get tDebts => 'Open items, last 14 days';

  @override
  String tDebtsUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons unmarked',
      one: '$count lesson unmarked',
    );
    return '$_temp0';
  }

  @override
  String get tCloseAll => 'Close all, everyone present';

  @override
  String get tCloseAllConfirm => 'Mark everyone present?';

  @override
  String get tCloseAllBody => 'Only lessons without any marks. You can fix it later in the lesson';

  @override
  String tAllPresentToast(String cls) {
    return '$cls: everyone present';
  }

  @override
  String get tAllPresent => 'Everyone present';

  @override
  String tLessonRowSemantic(String time, String cls, String subject, String state) {
    return '$time, $cls, $subject. $state';
  }

  @override
  String get tAllFilled => 'all filled in';

  @override
  String tJointClasses(String a, String b) {
    return '$a + $b';
  }

  @override
  String get lessonOver => 'lesson over';

  @override
  String get topicCard => 'Lesson topic';

  @override
  String ktpChip(String topic) {
    return 'Plan: $topic';
  }

  @override
  String get sameAsLast => 'Same as last time';

  @override
  String get topicHint => 'E.g. Similar triangles';

  @override
  String get topicSaved => 'Topic saved';

  @override
  String get presentLabel => 'Present';

  @override
  String get searchStudent => 'Find a student';

  @override
  String get viewList => 'List';

  @override
  String get viewFaces => 'Faces';

  @override
  String sourceCheckIn(String time) {
    return 'checked in · $time';
  }

  @override
  String get sourceCheckInShort => 'checked in';

  @override
  String get sourceHomeroom => 'homeroom mark';

  @override
  String lateBy(int m) {
    return '$m min late';
  }

  @override
  String notSaved(String reason) {
    return 'not saved: $reason';
  }

  @override
  String get reasonSochShort => 'SAT day';

  @override
  String get reasonSoch => 'SAT day — marks are not accepted';

  @override
  String get reasonForbiddenShort => 'no rights';

  @override
  String get reasonForbidden => 'No rights for this lesson';

  @override
  String get reasonNotFound => 'The lesson or student was removed';

  @override
  String get reasonInvalid => 'The server refused the record';

  @override
  String sochBanner(String subject) {
    return 'SAT in $subject today.';
  }

  @override
  String get sochBannerBody => 'Current grades and attendance are closed';

  @override
  String pendingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count marks are waiting for the network.',
      one: '$count mark is waiting for the network.',
    );
    return '$_temp0';
  }

  @override
  String get pendingBannerBody => 'We’ll send them';

  @override
  String rejectedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records not saved.',
      one: '$count record not saved.',
    );
    return '$_temp0';
  }

  @override
  String get openQueue => 'Open';

  @override
  String get dockHomework => 'HW';

  @override
  String get dockSummary => 'Summary';

  @override
  String dockAllPresent(int count) {
    return 'All present · $count';
  }

  @override
  String dockDone(int n, int m) {
    return 'Done · $n of $m';
  }

  @override
  String get dockFinish => 'Finish lesson';

  @override
  String get dockSochDay => 'SAT day';

  @override
  String get rollSaved => 'Roll call saved';

  @override
  String markedToast(String name, String state) {
    return '$name — $state';
  }

  @override
  String get stateAbsent => 'absent';

  @override
  String get statePresent => 'present';

  @override
  String get rowPresentHint => 'Double-tap to mark absent';

  @override
  String get rowAbsentHint => 'Double-tap to mark present';

  @override
  String get actionCodes => 'Attendance codes';

  @override
  String codesTitle(String name) {
    return '$name';
  }

  @override
  String get codeLate => 'Late';

  @override
  String get codeLateMinutes => 'How many minutes';

  @override
  String get codeCustom => 'Other';

  @override
  String get codeSick => 'Sick';

  @override
  String get codeExcused => 'Excused';

  @override
  String get codePresent => 'Present';

  @override
  String get codeAbsent => 'Absent';

  @override
  String get lessonStartedToast => 'Lesson started';

  @override
  String padOf(int n, int total) {
    return '$n of $total';
  }

  @override
  String get padComment => 'Comment';

  @override
  String get padCommentHint => 'Attaches to the next grade';

  @override
  String padAbsentWarn(String name) {
    return '$name is marked absent. Grade anyway?';
  }

  @override
  String get padPut => 'Grade';

  @override
  String get padRemoved => 'Grade removed';

  @override
  String padKey(String v, String tone) {
    return 'Grade $v, $tone';
  }

  @override
  String padSelected(int count) {
    return '$count selected';
  }

  @override
  String get padPrev => 'Previous student';

  @override
  String get padNext => 'Next student';

  @override
  String gradeSlot(String name) {
    return 'Grade: $name';
  }

  @override
  String get gradeLocked => 'Grades are locked';

  @override
  String get scaleViewOnly => 'This scale is graded in the web journal';

  @override
  String get selectMode => 'Select students';

  @override
  String get workType => 'Work type';

  @override
  String get menuMore => 'More';

  @override
  String get menuGradeAll => 'Grade everyone';

  @override
  String get menuOpenWeb => 'Open the journal on the web';

  @override
  String get menuStart => 'Start lesson';

  @override
  String jointPill(int count) {
    return 'joint · $count';
  }

  @override
  String classHeader(String cls, int count) {
    return '$cls · $count';
  }

  @override
  String get rosterEmpty => 'No students in this class';

  @override
  String hwSheetTitle(String cls) {
    return 'Homework for $cls';
  }

  @override
  String get hwTextHint => 'Section 12, exercises 3–7';

  @override
  String get hwDue => 'Due';

  @override
  String hwDueNextLesson(String date) {
    return 'Next lesson · $date';
  }

  @override
  String get hwTime => 'Time to complete';

  @override
  String hwLoad(String day, int used, int norm) {
    return '$day: already $used of $norm min';
  }

  @override
  String hwOverNorm(int m) {
    return '$m min over the norm';
  }

  @override
  String get hwAssign => 'Assign';

  @override
  String hwAssigned(String cls) {
    return 'Homework set · $cls';
  }

  @override
  String get hwExisting => 'Already set';

  @override
  String get hwFailed => 'Couldn’t set homework';

  @override
  String get hwOffline => 'Offline — the homework goes out when you’re back online';

  @override
  String get hwOtherDate => 'Another date';

  @override
  String get sumTitle => 'Lesson summary';

  @override
  String sumAttendance(int n, int m) {
    return 'Attendance · $n of $m';
  }

  @override
  String get sumTopic => 'Topic';

  @override
  String get sumHomework => 'Homework';

  @override
  String sumGrades(int count) {
    return 'Grades · $count';
  }

  @override
  String get sumField => 'Lesson notes, optional';

  @override
  String get lessonFinishedToast => 'Lesson finished';

  @override
  String get syncTitle => 'Sync';

  @override
  String syncLast(String time) {
    return 'Last sent at $time';
  }

  @override
  String syncRejected(int count) {
    return 'Refused · $count';
  }

  @override
  String syncWaiting(int count) {
    return 'Waiting · $count';
  }

  @override
  String get syncAllSent => 'Everything is sent';

  @override
  String get syncAllSentHint => 'Marks, grades and topics are on the server';

  @override
  String get syncDeleteConfirm => 'Delete the record?';

  @override
  String get syncDeleteBody => 'It will be lost without sending';

  @override
  String get syncSending => 'Sending';

  @override
  String syncPendingN(int count) {
    return 'Waiting to send: $count';
  }

  @override
  String syncRejectedN(int count) {
    return 'Not saved: $count';
  }

  @override
  String whatAttendance(String state) {
    return 'Attendance “$state”';
  }

  @override
  String whatGrade(String v) {
    return 'Grade $v';
  }

  @override
  String get whatGradeRemoved => 'Grade removed';

  @override
  String get whatTopic => 'Lesson topic';

  @override
  String get whatStart => 'Lesson start';

  @override
  String get whatFinish => 'Lesson end';

  @override
  String get whatHomework => 'Homework';

  @override
  String whatAllPresent(int count) {
    return 'All present · $count';
  }

  @override
  String get whatSummary => 'Lesson summary';

  @override
  String createdAt(String time) {
    return 'created at $time';
  }

  @override
  String get inboxAction => 'Needs action';

  @override
  String get inboxSchedule => 'Schedule';

  @override
  String get inboxOther => 'Other';

  @override
  String get inboxEmpty => 'Inbox is empty';

  @override
  String get inboxEmptyHint => 'Unmarked lessons, refused records, substitutions and announcements will show up here';

  @override
  String get inboxRejected => 'Records not saved';

  @override
  String get inboxRejectedSub => 'Open the queue to retry or delete';

  @override
  String inboxExcuses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count absence requests',
      one: '$count absence request',
    );
    return '$_temp0';
  }

  @override
  String get inboxExcusesSub => 'Approve or decline them on the web';

  @override
  String get markRead => 'Read';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get notifEmpty => 'No notifications';

  @override
  String get notifEmptyHint => 'Grades, homework, substitutions and request decisions will show up here';

  @override
  String get notifUnavailable => 'This item was deleted or is unavailable';

  @override
  String get notifUnavailableHint => 'It may have been changed at school. Everything else works as usual';

  @override
  String get ntGradeCreated => 'New grade';

  @override
  String get ntGradeUpdated => 'Grade updated';

  @override
  String get ntHomework => 'Homework';

  @override
  String get ntHomeworkReminder => 'Homework reminder';

  @override
  String get ntLessonCancelled => 'Lesson cancelled';

  @override
  String get ntLessonRescheduled => 'Lesson rescheduled';

  @override
  String get ntSubstitution => 'Substitution';

  @override
  String get ntLessonStarted => 'Lesson started';

  @override
  String get ntCheckIn => 'Your child arrived at school';

  @override
  String get ntAttendance => 'Attendance';

  @override
  String get ntUnmarked => 'Mark attendance';

  @override
  String get ntGradesReminder => 'Add grades';

  @override
  String get ntExcusePending => 'New request';

  @override
  String get ntExcuseApproved => 'Request approved';

  @override
  String get ntExcuseRejected => 'Request declined';

  @override
  String get ntExcuseCancelled => 'Request withdrawn';

  @override
  String get ntInvoice => 'Invoice';

  @override
  String get ntEvent => 'School event';

  @override
  String get ntChat => 'New message';

  @override
  String get ntOther => 'Notification';

  @override
  String get ngGrades => 'Grades';

  @override
  String get ngHomework => 'Homework';

  @override
  String get ngSchedule => 'Schedule and substitutions';

  @override
  String get ngAttendance => 'Attendance and arrival';

  @override
  String get ngChat => 'Messages';

  @override
  String get ngBilling => 'Payments';

  @override
  String get ngGeneral => 'Important';

  @override
  String get pushAskTitle => 'Turn on notifications?';

  @override
  String get pushAskAllow => 'Turn on';

  @override
  String get pushWhyStudent => 'Know right away about a new grade, homework or a lesson change.';

  @override
  String get pushWhyParent =>
      'Know right away when your child arrives at school, gets a grade or misses a lesson. Grades themselves never show on the lock screen.';

  @override
  String get pushWhyTeacher =>
      'We\'ll remind you about unmarked attendance and tell you about substitutions and new requests.';

  @override
  String get notifSettings => 'Notifications';

  @override
  String get notifSettingsHint =>
      'The bell in the app shows everything. Here you choose what comes to the phone as a push.';

  @override
  String get pushOffTitle => 'Notifications are off in phone settings';

  @override
  String get pushOffOpen => 'Open settings';

  @override
  String get pushTurnOn => 'Turn on notifications';

  @override
  String get pushUnavailable => 'Push notifications are not available in this build';

  @override
  String get notifOpen => 'Open';

  @override
  String get presenceOnline => 'Online';

  @override
  String get lockSetting => 'App lock';

  @override
  String get lockSettingHint =>
      'Face ID, fingerprint or phone passcode at launch and after 5 minutes in the background';

  @override
  String get lockReason => 'Confirm it\'s you';

  @override
  String get lockTitle => 'GradeApp is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockUnavailable => 'Set up Face ID, a fingerprint or a passcode in the phone\'s settings';

  @override
  String reportCardRow(String term) {
    return 'Report card for $term';
  }

  @override
  String get reportCardHint => 'PDF · share or save';

  @override
  String get reportCardPreparing => 'Preparing the report card…';

  @override
  String get reportCardOffline =>
      'No connection, so the report card can\'t be downloaded. Try again when you\'re online.';

  @override
  String get reportCardDenied => 'No access to this report card';

  @override
  String get reportCardFailed => 'Couldn\'t get the report card. Please try again.';

  @override
  String get feedbackTitle => 'Teacher feedback';

  @override
  String get feedbackPraise => 'Praise';

  @override
  String get feedbackRemark => 'Remark';

  @override
  String get feedbackAction => 'Write feedback';

  @override
  String feedbackSheetTitle(String name) {
    return 'Feedback: $name';
  }

  @override
  String get feedbackHint => 'What went well or what to work on';

  @override
  String get feedbackSend => 'Send feedback';

  @override
  String feedbackSent(String name) {
    return 'Feedback for $name is on its way';
  }

  @override
  String get whatFeedback => 'Feedback to a student';

  @override
  String get hwAttachCamera => 'Camera';

  @override
  String get hwAttachPhoto => 'Photos';

  @override
  String get hwAttachFile => 'File';

  @override
  String hwRemoveFile(String name) {
    return 'Remove $name';
  }

  @override
  String hwFileTooBig(String name) {
    return '$name is over 10 MB, not attached';
  }

  @override
  String hwUploading(int done, int total) {
    return 'Uploading files ($done of $total)…';
  }

  @override
  String hwFilesFailed(int n) {
    return 'Homework assigned, but $n files didn\'t upload. Attach them later on the website.';
  }

  @override
  String get hwFilesOffline =>
      'No connection: the homework is saved without files and will be sent later. Attach files once you\'re online.';

  @override
  String get hwFilesError => 'Couldn\'t assign the homework. Please try again.';

  @override
  String get attachmentOpenFailed => 'Couldn\'t open the file';

  @override
  String get actApprove => 'Approve';

  @override
  String get excuseApprovedToast => 'Request approved';

  @override
  String get excuseApproveFailed => 'Could not approve the request';

  @override
  String get liveNow => 'Lesson in progress';

  @override
  String liveMarked(int done, int total) {
    return 'Marked $done/$total';
  }

  @override
  String get liveEnded => 'Lesson ended';

  @override
  String get liveEndedTopic => 'Lesson ended: topic missing';

  @override
  String get liveUntilBell => 'Until the bell';

  @override
  String get notifPublicTitle => 'GradeApp';

  @override
  String get notifPublicBody => 'New notification';

  @override
  String liveShortMinutes(int n) {
    return '$n min';
  }

  @override
  String get liveChannel => 'Lesson in progress';

  @override
  String get remChannel => 'Reminders';

  @override
  String remTitle(String cls) {
    return '$cls: attendance not marked';
  }

  @override
  String remBody(String subject, String start, String end) {
    return '$subject, $start–$end';
  }

  @override
  String get wgNext => 'Next lesson';

  @override
  String get wgNow => 'Now';

  @override
  String get wgDay => 'Day';

  @override
  String wgUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get wgStale => 'Open the app to refresh';

  @override
  String get wgNoMore => 'No more lessons today';

  @override
  String get wgNoLessons => 'No lessons today';

  @override
  String get wgHomeworkTomorrow => 'Homework for tomorrow';

  @override
  String get wgNoHomework => 'Nothing due tomorrow';

  @override
  String get wgSignedOut => 'Sign in to GradeApp';

  @override
  String get wgTomorrow => 'Tomorrow';

  @override
  String get wgStartsIn => 'Starts in';

  @override
  String get wgEndsIn => 'Ends in';

  @override
  String get setLocalTitle => 'On this phone';

  @override
  String get setReminders => 'Attendance reminders';

  @override
  String get setLive => 'Lesson on the lock screen';

  @override
  String get ntCheckInMissing => 'Has not checked in';

  @override
  String get wgNextShort => 'Next';

  @override
  String get s7Title => 'Forecast';

  @override
  String get s7Now => 'Now';

  @override
  String s7NowLine(String pct, String mark) {
    return '$pct% · mark $mark';
  }

  @override
  String s7NextWork(String title, String date) {
    return 'Next up: $title, $date';
  }

  @override
  String get s7MaxScore => 'Maximum points for the work';

  @override
  String get s7Less => 'Fewer points';

  @override
  String get s7More => 'More points';

  @override
  String s7Need(String mark, String kind, int need, int max) {
    return 'To reach $mark, you need at least $need of $max on the $kind';
  }

  @override
  String get s7NoStep => 'This work will not change the mark, but it still counts: just do your best.';

  @override
  String get s7Top => 'You have the top mark right now. Keep it up!';

  @override
  String s7IfIGet(String kind, int score, int max) {
    return 'If I get $score of $max on the $kind';
  }

  @override
  String s7Result(String mark, String pct) {
    return 'Quarter: $mark ($pct%)';
  }

  @override
  String get s7Disclaimer => 'This is an estimate by the school formula. The teacher sets the final mark.';

  @override
  String get s7Hidden => 'No forecast yet';

  @override
  String get s7HiddenFormula => 'The school formula has not loaded yet. Please try again later.';

  @override
  String s7HiddenFew(int count) {
    return 'At least $count graded works are needed for a fair forecast.';
  }

  @override
  String get s10Title => 'Streaks and milestones';

  @override
  String get s10Unavailable => 'Streaks are not turned on at your school.';

  @override
  String get s10ParentOff => 'Your parents turned streaks off. That is fine and does not affect school.';

  @override
  String get s10CardStart => 'On-time streak: start today';

  @override
  String s10CardCheckin(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days on time',
      one: '$count day on time',
    );
    return '$_temp0';
  }

  @override
  String s10CardHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Homework on time: $count days',
      one: 'Homework on time: $count day',
    );
    return '$_temp0';
  }

  @override
  String s10Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count days', one: '$count day');
    return '$_temp0';
  }

  @override
  String get s10DaysShort => 'days';

  @override
  String s10Best(int count) {
    return 'Best: $count';
  }

  @override
  String s10FreezesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count freezes left',
      one: '$count freeze left',
    );
    return '$_temp0';
  }

  @override
  String get s10KindCheckin => 'On time at school';

  @override
  String get s10KindHomework => 'Homework on time';

  @override
  String get s10TodayDoneCheckin => 'Done today';

  @override
  String get s10TodayDoneHomework => 'Everything for today is in on time';

  @override
  String get s10TodayPending => 'Still time today';

  @override
  String get s10TodayFrozen => 'Day frozen: the streak is kept';

  @override
  String get s10TodayExcused => 'Request approved: streak is paused';

  @override
  String get s10TodayOff => 'Not a school day today';

  @override
  String get s10TodayMissed => 'Today didn\'t count — you can use a freeze';

  @override
  String get s10ExcusedTitle => 'Request approved.';

  @override
  String get s10ExcusedBody => 'Your streak does not break or grow: it simply waits for you.';

  @override
  String get s10Milestones => 'Pages of the mark';

  @override
  String s10MilestoneReached(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: 'Reached: $days days');
    return '$_temp0';
  }

  @override
  String s10MilestoneAhead(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: 'Ahead: $days days');
    return '$_temp0';
  }

  @override
  String s10MilestoneToday(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days on time: another page opened');
    return '$_temp0';
  }

  @override
  String get s10Missed => 'Missed days';

  @override
  String get s10MissedHint => 'A freeze puts the day back into your streak. You can use it within a day.';

  @override
  String get s10Freeze => 'Freeze';

  @override
  String get s10Frozen => 'Day frozen';

  @override
  String get s10FreezeExpired => 'The time to freeze this day has passed';

  @override
  String get s10NoFreezes => 'No freezes left this quarter';

  @override
  String get s10SickNote => 'Sick? Stay home: an excuse request does not break your streak.';

  @override
  String get s10ParentSwitch => 'Streaks and milestones';

  @override
  String get s10ParentExplain =>
      'The app notes whether the student arrived on time and handed in homework on time. This is visible to the student and parents, not to other students or staff. A sick-leave request does not break the streak.';

  @override
  String get s11Title => 'Your week';

  @override
  String get s11DaysOnTime => 'days on time';

  @override
  String get s11Homework => 'homework done';

  @override
  String s11Milestone(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days on time: a new page');
    return '$_temp0';
  }

  @override
  String get s11WithMarks => 'Show marks in the picture';

  @override
  String get s11MarksWarning => 'Marks will be on the card. By sharing it, you make them visible to other people.';

  @override
  String get s11Save => 'Save as picture';

  @override
  String get p5Title => 'Attendance';

  @override
  String get p5RowHint => 'Calendar, absences and reasons';

  @override
  String p5Quarter(String name) {
    return 'Attendance · $name';
  }

  @override
  String p5CountAbsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count absences', one: '$count absence');
    return '$_temp0';
  }

  @override
  String p5CountTardy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count late arrivals',
      one: '$count late arrival',
    );
    return '$_temp0';
  }

  @override
  String p5CountExcused(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count excused', one: '$count excused');
    return '$_temp0';
  }

  @override
  String get p5NoMisses => 'No absences';

  @override
  String get p5PrevMonth => 'Previous month';

  @override
  String get p5NextMonth => 'Next month';

  @override
  String get p5Present => 'Present';

  @override
  String get p5Tardy => 'Late';

  @override
  String get p5Absent => 'Absent';

  @override
  String get p5Excused => 'Excused';

  @override
  String get p5NoLessons => 'No lessons';

  @override
  String get p5Absences => 'Absences this month';

  @override
  String get p5NoReason => 'no reason given';

  @override
  String get p6Title => 'Weekly summary';

  @override
  String get p6OpenSummary => 'Details';

  @override
  String get p6PrevWeek => 'Previous week';

  @override
  String get p6NextWeek => 'Next week';

  @override
  String p6WeekOf(String range) {
    return 'Week $range';
  }

  @override
  String get p6EmptyTitle => 'No school days';

  @override
  String get p6EmptyBody => 'No summary for this week: holidays or time off.';

  @override
  String get p6VerdictEmpty => 'There were no lessons this week.';

  @override
  String get p6VerdictGreat => 'A great week: on time every day, homework handed in.';

  @override
  String get p6VerdictSteady => 'A steady week.';

  @override
  String get p6VerdictAbsences => 'There is an unexplained absence: it can be explained.';

  @override
  String get p6VerdictOverdue => 'Some homework is still not handed in.';

  @override
  String p6VerdictDip(String course) {
    return 'A steady week, the mark in “$course” dipped.';
  }

  @override
  String get p6VerdictDipPlain => 'A steady week, one subject dipped.';

  @override
  String get p6Attendance => 'Attendance';

  @override
  String get p6DaysOnTime => 'Days on time';

  @override
  String p6OfDays(int ontime, int days) {
    return '$ontime of $days';
  }

  @override
  String get p6Tardy => 'Late arrivals';

  @override
  String get p6Absent => 'Unexplained absences';

  @override
  String get p6Excused => 'Excused';

  @override
  String get p6Grades => 'Marks by subject';

  @override
  String p6GradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count marks', one: '$count mark');
    return '$_temp0';
  }

  @override
  String p6Avg(String value) {
    return 'average $value';
  }

  @override
  String p6Up(String delta) {
    return 'up by $delta';
  }

  @override
  String p6Down(String delta) {
    return 'down by $delta';
  }

  @override
  String get p6Same => 'unchanged';

  @override
  String get p6Homework => 'Homework';

  @override
  String get p6HwDone => 'Handed in';

  @override
  String p6OfTotal(int done, int total) {
    return '$done of $total';
  }

  @override
  String get p6HwOverdue => 'Not handed in on time';

  @override
  String get p6Feedback => 'Teacher feedback';

  @override
  String get p6Praise => 'Praise';

  @override
  String get p6Remark => 'Remark';

  @override
  String get p6Upcoming => 'Coming up';

  @override
  String get p6TodayCard => 'Weekly summary';

  @override
  String get p6TodayCardHint => 'How the week went and what to talk about';

  @override
  String get p6DigestWhen => 'When to send the weekly summary';

  @override
  String get p6DayFri => 'Friday';

  @override
  String get p6DaySun => 'Sunday';

  @override
  String get p6DigestHour => 'Time';

  @override
  String get ngDigest => 'Weekly summary';

  @override
  String get ntDigest => 'Weekly summary';

  @override
  String get ntConsentRequested => 'Request from your child';

  @override
  String get p7Ask => 'Ask a parent';

  @override
  String get p7Sent => 'We sent the request to your parent.';

  @override
  String get p7TooSoon => 'You have already asked. Try again tomorrow.';

  @override
  String get p7AlreadyGranted => 'Your parent has already allowed it. Refresh the screen.';

  @override
  String get p8Title => 'Invoices and payment';

  @override
  String get p8ToPay => 'To pay';

  @override
  String get p8History => 'History';

  @override
  String get p8Empty => 'No invoices yet';

  @override
  String get p8EmptyHint => 'Tuition invoices will appear here.';

  @override
  String p8InvoiceNo(String number) {
    return 'Invoice no. $number';
  }

  @override
  String p8DueDate(String date) {
    return 'due $date';
  }

  @override
  String p8PaidSoFar(String amount) {
    return 'paid $amount ₸';
  }

  @override
  String p8PayableSemantic(String amount, String due) {
    return 'To pay $amount tenge, $due';
  }

  @override
  String get p8StatusSent => 'To pay';

  @override
  String get p8StatusPartial => 'Partly paid';

  @override
  String get p8StatusPaid => 'Paid';

  @override
  String get p8StatusOverdue => 'Overdue';

  @override
  String get p8StatusCancelled => 'Cancelled';

  @override
  String get p8Pay => 'Pay';

  @override
  String get p8PayFailed => 'Could not open the payment. Please try again.';

  @override
  String get p8PayUnavailable => 'Online payment is not available at this school.';

  @override
  String get p8ConfirmTitle => 'Before you pay';

  @override
  String p8Confirm(String name, String bin, String amount) {
    return 'You are paying for tuition directly to the school “$name”, BIN $bin. Amount: $amount ₸. GradeApp does not receive or transfer money. The fiscal receipt is issued by the school or the payment service.';
  }

  @override
  String p8ConfirmNoBin(String name, String amount) {
    return 'You are paying for tuition directly to the school “$name”. Amount: $amount ₸. GradeApp does not receive or transfer money. The fiscal receipt is issued by the school or the payment service.';
  }

  @override
  String get p8ConfirmGo => 'Go to payment';

  @override
  String get p8Checking => 'Checking the payment';

  @override
  String get p8CheckingHint => 'This usually takes less than a minute.';

  @override
  String get p8Arrived => 'Payment received. Thank you!';

  @override
  String get p8Delayed => 'The payment is not visible yet.';

  @override
  String get p8DelayedHint =>
      'The bank sometimes confirms later. If the money was already charged, do not pay again: the status will update by itself.';

  @override
  String get p8CheckNow => 'Check';

  @override
  String get p8OnlineOff => 'No online payment.';

  @override
  String get p8OnlineOffHint => 'Pay by bank transfer using the details below.';

  @override
  String get p8Payments => 'Payments';

  @override
  String get p8MethodCash => 'Cash';

  @override
  String get p8MethodTransfer => 'Transfer';

  @override
  String get p8HowToPay => 'How to pay by transfer';

  @override
  String get p8ReqRecipient => 'Recipient';

  @override
  String get p8ReqBin => 'BIN';

  @override
  String get p8ReqBank => 'Bank';

  @override
  String get p8ReqBik => 'BIC';

  @override
  String get p8ReqKbe => 'KBe';

  @override
  String get p8ReqKnp => 'KNP';

  @override
  String get p8ReqPurpose => 'Payment purpose';

  @override
  String p8PurposeValue(String number) {
    return 'Tuition payment, invoice no. $number';
  }

  @override
  String get p8Copy => 'Copy';

  @override
  String get p8Copied => 'Copied';

  @override
  String get p8Document => 'Document';

  @override
  String get p8PdfTitle => 'Invoice for payment';

  @override
  String get p8PdfCaption => 'Informational document, not a fiscal receipt';

  @override
  String get p8PdfFailed => 'Could not get the document.';

  @override
  String get p9Title => 'Teachers';

  @override
  String get p9Homeroom => 'Homeroom teacher';

  @override
  String get p9Write => 'Write';

  @override
  String p9WriteTo(String name) {
    return 'Write to $name';
  }

  @override
  String p9AllTeachers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All teachers ($count)',
      one: 'All teachers ($count)',
    );
    return '$_temp0';
  }

  @override
  String get p9Empty => 'No teachers listed yet';

  @override
  String get p10Pinned => 'Announcement';

  @override
  String p10PinnedMany(String title, int more) {
    return '$title and $more more';
  }

  @override
  String get p10Expand => 'Expand';

  @override
  String get p10Collapse => 'Collapse';

  @override
  String get p10AllEvents => 'All events';

  @override
  String get p10Events => 'School events';

  @override
  String get p10EventsEmpty => 'No upcoming events';

  @override
  String get p10EventsEmptyHint => 'Events for the coming weeks will appear here.';

  @override
  String get t6Praise => 'Praise';

  @override
  String get t6Remark => 'Remark';

  @override
  String t6PraiseTitle(String name) {
    return 'Praise: $name';
  }

  @override
  String t6RemarkTitle(String name) {
    return 'Remark: $name';
  }

  @override
  String get t6TextHint => 'A few words if needed (optional)';

  @override
  String get t6TagActive => 'Was active';

  @override
  String get t6TagHelped => 'Helped others';

  @override
  String get t6TagProgress => 'Clear progress';

  @override
  String get t6TagGreatAnswer => 'Great answer';

  @override
  String get t6TagLate => 'Was late';

  @override
  String get t6TagNoHomework => 'No homework';

  @override
  String get t6TagDistracted => 'Was distracted';

  @override
  String get t6TagNoMaterials => 'No materials';

  @override
  String get t9Substitution => 'Substitute';

  @override
  String t9ForTeacher(String name) {
    return 'for $name';
  }

  @override
  String t9TaughtBy(String name) {
    return 'taught by $name';
  }

  @override
  String get t12Title => 'Homework progress';

  @override
  String t12Done(int done, int total) {
    return '$done of $total did it';
  }

  @override
  String get t12AllDone => 'Everyone did it';

  @override
  String t12NotDone(int count) {
    return 'Not done: $count';
  }

  @override
  String get t12Remind => 'Remind';

  @override
  String t12Reminded(int count) {
    return '$count got the reminder';
  }

  @override
  String get t12TooSoon => 'Once an hour only';

  @override
  String get t12RemindFailed => 'Could not send the reminder';

  @override
  String get t12Loading => 'Counting who did it…';

  @override
  String get t12Open => 'Who did it';

  @override
  String get t8Tab => 'My class';

  @override
  String t8Came(int came, int total) {
    return '$came of $total came';
  }

  @override
  String t8Unmarked(int count) {
    return 'Not marked: $count';
  }

  @override
  String get t8AllMarked => 'Everyone is marked';

  @override
  String t8NextLesson(String subject, String time) {
    return 'Next: $subject at $time';
  }

  @override
  String get t8RollCall => 'Morning roll call';

  @override
  String get t8MarkClass => 'Mark the class for the day';

  @override
  String get t8AllCame => 'Everyone came';

  @override
  String get t8MarkSent => 'Class marks are being sent';

  @override
  String get t8SourceExcuse => 'By request';

  @override
  String get t8SourcePending => 'Request waiting';

  @override
  String get t8Requests => 'Absence requests';

  @override
  String get t8Approve => 'Approve';

  @override
  String get t8Reject => 'Reject';

  @override
  String get t8RejectTitle => 'Why reject?';

  @override
  String get t8RejectHint => 'The parent will see this note';

  @override
  String get t8RejectSend => 'Reject the request';

  @override
  String get t8Approved => 'Request approved';

  @override
  String get t8Rejected => 'Request rejected';

  @override
  String get t8ReviewFailed => 'Could not send the decision';

  @override
  String get t8Photo => 'Photo of the request';

  @override
  String t8From(String name) {
    return 'From $name';
  }

  @override
  String get t8Week => 'The class this week';

  @override
  String t8WeekRate(String rate) {
    return 'Attendance $rate%';
  }

  @override
  String t8WeekAbsent(int count) {
    return 'Absences: $count';
  }

  @override
  String t8WeekTardy(int count) {
    return 'Late: $count';
  }

  @override
  String get t8AtRisk => 'At risk';

  @override
  String get t8AtRiskNone => 'Nobody is at risk';

  @override
  String get t8OpenWeb => 'Open on the web';

  @override
  String get t8Empty => 'No students in the class';

  @override
  String get t8NotHomeroom => 'This section is for homeroom teachers';

  @override
  String get t8InboxSub => 'Approve them in «My class»';

  @override
  String t8WhatDay(int count) {
    return 'Class marks for the day: $count';
  }

  @override
  String t8ClassPick(String name) {
    return 'Class $name';
  }

  @override
  String wgChildIn(String time) {
    return 'At school since $time';
  }

  @override
  String get wgChildInNoTime => 'At school';

  @override
  String get wgChildNotYet => 'Not checked in yet';

  @override
  String wgChildNewGrades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new grades',
      one: '$count new grade',
    );
    return '$_temp0';
  }

  @override
  String get wgChildNoNew => 'No new grades';

  @override
  String get wgChildAbsent => 'Not at school';
}
