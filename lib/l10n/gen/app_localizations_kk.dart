// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'GradeApp';

  @override
  String get tabToday => 'Бүгін';

  @override
  String get tabWeek => 'Апта';

  @override
  String get tabGrades => 'Бағалар';

  @override
  String get tabTasks => 'Тапсырмалар';

  @override
  String get tabFamily => 'Отбасы';

  @override
  String get tabInbox => 'Кіріс';

  @override
  String tabWithBadge(String tab, int count) {
    return '$tab, жаңасы: $count';
  }

  @override
  String get back => 'Артқа';

  @override
  String get close => 'Жабу';

  @override
  String get cancel => 'Бас тарту';

  @override
  String get done => 'Дайын';

  @override
  String get retry => 'Қайталау';

  @override
  String get undo => 'Болдырмау';

  @override
  String get save => 'Сақтау';

  @override
  String get delete => 'Жою';

  @override
  String get skip => 'Өткізу';

  @override
  String get notNow => 'Қазір емес';

  @override
  String get continueAction => 'Жалғастыру';

  @override
  String get change => 'Өзгерту';

  @override
  String get add => 'Қосу';

  @override
  String get openSettings => 'Баптауларды ашу';

  @override
  String get send => 'Жіберу';

  @override
  String get errorTitle => 'Жүктеу мүмкін болмады';

  @override
  String get errorOffline => 'Желі жоқ. Интернетті тексеріп, қайталаңыз';

  @override
  String get errorGeneric => 'Бір қате кетті. Қайта көріңіз';

  @override
  String offlineBar(String time) {
    return 'Желі жоқ. $time кезіндегі деректер көрсетілген';
  }

  @override
  String get offlineBarNoTime => 'Желі жоқ. Сақталған деректер көрсетілген';

  @override
  String updatedAt(String time) {
    return '$time жаңартылды';
  }

  @override
  String minutesShort(int m) {
    return '$m мин';
  }

  @override
  String approxMinutes(int m) {
    return '≈ $m мин';
  }

  @override
  String inMinutes(int m) {
    return '$m минуттан кейін';
  }

  @override
  String room(String room) {
    return '$room каб.';
  }

  @override
  String nOfM(int n, int m) {
    return '$n / $m';
  }

  @override
  String get yesterday => 'Кеше';

  @override
  String get tomorrow => 'Ертең';

  @override
  String get todayWord => 'Бүгін';

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count сабақ', zero: 'Сабақ жоқ');
    return '$_temp0';
  }

  @override
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count тапсырма');
    return '$_temp0';
  }

  @override
  String tasksUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'тапсырма');
    return '$_temp0';
  }

  @override
  String get roleTeacher => 'Мұғалім';

  @override
  String get roleParent => 'Ата-ана';

  @override
  String get roleStudent => 'Оқушы';

  @override
  String get notifications => 'Хабарландырулар';

  @override
  String notificationsUnread(int count) {
    return 'Хабарландырулар, оқылмағаны: $count';
  }

  @override
  String get profile => 'Профиль';

  @override
  String switchChild(String name) {
    return 'Баланы ауыстыру, қазір $name';
  }

  @override
  String get profileSchools => 'Мектептер';

  @override
  String get profileChildren => 'Балалар';

  @override
  String get settingsNotifications => 'Хабарландырулар';

  @override
  String get settingsLanguage => 'Тіл';

  @override
  String get settingsTheme => 'Көрініс';

  @override
  String get themeSystem => 'Жүйедегідей';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Қараңғы';

  @override
  String get langSystem => 'Жүйедегідей';

  @override
  String get langKk => 'Қазақша';

  @override
  String get langRu => 'Русский';

  @override
  String get langEn => 'English';

  @override
  String get openWeb => 'Веб-нұсқасын ашу';

  @override
  String get about => 'Қосымша туралы';

  @override
  String version(String v) {
    return 'Нұсқа $v';
  }

  @override
  String get signOut => 'Шығу';

  @override
  String get signOutConfirm => 'Аккаунттан шығасыз ба?';

  @override
  String signOutPending(int count) {
    return '$count жазба жіберілмеген. Шықсаңыз, олар жоғалады';
  }

  @override
  String get signOutSendFirst => 'Жіберіп, шығу';

  @override
  String get signOutAnyway => 'Жібермей шығу';

  @override
  String get signOutWaitNet => 'Желі жоқ — жазбалар әлі жіберілмеді';

  @override
  String get photoConsent => 'Селфимен белгілеу';

  @override
  String get consentOn => 'рұқсат етілген';

  @override
  String get consentOff => 'рұқсат етілмеген';

  @override
  String get consentRevoke => 'Селфимен белгілеуге тыйым салу керек пе?';

  @override
  String get consentRevokeBody => 'Бала «Мен мектептемін» белгісін фотомен қоя алмайды';

  @override
  String get consentRevokeAction => 'Тыйым салу';

  @override
  String get switchSchoolFailed => 'Мектепті ауыстыру мүмкін болмады';

  @override
  String get noChildrenTitle => 'Балалар байланыстырылмаған';

  @override
  String get noChildrenMessage => 'Баланы аккаунтыңызға байланыстыруды мектептен сұраңыз';

  @override
  String get allFamily => 'Бүкіл отбасы';

  @override
  String className(String name) {
    return '$name сынып';
  }

  @override
  String get loginTagline => 'Мектеп кестесі, бағалар мен журнал — бір қосымшада';

  @override
  String get loginHow => 'Қалай кіресіз?';

  @override
  String get loginWithPassword => 'Логин мен құпиясөз';

  @override
  String get loginWithPasswordHint => 'Мектеп берген пошта не логин';

  @override
  String get loginWithCode => 'Мектеп берген код';

  @override
  String get loginWithCodeHint => 'ABCDE-12345 түріндегі коды бар парақ';

  @override
  String get loginTitle => 'Кіру';

  @override
  String get loginField => 'Пошта немесе логин';

  @override
  String get password => 'Құпиясөз';

  @override
  String get showPassword => 'Құпиясөзді көрсету';

  @override
  String get hidePassword => 'Құпиясөзді жасыру';

  @override
  String get forgotPassword => 'Құпиясөзді ұмыттыңыз ба?';

  @override
  String get signIn => 'Кіру';

  @override
  String get loginInvalid => 'Логин немесе құпиясөз қате';

  @override
  String get loginBlocked => 'Аккаунт бұғатталған — мектепке хабарласыңыз';

  @override
  String get loginThrottled => 'Тым көп әрекет. Бір минут күтіңіз';

  @override
  String get loginNoRole => 'Қосымшада әзірге оқушы, ата-ана және мұғалім кабинеттері ғана бар';

  @override
  String get otpTitle => 'Растау коды';

  @override
  String get otpHint => 'Аутентификатор қосымшасындағы 6 цифрды енгізіңіз';

  @override
  String get otpInvalid => 'Код қате';

  @override
  String get resetTitle => 'Құпиясөзді қалпына келтіру';

  @override
  String get resetHint => 'Жаңа құпиясөз орнату үшін поштаға сілтеме жібереміз';

  @override
  String get resetEmail => 'Пошта';

  @override
  String get resetSend => 'Сілтемені жіберу';

  @override
  String get resetSentTitle => 'Поштаңызды тексеріңіз';

  @override
  String resetSentBody(String email) {
    return 'Егер $email мекенжайы GradeApp-та тіркелген болса, оған сілтемесі бар хат келеді';
  }

  @override
  String get resetOtherEmail => 'Басқа мекенжай енгізу';

  @override
  String get codeTitle => 'Мектеп берген код';

  @override
  String get codeHint => 'Код мектеп берген парақта басылған';

  @override
  String get codeInvalid => 'Код табылмады немесе бұрын қолданылған';

  @override
  String get codeIncomplete => 'Кодта 10 таңба бар';

  @override
  String get codePasswordTitle => 'Құпиясөз ойлап табыңыз';

  @override
  String get codePasswordHint => 'Онымен қосымшаға және сайтқа кіресіз';

  @override
  String get codePwLength => 'Кемінде 8 таңба';

  @override
  String get codePwMixed => 'Әріптер мен цифрлар бар';

  @override
  String get codePwMatch => 'Құпиясөздер сәйкес';

  @override
  String get codePwRepeat => 'Құпиясөзді қайталаңыз';

  @override
  String get codeLoginTitle => 'Сіздің логиніңіз';

  @override
  String get codeLoginHint => 'Онымен веб-нұсқаға да кіруге болады';

  @override
  String get copy => 'Көшіру';

  @override
  String get copied => 'Көшірілді';

  @override
  String stepOf(int step, int total) {
    return '$step/$total қадам';
  }

  @override
  String get heroNow => 'Қазір';

  @override
  String get heroNext => 'Келесі';

  @override
  String heroLessonN(int n) {
    return '$n-сабақ';
  }

  @override
  String get heroLast => 'соңғы';

  @override
  String get heroPause => 'Үзіліс';

  @override
  String get heroPauseNext => 'келесі сабақ';

  @override
  String get heroUntilBell => 'қоңырауға дейін';

  @override
  String get heroUntilStart => 'басталуына дейін';

  @override
  String get heroUntilLesson => 'сабаққа дейін';

  @override
  String get heroMin => 'мин';

  @override
  String get heroDayOver => 'Күн аяқталды';

  @override
  String get heroForTomorrow => 'Ертеңге';

  @override
  String get heroOpenTasks => 'Тапсырмаларды ашу';

  @override
  String get heroNoLessons => 'Бүгін сабақ жоқ';

  @override
  String get heroRest => 'Демалуға болады';

  @override
  String get heroCancelled => 'болмайды';

  @override
  String get heroThen => 'Содан кейін';

  @override
  String heroInstead(String who, String whom) {
    return '$whom орнына $who';
  }

  @override
  String heroSemantic(String state, String subject, String details, String countdown) {
    return '$state $subject, $details. $countdown';
  }

  @override
  String heroCountdown(String label, int m) {
    return '$label: $m мин';
  }

  @override
  String heroNextLine(String time, String subject) {
    return 'Келесі $time $subject';
  }

  @override
  String heroTomorrowPlan(int count, String time) {
    return 'Ертең $time бастап $count сабақ';
  }

  @override
  String heroTasksDone(int done, int total) {
    return 'Үй тапсырмасы: $total ішінен $done дайын';
  }

  @override
  String get tileTomorrow => 'Ертеңге';

  @override
  String get tileNewGrades => 'Жаңа бағалар';

  @override
  String get tileOverdue => 'Мерзімі өтті';

  @override
  String get dayPlan => 'Күн жоспары';

  @override
  String lessonsPassed(int count) {
    return '$count сабақ өтті';
  }

  @override
  String get pillNow => 'қазір';

  @override
  String get pillSubstitution => 'алмастыру';

  @override
  String get pillCancelled => 'болмайды';

  @override
  String get pillJoint => 'біріктірілген';

  @override
  String breakLine(int m) {
    return 'үзіліс $m мин';
  }

  @override
  String get checkInTitle => 'Мен мектептемін';

  @override
  String checkInBy(String time) {
    return 'Белгілеу $time дейін';
  }

  @override
  String get checkInSubtitle => 'Кіреберісте селфи — 5 секунд';

  @override
  String checkInOpensAt(String time) {
    return 'Белгілеу $time ашылады';
  }

  @override
  String checkInDoneAt(String time) {
    return '$time бастап мектептесің';
  }

  @override
  String get checkInOnTime => 'Уақытында белгі қойдың';

  @override
  String checkInLateAt(String time) {
    return '$time белгіленді · кешігу';
  }

  @override
  String checkInClosed(String time) {
    return 'Белгілеу терезесі $time жабылды';
  }

  @override
  String get checkInClosedHint => 'Мектепте болсаң, сынып жетекшісіне айт';

  @override
  String get checkInNoConsent => 'Фотоға ата-ананың рұқсаты керек';

  @override
  String get checkInAskParent => 'Ата-анадан қалай сұрауға болады';

  @override
  String get checkInAskParentHint =>
      'Ата-анаң мұны өз GradeApp қосымшасында рұқсат етеді: «Бүгін» → «Рұқсат беру». Бір минут қана';

  @override
  String get checkInSending => 'Фото жіберілуде…';

  @override
  String checkInSendingPct(int pct) {
    return 'Жіберілуде… $pct %';
  }

  @override
  String checkInOutside(int meters) {
    return 'Мектептен $meters м қашықтықтасың. Кіреберіске жақындап, қайтала';
  }

  @override
  String get checkInNeedLocation => 'Геолокацияны қос';

  @override
  String get checkInStale => 'Жаңа сурет түсір';

  @override
  String get checkInOffline => 'Желі жоқ. Терезе ашық тұрғанда, жаңа суретсіз қайталаймыз';

  @override
  String get checkInAlready => 'Бүгін белгі қойып қойдың';

  @override
  String get checkInWindowClosed => 'Белгілеу терезесі жабық';

  @override
  String get checkInFailed => 'Фотоны жіберу мүмкін болмады';

  @override
  String get checkInOpenCamera => 'Камераны ашу';

  @override
  String get camLocating => 'Орналасқан жер ізделуде…';

  @override
  String camAtSchool(String time) {
    return 'Мектеп жанындасың · терезе $time дейін';
  }

  @override
  String camWindowUntil(String time) {
    return 'Терезе $time дейін';
  }

  @override
  String get camFar => 'Мектептен алыс';

  @override
  String get camHint => 'Бетің сопақ ішінде — түсір';

  @override
  String get camPrivacy => 'Фотоны тек мектеп қызметкерлері көреді. Ол 30 күннен кейін өшеді';

  @override
  String get camShutter => 'Суретке түсіру';

  @override
  String get camFlashOn => 'Экран жарқылын қосу';

  @override
  String get camFlashOff => 'Экран жарқылын өшіру';

  @override
  String get camRetake => 'Қайта түсіру';

  @override
  String get camUnavailable => 'Камера қолжетімсіз';

  @override
  String get camDenied => 'Телефон баптауларында GradeApp үшін «Камера» рұқсатын қос';

  @override
  String get camExplainTitle => 'Селфимен белгілеу';

  @override
  String get camExplainWhy => 'Кіреберістегі селфи мектепте екеніңді растайды';

  @override
  String get camExplainWho => 'Фотоны тек мектеп қызметкерлері көреді';

  @override
  String get camExplainKeep => 'Фото 30 күннен кейін өшеді';

  @override
  String get doneTitle => 'Белгіленді';

  @override
  String doneOnTime(String time) {
    return '$time · уақытында';
  }

  @override
  String doneLate(String time) {
    return '$time · кешігу';
  }

  @override
  String doneLateMin(String time, int m) {
    return '$time · $m мин кешігу';
  }

  @override
  String doneFirstLesson(String time) {
    return 'Бірінші сабақ · $time';
  }

  @override
  String get doneParents => 'Ата-анаң белгіні қосымшадан көреді';

  @override
  String weekEyebrow(String range, String term) {
    return '$range · $term';
  }

  @override
  String get weekGoToday => 'Бүгін';

  @override
  String weekDaySpan(String lessons, String from, String to) {
    return '$lessons · $from–$to';
  }

  @override
  String get weekNoLessons => 'Сабақ жоқ';

  @override
  String get weekNoLessonsHint => 'Бұл күні сабақ жоқ';

  @override
  String get weekPrev => 'Алдыңғы апта';

  @override
  String get weekNext => 'Келесі апта';

  @override
  String get hwShort => 'ҮТ';

  @override
  String get dotChanges => 'өзгерістер бар';

  @override
  String get dotHomework => 'үй тапсырмасы бар';

  @override
  String get dotExam => 'БЖБ не ТЖБ';

  @override
  String lessonOrdinal(String weekday, int n) {
    return '$weekday · $n-сабақ';
  }

  @override
  String get teacher => 'Мұғалім';

  @override
  String get topicLabel => 'Тақырып';

  @override
  String get lessonHomework => 'Сабаққа тапсырма';

  @override
  String get myMarks => 'Менің белгілерім';

  @override
  String get childMarks => 'Белгілер';

  @override
  String get notFilledYet => 'Мұғалім әлі толтырмады';

  @override
  String get explainAbsence => 'Себебін түсіндіру';

  @override
  String get openLesson => 'Сабақты ашу';

  @override
  String get presencePresent => 'сабақта болды';

  @override
  String get presenceAbsent => 'келмеді';

  @override
  String get presenceTardy => 'кешікті';

  @override
  String get presenceExcused => 'дәлелді себеп';

  @override
  String gradesEyebrow(String term, int week) {
    return '$term · $week-апта';
  }

  @override
  String termShort(int n) {
    return '$n тоқс.';
  }

  @override
  String get termRunning => 'жүріп жатыр';

  @override
  String termPick(String term) {
    return '$term таңдау';
  }

  @override
  String get segSubjects => 'Пәндер';

  @override
  String get segFeed => 'Таспа';

  @override
  String subjectsCount(int count) {
    return '$count пән';
  }

  @override
  String get sortAttention => 'Алдымен назарды қажет ететіндер';

  @override
  String get sortAlpha => 'Әліпби бойынша';

  @override
  String get prelim => 'алдын ала';

  @override
  String get gradesEmpty => 'Бұл тоқсанда әлі баға жоқ';

  @override
  String get gradesEmptyHint => 'Алғашқысы сабақтан кейін шығады';

  @override
  String insightStrong(String subject) {
    return 'Ең жақсысы — $subject.';
  }

  @override
  String insightWeak(String subject, int pct) {
    return '$subject назар аударуды қажет етеді: $pct %.';
  }

  @override
  String quarterResults(String term) {
    return 'Қорытынды: $term';
  }

  @override
  String get howCalculated => 'Тоқсандық баға қалай шығады';

  @override
  String get howCalcBody => 'Мектеп пен табель де осылай есептейді';

  @override
  String get howCalcMissing => 'Бір бөлігі әлі жоқ болса, оның салмағы қалғандарына бөлінеді';

  @override
  String get pctToMark => '% → баға';

  @override
  String pctFrom(int pct) {
    return '$pct % бастап';
  }

  @override
  String get formulaMissing => 'Мектеп формуласы жүктелмеді, сондықтан тоқсандық баға жасырылды';

  @override
  String subjectPrelim(String term) {
    return '$term · алдын ала';
  }

  @override
  String subjectFinal(String term) {
    return '$term · қорытынды';
  }

  @override
  String worksCount(int count) {
    return '$count жұмыс';
  }

  @override
  String toNextMark(String mark, int pct) {
    return '«$mark» үшін $pct % жетпейді';
  }

  @override
  String get works => 'Жұмыстар';

  @override
  String get newestFirst => 'жаңалары жоғарыда';

  @override
  String get kindFo => 'ҚБ';

  @override
  String get kindSor => 'БЖБ';

  @override
  String get kindSoch => 'ТЖБ';

  @override
  String gradeSemantic(String value, String tone) {
    return 'Баға $value, $tone';
  }

  @override
  String get toneExcellent => 'өте жақсы';

  @override
  String get toneGood => 'жақсы';

  @override
  String get toneFair => 'қанағаттанарлық';

  @override
  String get tonePoor => 'қанағаттанарлықсыз';

  @override
  String get newWord => 'жаңа';

  @override
  String tasksEyebrow(int count) {
    return 'Осы аптада: $count тапсырма';
  }

  @override
  String get sectionOverdue => 'Мерзімі өтті';

  @override
  String get sectionToday => 'Бүгін';

  @override
  String get sectionTomorrow => 'Ертең';

  @override
  String get sectionWeek => 'Осы аптада';

  @override
  String get sectionLater => 'Кейінірек';

  @override
  String sectionDone(int count) {
    return 'Орындалды: $count';
  }

  @override
  String get allSubjects => 'Барлығы';

  @override
  String get markDone => 'Дайын деп белгілеу';

  @override
  String get markUndone => 'Орындалмағандарға қайтару';

  @override
  String get doneToast => 'Тапсырма дайын деп белгіленді';

  @override
  String get undoneToast => 'Тапсырма тізімге қайтты';

  @override
  String get hwDone => 'орындалды';

  @override
  String get hwNotDone => 'орындалмады';

  @override
  String dueBy(String date) {
    return '$date дейін';
  }

  @override
  String attachmentsCount(int count) {
    return '$count файл';
  }

  @override
  String get tasksEmpty => 'Тапсырма жоқ';

  @override
  String get tasksEmptyHint => 'Мұғалімдердің жаңа тапсырмалары осында шығады';

  @override
  String taskToggleDone(String title) {
    return '«$title» дайын деп белгілеу';
  }

  @override
  String taskToggleUndone(String title) {
    return '«$title» қайтару';
  }

  @override
  String get openFile => 'Файлды ашу';

  @override
  String loadToday(int used, int norm) {
    return 'Жүктеме: $norm минуттың $used';
  }

  @override
  String get verdictOk => 'Бәрі жақсы';

  @override
  String get verdictQuestion => 'Сұрақ бар';

  @override
  String get verdictAction => 'Әрекет керек';

  @override
  String get verdictAlarm => 'Мектепте белгі қоймады';

  @override
  String get verdictNoLessons => 'Бүгін сабақ жоқ';

  @override
  String verdictUpdated(String time) {
    return '$time кезіндегі деректер';
  }

  @override
  String factArrived(String time) {
    return '$time бастап мектепте.';
  }

  @override
  String factLessons(int done, int total) {
    return '$total сабақтың $done өтті.';
  }

  @override
  String factBeforeLessons(String time) {
    return 'Бірінші сабақ $time.';
  }

  @override
  String factAbsent(String subject) {
    return 'Сабаққа келмеді: $subject';
  }

  @override
  String get factNoReason => 'себебі көрсетілмеген.';

  @override
  String factLate(String time) {
    return 'Кешігу: $time белгіленді.';
  }

  @override
  String factLowGrade(String subject, String value) {
    return 'Төмен баға: $subject $value.';
  }

  @override
  String get factExcused => 'Бүгінге рұқсат алынған.';

  @override
  String factAlarm(String time) {
    return 'Бірінші сабақ $time басталды. Белгі де, өтініш те жоқ.';
  }

  @override
  String get factNoConsent => 'Селфимен белгілеу сіздің рұқсатыңызды күтуде.';

  @override
  String factTomorrow(String lessons, String time) {
    return 'Ертең $time бастап $lessons.';
  }

  @override
  String factNewGrade(String subject) {
    return 'жаңа баға · $subject';
  }

  @override
  String get actExcuse => 'Сұрап алу';

  @override
  String get actExplain => 'Себебін түсіндіру';

  @override
  String get actAllow => 'Рұқсат беру';

  @override
  String get attentionTitle => 'Назар аударыңыз';

  @override
  String attAbsent(String time) {
    return 'Келмеді · $time';
  }

  @override
  String get attNoConsent => 'Селфимен белгілеу';

  @override
  String get attNoConsentSub => 'Сіздің рұқсатыңыз керек';

  @override
  String get attRejected => 'Өтініш қабылданбады';

  @override
  String get attPending => 'Өтініш сынып жетекшісінде қаралуда';

  @override
  String get feedTitle => 'Күн таспасы';

  @override
  String get feedNewest => 'жаңасы жоғарыда';

  @override
  String get feedArrived => 'Мектепке келді';

  @override
  String feedArrivedSub(String state) {
    return 'селфимен белгі · $state';
  }

  @override
  String get feedOnTime => 'уақытында';

  @override
  String get feedLate => 'кешігу';

  @override
  String get feedNow => 'қазір жүріп жатыр';

  @override
  String get feedMarkedAbsent => 'келмеді деп белгіленді';

  @override
  String get feedEmpty => 'Әзірге ештеңе болған жоқ';

  @override
  String forTomorrowLine(String tasks, int m, int done) {
    return '$tasks · ≈ $m мин · $done дайын';
  }

  @override
  String get familyTitle => 'Отбасы';

  @override
  String get familyNotChecked => 'белгі жоқ';

  @override
  String get familyAllGood => 'бәрі жақсы';

  @override
  String get familyQuestion => 'сұрақ бар';

  @override
  String get familyNoLessons => 'сабақ жоқ';

  @override
  String get familyExcuseCard => 'Баланы сұрап алу';

  @override
  String get familyExcuseHint => 'Ауру, отбасылық жағдай, дәрігер — өтініш сынып жетекшісіне жіберіледі';

  @override
  String get requests => 'Өтініштер';

  @override
  String get reqPending => 'қаралуда';

  @override
  String get reqApproved => 'мақұлданды';

  @override
  String get reqRejected => 'қабылданбады';

  @override
  String get reqCancelled => 'кері қайтарылды';

  @override
  String get reqWithdraw => 'Өтінішті кері қайтару';

  @override
  String get reqWithdrawConfirm => 'Өтінішті кері қайтарасыз ба?';

  @override
  String get reqEmpty => 'Әзірге өтініш жоқ';

  @override
  String get reqEmptyHint => 'Баланы сұрап алғанда, өтініш осында шығады';

  @override
  String get catIllness => 'Ауру';

  @override
  String get catFamily => 'Отбасылық';

  @override
  String get catAppointment => 'Дәрігер не шаруа';

  @override
  String get catOther => 'Басқа';

  @override
  String excuseTitle(String name) {
    return 'Сұрап алу: $name';
  }

  @override
  String get excuseWhen => 'Қашан';

  @override
  String get excuseDates => 'Күндер';

  @override
  String get excuseLessons => 'Сабақтар';

  @override
  String get excuseFrom => 'Бастап';

  @override
  String get excuseTo => 'Дейін';

  @override
  String get excuseReason => 'Себеп';

  @override
  String get excuseComment => 'Түсініктеме';

  @override
  String get excuseCommentHint => 'Міндетті емес';

  @override
  String get excuseProof => 'Анықтама';

  @override
  String get excuseCamera => 'Камера';

  @override
  String get excuseGallery => 'Галерея';

  @override
  String get excuseRemoveProof => 'Анықтаманы алып тастау';

  @override
  String get excuseSend => 'Сынып жетекшісіне жіберу';

  @override
  String get excuseSent => 'Өтініш жіберілді';

  @override
  String get excusePickLessons => 'Кемінде бір сабақты таңдаңыз';

  @override
  String get excuseOffline => 'Желі жоқ. Байланыс болғанда жіберіңіз';

  @override
  String get excuseFailed => 'Өтінішті жіберу мүмкін болмады';

  @override
  String get consentSheetTitle => 'Селфимен белгілеуге рұқсат бересіз бе?';

  @override
  String get consentWho => 'Фотоны тек мектеп қызметкерлері көреді';

  @override
  String get consentKeep => '30 күннен кейін өшеді';

  @override
  String get consentWhere => 'Бала профилінде кері қайтаруға болады';

  @override
  String consentAllowed(String name) {
    return '$name белгі қоя алады';
  }

  @override
  String get consentFailed => 'Рұқсатты сақтау мүмкін болмады';

  @override
  String tUntilBell(int m) {
    return 'қоңырауға $m мин';
  }

  @override
  String tStartsIn(int m) {
    return '$m минуттан кейін';
  }

  @override
  String tFree(int m) {
    return 'бос уақыт $m мин';
  }

  @override
  String tStudents(int count) {
    return '$count оқушы';
  }

  @override
  String get tRollNotDone => 'Түгендеу жасалмады';

  @override
  String get tRollDone => 'Түгендеу жасалды';

  @override
  String get tTopicDone => 'тақырып ✓';

  @override
  String get tCloseDay => 'Күнді жабу';

  @override
  String tActions(int count) {
    return '$count әрекет';
  }

  @override
  String get tDayClosed => 'Күн жабылды';

  @override
  String get tDayClosedHint => 'Барлық сабақ толтырылды';

  @override
  String get tNoLessons => 'Бүгін сабақ жоқ';

  @override
  String get tUnmarked => 'белгіленбеген';

  @override
  String get tNoTopic => 'тақырыпсыз';

  @override
  String get tLessons => 'Сабақтар';

  @override
  String tTodayCount(int count) {
    return 'бүгін $count';
  }

  @override
  String get missingAttendance => 'қатысу';

  @override
  String get missingTopic => 'тақырып';

  @override
  String get missingHomework => 'ҮТ';

  @override
  String get missingGrades => 'бағалар';

  @override
  String tMissingWhat(String what, String lesson) {
    return '$what: $lesson';
  }

  @override
  String get tDebts => 'Соңғы 14 күндегі қарыздар';

  @override
  String tDebtsUnmarked(int count) {
    return '$count сабақ белгісіз';
  }

  @override
  String get tCloseAll => 'Барлығын келмегендерсіз жабу';

  @override
  String get tCloseAllConfirm => 'Барлығын қатысты деп белгілейміз бе?';

  @override
  String get tCloseAllBody => 'Тек белгі әлі жоқ сабақтар. Кейін сабақта түзетуге болады';

  @override
  String tAllPresentToast(String cls) {
    return '$cls: барлығы орнында';
  }

  @override
  String get tAllPresent => 'Барлығы орнында';

  @override
  String tLessonRowSemantic(String time, String cls, String subject, String state) {
    return '$time, $cls, $subject. $state';
  }

  @override
  String get tAllFilled => 'бәрі толтырылды';

  @override
  String tJointClasses(String a, String b) {
    return '$a + $b';
  }

  @override
  String get lessonOver => 'сабақ аяқталды';

  @override
  String get topicCard => 'Сабақ тақырыбы';

  @override
  String ktpChip(String topic) {
    return 'КТЖ: $topic';
  }

  @override
  String get sameAsLast => 'Өткендегідей';

  @override
  String get topicHint => 'Мысалы: Үшбұрыштардың ұқсастығы';

  @override
  String get topicSaved => 'Тақырып сақталды';

  @override
  String get presentLabel => 'Қатысады';

  @override
  String get searchStudent => 'Оқушыны іздеу';

  @override
  String get viewList => 'Тізім';

  @override
  String get viewFaces => 'Беттер';

  @override
  String sourceCheckIn(String time) {
    return 'өзі белгіленді · $time';
  }

  @override
  String get sourceCheckInShort => 'өзі белгіленді';

  @override
  String get sourceHomeroom => 'сынып жетекшісінің белгісі';

  @override
  String lateBy(int m) {
    return '$m мин кешікті';
  }

  @override
  String notSaved(String reason) {
    return 'сақталмады: $reason';
  }

  @override
  String get reasonSochShort => 'ТЖБ күні';

  @override
  String get reasonSoch => 'ТЖБ күні — белгілер қабылданбайды';

  @override
  String get reasonForbiddenShort => 'сабаққа құқық жоқ';

  @override
  String get reasonForbidden => 'Бұл сабаққа құқық жоқ';

  @override
  String get reasonNotFound => 'Сабақ не оқушы жойылған';

  @override
  String get reasonInvalid => 'Сервер жазбаны қабылдамады';

  @override
  String sochBanner(String subject) {
    return 'Бүгін «$subject» пәні бойынша ТЖБ.';
  }

  @override
  String get sochBannerBody => 'Ағымдағы бағалар мен қатысу қойылмайды';

  @override
  String pendingBanner(int count) {
    return '$count белгі желіні күтуде.';
  }

  @override
  String get pendingBannerBody => 'Өзіміз жібереміз';

  @override
  String rejectedBanner(int count) {
    return '$count жазба сақталмады.';
  }

  @override
  String get openQueue => 'Ашу';

  @override
  String get dockHomework => 'ҮТ';

  @override
  String get dockSummary => 'Қорытынды';

  @override
  String dockAllPresent(int count) {
    return 'Барлығы орнында · $count';
  }

  @override
  String dockDone(int n, int m) {
    return 'Дайын · $n/$m';
  }

  @override
  String get dockFinish => 'Сабақты аяқтау';

  @override
  String get dockSochDay => 'ТЖБ күні';

  @override
  String get rollSaved => 'Түгендеу сақталды';

  @override
  String markedToast(String name, String state) {
    return '$name — $state';
  }

  @override
  String get stateAbsent => 'Н';

  @override
  String get statePresent => 'бар';

  @override
  String get rowPresentHint => 'Екі рет түрту — келмеді деп белгілеу';

  @override
  String get rowAbsentHint => 'Екі рет түрту — қатысты деп белгілеу';

  @override
  String get actionCodes => 'Қатысу кодтары';

  @override
  String codesTitle(String name) {
    return '$name';
  }

  @override
  String get codeLate => 'Кешікті';

  @override
  String get codeLateMinutes => 'Неше минутқа';

  @override
  String get codeCustom => 'Басқа';

  @override
  String get codeSick => 'Ауырып жүр';

  @override
  String get codeExcused => 'Дәлелді себеп';

  @override
  String get codePresent => 'Бар';

  @override
  String get codeAbsent => 'Жоқ';

  @override
  String get lessonStartedToast => 'Сабақ басталды';

  @override
  String padOf(int n, int total) {
    return '$n/$total';
  }

  @override
  String get padComment => 'Түсініктеме';

  @override
  String get padCommentHint => 'Келесі бағаға қосылады';

  @override
  String padAbsentWarn(String name) {
    return '$name «Н» деп белгіленген. Баға қоямыз ба?';
  }

  @override
  String get padPut => 'Қою';

  @override
  String get padRemoved => 'Баға алынды';

  @override
  String padKey(String v, String tone) {
    return '$v қою, $tone';
  }

  @override
  String padSelected(int count) {
    return 'Таңдалды: $count';
  }

  @override
  String get padPrev => 'Алдыңғы оқушы';

  @override
  String get padNext => 'Келесі оқушы';

  @override
  String gradeSlot(String name) {
    return 'Баға: $name';
  }

  @override
  String get gradeLocked => 'Бағалар жабық';

  @override
  String get scaleViewOnly => 'Бұл шкала веб-журналда қойылады';

  @override
  String get selectMode => 'Оқушыларды таңдау';

  @override
  String get workType => 'Жұмыс түрі';

  @override
  String get menuMore => 'Тағы';

  @override
  String get menuGradeAll => 'Барлығын бағалау';

  @override
  String get menuOpenWeb => 'Журналды вебте ашу';

  @override
  String get menuStart => 'Сабақты бастау';

  @override
  String jointPill(int count) {
    return 'біріктірілген · $count';
  }

  @override
  String classHeader(String cls, int count) {
    return '$cls · $count';
  }

  @override
  String get rosterEmpty => 'Сыныпта оқушы жоқ';

  @override
  String hwSheetTitle(String cls) {
    return '$cls үшін тапсырма';
  }

  @override
  String get hwTextHint => '12-параграф, 3–7 есептер';

  @override
  String get hwDue => 'Мерзімі';

  @override
  String hwDueNextLesson(String date) {
    return 'Келесі сабақ · $date';
  }

  @override
  String get hwTime => 'Орындау уақыты';

  @override
  String hwLoad(String day, int used, int norm) {
    return '$day: $norm минуттың $used бос емес';
  }

  @override
  String hwOverNorm(int m) {
    return 'нормадан $m мин артық';
  }

  @override
  String get hwAssign => 'Беру';

  @override
  String hwAssigned(String cls) {
    return 'ҮТ берілді · $cls';
  }

  @override
  String get hwExisting => 'Берілген';

  @override
  String get hwFailed => 'ҮТ беру мүмкін болмады';

  @override
  String get hwOffline => 'Желі жоқ — тапсырма байланыс болғанда жіберіледі';

  @override
  String get hwOtherDate => 'Басқа күн';

  @override
  String get sumTitle => 'Сабақ қорытындысы';

  @override
  String sumAttendance(int n, int m) {
    return 'Қатысу · $n/$m';
  }

  @override
  String get sumTopic => 'Тақырып';

  @override
  String get sumHomework => 'ҮТ';

  @override
  String sumGrades(int count) {
    return 'Бағалар · $count';
  }

  @override
  String get sumField => 'Сабақ қорытындысы, міндетті емес';

  @override
  String get lessonFinishedToast => 'Сабақ аяқталды';

  @override
  String get syncTitle => 'Синхрондау';

  @override
  String syncLast(String time) {
    return 'Соңғы жіберу $time';
  }

  @override
  String syncRejected(int count) {
    return 'Қабылданбады · $count';
  }

  @override
  String syncWaiting(int count) {
    return 'Желіні күтуде · $count';
  }

  @override
  String get syncAllSent => 'Бәрі жіберілді';

  @override
  String get syncAllSentHint => 'Белгілер, бағалар мен тақырыптар серверде';

  @override
  String get syncDeleteConfirm => 'Жазбаны жою керек пе?';

  @override
  String get syncDeleteBody => 'Ол жіберілмей жойылады';

  @override
  String get syncSending => 'Жіберілуде';

  @override
  String syncPendingN(int count) {
    return 'Жіберуді күтуде: $count';
  }

  @override
  String syncRejectedN(int count) {
    return 'Сақталмады: $count';
  }

  @override
  String whatAttendance(String state) {
    return 'Қатысу «$state»';
  }

  @override
  String whatGrade(String v) {
    return 'Баға $v';
  }

  @override
  String get whatGradeRemoved => 'Баға алынды';

  @override
  String get whatTopic => 'Сабақ тақырыбы';

  @override
  String get whatStart => 'Сабақтың басталуы';

  @override
  String get whatFinish => 'Сабақтың аяқталуы';

  @override
  String get whatHomework => 'Үй тапсырмасы';

  @override
  String whatAllPresent(int count) {
    return 'Барлығы орнында · $count';
  }

  @override
  String get whatSummary => 'Сабақ қорытындысы';

  @override
  String createdAt(String time) {
    return '$time жасалды';
  }

  @override
  String get inboxAction => 'Әрекет қажет';

  @override
  String get inboxSchedule => 'Кесте';

  @override
  String get inboxOther => 'Басқасы';

  @override
  String get inboxEmpty => 'Кіріс бос';

  @override
  String get inboxEmptyHint =>
      'Мұнда белгісіз сабақтар, қабылданбаған жазбалар, алмастырулар мен хабарландырулар шығады';

  @override
  String get inboxRejected => 'Жазбалар сақталмады';

  @override
  String get inboxRejectedSub => 'Қайталау не жою үшін кезекті ашыңыз';

  @override
  String inboxExcuses(int count) {
    return '$count келмеу туралы өтініш';
  }

  @override
  String get inboxExcusesSub => 'Мақұлдау не қабылдамау веб-нұсқада';

  @override
  String get markRead => 'Оқылды';

  @override
  String get markAllRead => 'Бәрін оқылды деу';

  @override
  String get notifEmpty => 'Хабарландыру жоқ';

  @override
  String get notifEmptyHint => 'Мұнда бағалар, тапсырмалар, алмастырулар және өтініштер бойынша шешімдер шығады';

  @override
  String get notifUnavailable => 'Жазба жойылған немесе қолжетімсіз';

  @override
  String get notifUnavailableHint => 'Мүмкін, мектепте өзгерткен. Қосымшаның қалғаны әдеттегідей жұмыс істейді';

  @override
  String get ntGradeCreated => 'Жаңа баға';

  @override
  String get ntGradeUpdated => 'Баға өзгертілді';

  @override
  String get ntHomework => 'Үй тапсырмасы';

  @override
  String get ntHomeworkReminder => 'Тапсырма туралы еске салу';

  @override
  String get ntLessonCancelled => 'Сабақ болмайды';

  @override
  String get ntLessonRescheduled => 'Сабақ ауыстырылды';

  @override
  String get ntSubstitution => 'Алмастыру';

  @override
  String get ntLessonStarted => 'Сабақ басталды';

  @override
  String get ntCheckIn => 'Бала мектепке келді';

  @override
  String get ntAttendance => 'Қатысу';

  @override
  String get ntUnmarked => 'Қатысуды белгілеңіз';

  @override
  String get ntGradesReminder => 'Бағаларды қойыңыз';

  @override
  String get ntExcusePending => 'Жаңа өтініш';

  @override
  String get ntExcuseApproved => 'Өтініш мақұлданды';

  @override
  String get ntExcuseRejected => 'Өтініш қабылданбады';

  @override
  String get ntExcuseCancelled => 'Өтініш кері қайтарылды';

  @override
  String get ntInvoice => 'Төлем шоты';

  @override
  String get ntEvent => 'Мектеп іс-шарасы';

  @override
  String get ntChat => 'Жаңа хабарлама';

  @override
  String get ntOther => 'Хабарлама';

  @override
  String get ngGrades => 'Бағалар';

  @override
  String get ngHomework => 'Тапсырмалар';

  @override
  String get ngSchedule => 'Кесте және алмастыру';

  @override
  String get ngAttendance => 'Қатысу және мектепке келу';

  @override
  String get ngChat => 'Хабарламалар';

  @override
  String get ngBilling => 'Төлем';

  @override
  String get ngGeneral => 'Маңызды';

  @override
  String get pushAskTitle => 'Хабарламаларды қосасыз ба?';

  @override
  String get pushAskAllow => 'Қосу';

  @override
  String get pushWhyStudent => 'Жаңа баға, тапсырма немесе сабақтың ауысқаны туралы бірден білесің.';

  @override
  String get pushWhyParent =>
      'Бала мектепке келгенін, баға алғанын немесе сабаққа келмегенін бірден біліп отырыңыз. Бағаның өзі құлыпталған экранда көрсетілмейді.';

  @override
  String get pushWhyTeacher =>
      'Белгіленбеген қатысуды еске саламыз, алмастырулар мен жаңа өтініштер туралы хабарлаймыз.';

  @override
  String get notifSettings => 'Хабарламалар';

  @override
  String get notifSettingsHint =>
      'Қосымшадағы қоңыраудан бәрі көрінеді. Мұнда телефонға пуш болып не келетінін таңдайсыз.';

  @override
  String get pushOffTitle => 'Хабарламалар телефон баптауларында өшірулі';

  @override
  String get pushOffOpen => 'Баптауларды ашу';

  @override
  String get pushTurnOn => 'Хабарламаларды қосу';

  @override
  String get pushUnavailable => 'Бұл нұсқада пуш-хабарламалар жоқ';

  @override
  String get notifOpen => 'Ашу';

  @override
  String get presenceOnline => 'Желіде';

  @override
  String get lockSetting => 'Қолданбаны құлыптау';

  @override
  String get lockSettingHint =>
      'Іске қосқанда және 5 минуттан артық фонда болғаннан кейін — Face ID, саусақ ізі немесе телефон коды';

  @override
  String get lockReason => 'Бұл өзіңіз екеніңізді растаңыз';

  @override
  String get lockTitle => 'GradeApp құлыпталған';

  @override
  String get lockUnlock => 'Құлыпты ашу';

  @override
  String get lockUnavailable => 'Телефон баптауларында Face ID, саусақ ізін немесе құпиякодты қосыңыз';

  @override
  String reportCardRow(String term) {
    return '$term бойынша табель';
  }

  @override
  String get reportCardHint => 'PDF · жіберу немесе сақтау';

  @override
  String get reportCardPreparing => 'Табель дайындалуда…';

  @override
  String get reportCardOffline => 'Желі жоқ — табельді жүктеу мүмкін емес. Интернет пайда болғанда қайталап көріңіз.';

  @override
  String get reportCardDenied => 'Табельге рұқсат жоқ';

  @override
  String get reportCardFailed => 'Табельді алу мүмкін болмады. Қайтадан көріңіз.';

  @override
  String get feedbackTitle => 'Мұғалімдер пікірі';

  @override
  String get feedbackPraise => 'Мақтау';

  @override
  String get feedbackRemark => 'Ескерту';

  @override
  String get feedbackAction => 'Оқушыға пікір жазу';

  @override
  String feedbackSheetTitle(String name) {
    return 'Пікір: $name';
  }

  @override
  String get feedbackHint => 'Не жақсы шықты немесе неге көңіл бөлу керек';

  @override
  String get feedbackSend => 'Пікірді жіберу';

  @override
  String feedbackSent(String name) {
    return '$name үшін пікір жіберіліп жатыр';
  }

  @override
  String get whatFeedback => 'Оқушыға пікір';

  @override
  String get hwAttachCamera => 'Камера';

  @override
  String get hwAttachPhoto => 'Фото';

  @override
  String get hwAttachFile => 'Файл';

  @override
  String hwRemoveFile(String name) {
    return '$name алып тастау';
  }

  @override
  String hwFileTooBig(String name) {
    return '$name 10 МБ-тан үлкен — тіркелмеді';
  }

  @override
  String hwUploading(int done, int total) {
    return 'Файлдар жүктелуде ($done/$total)…';
  }

  @override
  String hwFilesFailed(int n) {
    return 'Тапсырма берілді, бірақ $n файл жүктелмеді. Оларды кейін сайт арқылы тіркеңіз.';
  }

  @override
  String get hwFilesOffline =>
      'Желі жоқ: тапсырма файлсыз сақталды, кейін жіберіледі. Файлдарды интернет пайда болғанда тіркеңіз.';

  @override
  String get hwFilesError => 'Тапсырманы беру мүмкін болмады. Қайтадан көріңіз.';

  @override
  String get attachmentOpenFailed => 'Файлды ашу мүмкін болмады';

  @override
  String get actApprove => 'Мақұлдау';

  @override
  String get excuseApprovedToast => 'Өтінім мақұлданды';

  @override
  String get excuseApproveFailed => 'Өтінімді мақұлдау мүмкін болмады';

  @override
  String get liveNow => 'Сабақ жүріп жатыр';

  @override
  String liveMarked(int done, int total) {
    return 'Белгіленді $done/$total';
  }

  @override
  String get liveEnded => 'Сабақ аяқталды';

  @override
  String get liveEndedTopic => 'Сабақ аяқталды: тақырып толтырылмаған';

  @override
  String get liveUntilBell => 'Қоңырауға дейін';

  @override
  String get notifPublicTitle => 'GradeApp';

  @override
  String get notifPublicBody => 'Жаңа хабарландыру';

  @override
  String liveShortMinutes(int n) {
    return '$n мин';
  }

  @override
  String get liveChannel => 'Сабақ жүріп жатыр';

  @override
  String get remChannel => 'Еске салулар';

  @override
  String remTitle(String cls) {
    return '$cls: қатысу белгіленбеген';
  }

  @override
  String remBody(String subject, String start, String end) {
    return '$subject, $start–$end';
  }

  @override
  String get wgNext => 'Келесі сабақ';

  @override
  String get wgNow => 'Қазір';

  @override
  String get wgDay => 'Күн';

  @override
  String wgUpdated(String time) {
    return 'Жаңартылды $time';
  }

  @override
  String get wgStale => 'Жаңарту үшін қолданбаны ашыңыз';

  @override
  String get wgNoMore => 'Бүгін сабақ қалмады';

  @override
  String get wgNoLessons => 'Бүгін сабақ жоқ';

  @override
  String get wgHomeworkTomorrow => 'Ертеңгі үй тапсырмасы';

  @override
  String get wgNoHomework => 'Ертеңге тапсырма жоқ';

  @override
  String get wgSignedOut => 'GradeApp-қа кіріңіз';

  @override
  String get wgTomorrow => 'Ертең';

  @override
  String get wgStartsIn => 'Басталуына';

  @override
  String get wgEndsIn => 'Аяқталуына';

  @override
  String get setLocalTitle => 'Осы телефонда';

  @override
  String get setReminders => 'Қатысуды белгілеу туралы еске салу';

  @override
  String get setLive => 'Құлыптау экранындағы «Сабақ жүріп жатыр»';

  @override
  String get ntCheckInMissing => 'Мектепке белгі қойылмады';

  @override
  String get wgNextShort => 'Келесі';

  @override
  String get s7Title => 'Болжам';

  @override
  String get s7Now => 'Қазір';

  @override
  String s7NowLine(String pct, String mark) {
    return '$pct % · баға $mark';
  }

  @override
  String s7NextWork(String title, String date) {
    return 'Жақын жұмыс: $title, $date';
  }

  @override
  String get s7MaxScore => 'Жұмыстың ең жоғары балы';

  @override
  String get s7Less => 'Баллды азайту';

  @override
  String get s7More => 'Баллды көбейту';

  @override
  String s7Need(String mark, String kind, int need, int max) {
    return '$mark деңгейіне шығу үшін $kind жұмысынан кемінде $need / $max жинау керек';
  }

  @override
  String get s7NoStep => 'Бұл жұмыс бағаны өзгертпейді, бірақ ол маңызды: мүмкіндігінше жақсы орындап көріңіз.';

  @override
  String get s7Top => 'Қазір ең жоғары бағаңыз бар. Осылай жалғастырыңыз!';

  @override
  String s7IfIGet(String kind, int score, int max) {
    return 'Егер $kind жұмысынан $score / $max алсам';
  }

  @override
  String s7Result(String mark, String pct) {
    return 'Тоқсандық: $mark ($pct %)';
  }

  @override
  String get s7Disclaimer => 'Бұл мектеп формуласы бойынша шамамен есептеу. Қорытынды бағаны мұғалім қояды.';

  @override
  String get s7Hidden => 'Болжам әзірге қолжетімсіз';

  @override
  String get s7HiddenFormula => 'Мектеп формуласы әлі жүктелген жоқ. Кейінірек қайталап көріңіз.';

  @override
  String s7HiddenFew(int count) {
    return 'Болжам шынайы болу үшін кемінде $count бағаланған жұмыс қажет.';
  }

  @override
  String get s10Title => 'Серия және жетістіктер';

  @override
  String get s10Unavailable => 'Мектебіңізде серия қосылмаған.';

  @override
  String get s10ParentOff => 'Серияны ата-анаңыз өшірген. Бұл оқуға әсер етпейді.';

  @override
  String get s10CardStart => 'Уақытында келу сериясы: бүгіннен бастаңыз';

  @override
  String s10CardCheckin(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count күн уақытында');
    return '$_temp0';
  }

  @override
  String s10CardHomework(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'ҮТ мерзімінде: $count күн');
    return '$_temp0';
  }

  @override
  String s10Days(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count күн');
    return '$_temp0';
  }

  @override
  String get s10DaysShort => 'күн';

  @override
  String s10Best(int count) {
    return 'Үздік: $count';
  }

  @override
  String s10FreezesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count мұздату қалды');
    return '$_temp0';
  }

  @override
  String get s10KindCheckin => 'Мектепке уақытында келу';

  @override
  String get s10KindHomework => 'ҮТ мерзімінде';

  @override
  String get s10TodayDoneCheckin => 'Бүгін белгіленді';

  @override
  String get s10TodayDoneHomework => 'Бүгінге бәрі мерзімінде тапсырылды';

  @override
  String get s10TodayPending => 'Бүгін әлі үлгеруге болады';

  @override
  String get s10TodayFrozen => 'Күн мұздатылды: серия сақталды';

  @override
  String get s10TodayExcused => 'Өтініш бар: серия аялдап тұр';

  @override
  String get s10TodayOff => 'Бүгін оқу күні емес';

  @override
  String get s10TodayOffHomework => 'Жақын оқу күніне тапсырма жоқ';

  @override
  String get s10TodayMissed => 'Бүгін есептелмеді — күнді қатыруға болады';

  @override
  String get s10ExcusedTitle => 'Өтініш қабылданды.';

  @override
  String get s10ExcusedBody => 'Серия үзілмейді және өспейді: сізді күтіп тұр.';

  @override
  String get s10Milestones => 'Белгі беттері';

  @override
  String s10MilestoneReached(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: 'Жетті: $days күн');
    return '$_temp0';
  }

  @override
  String s10MilestoneAhead(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: 'Алда: $days күн');
    return '$_temp0';
  }

  @override
  String s10MilestoneToday(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days күн уақытында: тағы бір бет ашылды');
    return '$_temp0';
  }

  @override
  String get s10Missed => 'Өткізілген күндер';

  @override
  String get s10MissedHint => 'Мұздату күнді серияға қайтарады. Оны тәулік ішінде қолдануға болады.';

  @override
  String get s10Freeze => 'Мұздату';

  @override
  String get s10Frozen => 'Күн мұздатылды';

  @override
  String get s10FreezeExpired => 'Мұздату уақыты өтті';

  @override
  String get s10NoFreezes => 'Осы тоқсанға мұздату қалмады';

  @override
  String get s10SickNote => 'Ауырып қалсаң — үйде қал: өтініш болса, серия үзілмейді.';

  @override
  String get s10ParentSwitch => 'Серия және жетістіктер';

  @override
  String get s10ParentExplain =>
      'Қолданба оқушының сабаққа уақытында келгенін және үй тапсырмасын мерзімінде тапсырғанын белгілейді. Мұны оқушы мен ата-аналар көреді, басқа оқушылар мен қызметкерлер көрмейді. Ауырғаны туралы өтініш серияны үзбейді.';

  @override
  String get s11Title => 'Сенің аптаң';

  @override
  String get s11DaysOnTime => 'күн уақытында';

  @override
  String get s11Homework => 'ҮТ тапсырылды';

  @override
  String s11Milestone(int days) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days күн уақытында: жаңа бет');
    return '$_temp0';
  }

  @override
  String get s11WithMarks => 'Суретте бағаларды көрсету';

  @override
  String get s11MarksWarning =>
      'Карточкада бағалар болады. Оны бөлісу арқылы бағаларды басқа адамдарға көрінетін етесіз.';

  @override
  String get s11Save => 'Сурет ретінде сақтау';

  @override
  String get p5Title => 'Қатысу';

  @override
  String get p5RowHint => 'Күнтізбе, қалып қоюлар және себептер';

  @override
  String p5Quarter(String name) {
    return 'Қатысу · $name';
  }

  @override
  String p5CountAbsent(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count қалып қою');
    return '$_temp0';
  }

  @override
  String p5CountTardy(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count кешігу');
    return '$_temp0';
  }

  @override
  String p5CountExcused(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count өтініш бойынша');
    return '$_temp0';
  }

  @override
  String get p5NoMisses => 'Қалып қоюсыз';

  @override
  String get p5PrevMonth => 'Алдыңғы ай';

  @override
  String get p5NextMonth => 'Келесі ай';

  @override
  String get p5Present => 'Болды';

  @override
  String get p5Tardy => 'Кешікті';

  @override
  String get p5Absent => 'Қалып қойды';

  @override
  String get p5Excused => 'Өтініш бойынша';

  @override
  String get p5NoLessons => 'Сабақ жоқ';

  @override
  String get p5Absences => 'Айдағы қалып қоюлар';

  @override
  String get p5NoReason => 'себебі көрсетілмеген';

  @override
  String get p6Title => 'Апта қорытындысы';

  @override
  String get p6OpenSummary => 'Толығырақ';

  @override
  String get p6PrevWeek => 'Алдыңғы апта';

  @override
  String get p6NextWeek => 'Келесі апта';

  @override
  String p6WeekOf(String range) {
    return 'Апта $range';
  }

  @override
  String get p6EmptyTitle => 'Оқу күндері болған жоқ';

  @override
  String get p6EmptyBody => 'Бұл аптада қорытынды жоқ: демалыс немесе каникул.';

  @override
  String get p6VerdictEmpty => 'Бұл аптада сабақ болған жоқ.';

  @override
  String get p6VerdictGreat => 'Тамаша апта: барлық күн уақытында, тапсырмалар тапсырылды.';

  @override
  String get p6VerdictSteady => 'Апта тыныш өтті.';

  @override
  String get p6VerdictAbsences => 'Себепсіз қалып қою бар: оны түсіндіруге болады.';

  @override
  String get p6VerdictOverdue => 'Әлі тапсырылмаған тапсырмалар бар.';

  @override
  String p6VerdictDip(String course) {
    return 'Апта тыныш өтті, «$course» пәнінен баға төмендеді.';
  }

  @override
  String get p6VerdictDipPlain => 'Апта тыныш өтті, бір пәннен баға төмендеді.';

  @override
  String get p6Attendance => 'Қатысу';

  @override
  String get p6DaysOnTime => 'Уақытында келген күндер';

  @override
  String p6OfDays(int ontime, int days) {
    return '$ontime / $days';
  }

  @override
  String get p6Tardy => 'Кешігулер';

  @override
  String get p6Absent => 'Себепсіз қалып қоюлар';

  @override
  String get p6Excused => 'Өтініш бойынша';

  @override
  String get p6Grades => 'Пәндер бойынша бағалар';

  @override
  String p6GradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count баға');
    return '$_temp0';
  }

  @override
  String p6Avg(String value) {
    return 'орташа $value';
  }

  @override
  String p6Up(String delta) {
    return '$delta жоғары';
  }

  @override
  String p6Down(String delta) {
    return '$delta төмен';
  }

  @override
  String get p6Same => 'өзгеріссіз';

  @override
  String get p6Homework => 'Үй тапсырмалары';

  @override
  String get p6HwDone => 'Тапсырылды';

  @override
  String p6OfTotal(int done, int total) {
    return '$done / $total';
  }

  @override
  String get p6HwOverdue => 'Мерзімінде тапсырылмады';

  @override
  String get p6Feedback => 'Мұғалімдердің пікірлері';

  @override
  String get p6Praise => 'Мақтау';

  @override
  String get p6Remark => 'Ескертпе';

  @override
  String get p6Upcoming => 'Келесі аптада';

  @override
  String get p6TodayCard => 'Апта қорытындысы';

  @override
  String get p6TodayCardHint => 'Апта қалай өтті және не туралы сөйлесуге болады';

  @override
  String get p6DigestWhen => 'Апта қорытындысын қашан жіберу';

  @override
  String get p6DayFri => 'Жұма';

  @override
  String get p6DaySun => 'Жексенбі';

  @override
  String get p6DigestHour => 'Жіберу уақыты';

  @override
  String get ngDigest => 'Апта қорытындысы';

  @override
  String get ntDigest => 'Апта қорытындысы';

  @override
  String get ntConsentRequested => 'Баладан сұрау';

  @override
  String get p7Ask => 'Ата-анадан сұрау';

  @override
  String get p7Sent => 'Ата-анаңызға сұрау жіберілді.';

  @override
  String get p7TooSoon => 'Сіз қазір сұрадыңыз. Ертең қайталап көріңіз.';

  @override
  String get p7AlreadyGranted => 'Ата-анаңыз рұқсат берген. Экранды жаңартыңыз.';

  @override
  String get p8Title => 'Шоттар және төлем';

  @override
  String get p8ToPay => 'Төлеуге';

  @override
  String get p8History => 'Тарих';

  @override
  String get p8Empty => 'Әзірге шот жоқ';

  @override
  String get p8EmptyHint => 'Мұнда оқу ақысының шоттары көрінеді.';

  @override
  String p8InvoiceNo(String number) {
    return '№ $number шот';
  }

  @override
  String p8DueDate(String date) {
    return '$date дейін';
  }

  @override
  String p8PaidSoFar(String amount) {
    return '$amount ₸ төленді';
  }

  @override
  String p8PayableSemantic(String amount, String due) {
    return 'Төлеуге $amount теңге, $due';
  }

  @override
  String get p8StatusSent => 'Төлеуге';

  @override
  String get p8StatusPartial => 'Ішінара төленді';

  @override
  String get p8StatusPaid => 'Төленді';

  @override
  String get p8StatusOverdue => 'Мерзімі өтті';

  @override
  String get p8StatusCancelled => 'Бас тартылды';

  @override
  String get p8Pay => 'Төлеу';

  @override
  String get p8PayFailed => 'Төлемді ашу мүмкін болмады. Қайталап көріңіз.';

  @override
  String get p8PayUnavailable => 'Мектепте онлайн төлем қазір қолжетімсіз.';

  @override
  String get p8ConfirmTitle => 'Төлеу алдында';

  @override
  String p8Confirm(String name, String bin, String amount) {
    return 'Сіз оқу ақысын тікелей мектепке төлейсіз: «$name», БСН $bin. Сомасы: $amount ₸. GradeApp ақшаны қабылдамайды және аудармайды. Фискалдық чекті мектеп немесе төлем сервисі қалыптастырады.';
  }

  @override
  String p8ConfirmNoBin(String name, String amount) {
    return 'Сіз оқу ақысын тікелей мектепке төлейсіз: «$name». Сомасы: $amount ₸. GradeApp ақшаны қабылдамайды және аудармайды. Фискалдық чекті мектеп немесе төлем сервисі қалыптастырады.';
  }

  @override
  String get p8ConfirmGo => 'Төлеуге өту';

  @override
  String get p8Checking => 'Төлемді тексеріп жатырмыз';

  @override
  String get p8CheckingHint => 'Әдетте бір минуттан аз уақыт алады.';

  @override
  String get p8Arrived => 'Төлем қабылданды. Рақмет!';

  @override
  String get p8Delayed => 'Төлем әзірге көрінбейді.';

  @override
  String get p8DelayedHint =>
      'Банк кейде төлемді ұзағырақ растайды. Ақша есептен шығарылса, қайта төлеудің қажеті жоқ: мәртебе өзі жаңарады.';

  @override
  String get p8CheckNow => 'Тексеру';

  @override
  String get p8OnlineOff => 'Онлайн төлем жоқ.';

  @override
  String get p8OnlineOffHint => 'Төменде көрсетілген деректемелер бойынша аудару арқылы төлеңіз.';

  @override
  String get p8Payments => 'Төлемдер';

  @override
  String get p8MethodCash => 'Қолма-қол';

  @override
  String get p8MethodTransfer => 'Аударым';

  @override
  String get p8HowToPay => 'Аударым арқылы қалай төлеу';

  @override
  String get p8ReqRecipient => 'Алушы';

  @override
  String get p8ReqBin => 'БСН';

  @override
  String get p8ReqBank => 'Банк';

  @override
  String get p8ReqBik => 'БСК';

  @override
  String get p8ReqKbe => 'КБе';

  @override
  String get p8ReqKnp => 'ТМК';

  @override
  String get p8ReqPurpose => 'Төлемнің мақсаты';

  @override
  String p8PurposeValue(String number) {
    return 'Оқу ақысы, № $number шот';
  }

  @override
  String get p8Copy => 'Көшіру';

  @override
  String get p8Copied => 'Көшірілді';

  @override
  String get p8Document => 'Құжат';

  @override
  String get p8PdfTitle => 'Төлем шоты';

  @override
  String get p8PdfCaption => 'Ақпараттық құжат, фискалдық чек емес';

  @override
  String get p8PdfFailed => 'Құжатты алу мүмкін болмады.';

  @override
  String get p9Title => 'Мұғалімдер';

  @override
  String get p9Homeroom => 'Сынып жетекшісі';

  @override
  String get p9Write => 'Жазу';

  @override
  String p9WriteTo(String name) {
    return 'Жазу: $name';
  }

  @override
  String p9AllTeachers(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Барлық мұғалімдер ($count)');
    return '$_temp0';
  }

  @override
  String get p9Empty => 'Мұғалімдер тізімі әзірге бос';

  @override
  String get p10Pinned => 'Хабарландыру';

  @override
  String p10PinnedMany(String title, int more) {
    return '$title және тағы $more';
  }

  @override
  String get p10Expand => 'Ашу';

  @override
  String get p10Collapse => 'Жинау';

  @override
  String get p10AllEvents => 'Барлық іс-шаралар';

  @override
  String get p10Events => 'Мектеп іс-шаралары';

  @override
  String get p10EventsEmpty => 'Жақын арада іс-шара жоқ';

  @override
  String get p10EventsEmptyHint => 'Мұнда алдағы апталардағы іс-шаралар көрінеді.';

  @override
  String get t6Praise => 'Мақтау';

  @override
  String get t6Remark => 'Ескерту';

  @override
  String t6PraiseTitle(String name) {
    return 'Мақтау: $name';
  }

  @override
  String t6RemarkTitle(String name) {
    return 'Ескерту: $name';
  }

  @override
  String get t6TextHint => 'Қажет болса, бір-екі сөз (міндетті емес)';

  @override
  String get t6TagActive => 'Белсенді болды';

  @override
  String get t6TagHelped => 'Басқаларға көмектесті';

  @override
  String get t6TagProgress => 'Айқын жетістік';

  @override
  String get t6TagGreatAnswer => 'Тамаша жауап';

  @override
  String get t6TagLate => 'Кешікті';

  @override
  String get t6TagNoHomework => 'Үй тапсырмасы жоқ';

  @override
  String get t6TagDistracted => 'Алаңдады';

  @override
  String get t6TagNoMaterials => 'Құрал-жабдығы жоқ';

  @override
  String get t9Substitution => 'Ауыстыру';

  @override
  String t9ForTeacher(String name) {
    return '$name орнына';
  }

  @override
  String t9TaughtBy(String name) {
    return '$name жүргізеді';
  }

  @override
  String get t12Title => 'ҮТ орындалуы';

  @override
  String t12Done(int done, int total) {
    return '$total оқушының $done-і орындады';
  }

  @override
  String get t12AllDone => 'Барлығы орындады';

  @override
  String t12NotDone(int count) {
    return 'Орындамағандар: $count';
  }

  @override
  String get t12Remind => 'Еске салу';

  @override
  String t12Reminded(int count) {
    return 'Еске салуды $count адам алды';
  }

  @override
  String get t12TooSoon => 'Сағатына бір рет қана болады';

  @override
  String get t12RemindFailed => 'Еске салу жіберілмеді';

  @override
  String get t12Loading => 'Кім орындағанын санап жатырмыз…';

  @override
  String get t12Open => 'Кім орындады';

  @override
  String get t8Tab => 'Менің сыныбым';

  @override
  String t8Came(int came, int total) {
    return '$total оқушының $came-і келді';
  }

  @override
  String t8Unmarked(int count) {
    return 'Белгісіз: $count';
  }

  @override
  String get t8AllMarked => 'Бәрі белгіленген';

  @override
  String t8NextLesson(String subject, String time) {
    return 'Келесі: $subject, $time';
  }

  @override
  String get t8RollCall => 'Таңертеңгі белгі';

  @override
  String get t8MarkClass => 'Сыныпты күнге белгілеу';

  @override
  String get t8AllCame => 'Барлығы келді';

  @override
  String get t8MarkSent => 'Сынып белгісі жіберілуде';

  @override
  String get t8SourceExcuse => 'Өтініш бойынша';

  @override
  String get t8SourcePending => 'Өтініш бар';

  @override
  String get t8Requests => 'Келмеу өтініштері';

  @override
  String get t8Approve => 'Қабылдау';

  @override
  String get t8Reject => 'Қабылдамау';

  @override
  String get t8RejectTitle => 'Неге қабылдамайсыз?';

  @override
  String get t8RejectHint => 'Ата-ана бұл хабарламаны көреді';

  @override
  String get t8RejectSend => 'Өтінішті қабылдамау';

  @override
  String get t8Approved => 'Өтініш қабылданды';

  @override
  String get t8Rejected => 'Өтініш қабылданбады';

  @override
  String get t8ReviewFailed => 'Шешім жіберілмеді';

  @override
  String get t8Photo => 'Өтінішке фото';

  @override
  String t8From(String name) {
    return 'Жіберген: $name';
  }

  @override
  String get t8Week => 'Сыныптың аптасы';

  @override
  String t8WeekRate(String rate) {
    return 'Қатысу $rate%';
  }

  @override
  String t8WeekAbsent(int count) {
    return 'Жіберулер: $count';
  }

  @override
  String t8WeekTardy(int count) {
    return 'Кешігулер: $count';
  }

  @override
  String get t8AtRisk => 'Тәуекел тобы';

  @override
  String get t8AtRiskNone => 'Тәуекел тобында ешкім жоқ';

  @override
  String get t8OpenWeb => 'Веб-нұсқада ашу';

  @override
  String get t8Empty => 'Сыныпта оқушы жоқ';

  @override
  String get t8NotHomeroom => 'Бөлім сынып жетекшілеріне арналған';

  @override
  String get t8InboxSub => '«Менің сыныбым» бөлімінде қабылдауға болады';

  @override
  String t8WhatDay(int count) {
    return 'Күнге сынып белгісі: $count';
  }

  @override
  String t8ClassPick(String name) {
    return '$name сыныбы';
  }

  @override
  String wgChildIn(String time) {
    return '$time-ден бері мектепте';
  }

  @override
  String get wgChildInNoTime => 'Мектепте';

  @override
  String get wgChildDayOver => 'Сабақтар бітті';

  @override
  String get wgChildNotYet => 'Әзірге белгі жоқ';

  @override
  String wgChildNewGrades(int count) {
    return '$count жаңа баға';
  }

  @override
  String get wgChildNoNew => 'Жаңа баға жоқ';

  @override
  String get wgChildAbsent => 'Мектепте жоқ';

  @override
  String get chatTitle => 'Хабарламалар';

  @override
  String get chatEmpty => 'Хат алмасу әлі жоқ';

  @override
  String get chatEmptyHint => 'Мұғалімге не ата-анаға жазыңыз — жауап осында келеді.';

  @override
  String get chatThreadEmpty => 'Алғашқы хабарламаны жазыңыз';

  @override
  String get chatNew => 'Жаңа хабарлама';

  @override
  String get chatSearch => 'Аты немесе сынып';

  @override
  String get chatNoOne => 'Ешкім табылмады';

  @override
  String get chatInputHint => 'Хабарлама';

  @override
  String get chatSend => 'Жіберу';

  @override
  String get chatSending => 'Жіберілуде…';

  @override
  String get chatSendFailed => 'Жіберілмеді — қайталау үшін басыңыз';

  @override
  String get chatEdited => 'өзгертілді';

  @override
  String get chatYou => 'Сіз';

  @override
  String get chatAttachment => 'Тіркеме';

  @override
  String get chatSystem => 'Әңгімедегі өзгеріс';

  @override
  String get chatReadOnly => 'Бұл арнада тек автор жазады';

  @override
  String get chatMute => 'Дыбыссыз';

  @override
  String get chatUnmute => 'Дыбысты қосу';

  @override
  String get chatMuted => 'Әңгіме хабарландырулары өшірілді';

  @override
  String get chatUnmuted => 'Әңгіме хабарландырулары қосылды';

  @override
  String get chatOpenFailed => 'Хат алмасуды ашу мүмкін болмады';

  @override
  String get chatInboxSub => 'Ата-аналармен және әріптестермен хат алмасу';

  @override
  String chatUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count оқылмаған әңгіме');
    return '$_temp0';
  }

  @override
  String factCameAt(String time) {
    return '$time-те келді.';
  }

  @override
  String get factDayOver => 'Сабақтар бітті.';
}
