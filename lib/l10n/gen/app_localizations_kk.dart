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
  String get loginTitle => 'GradeApp-қа кіру';

  @override
  String get loginSubtitle => 'Мектеп аккаунтының поштасы мен құпиясөзін енгізіңіз';

  @override
  String get email => 'Пошта';

  @override
  String get password => 'Құпиясөз';

  @override
  String get otpCode => 'Аутентификатор қосымшасының коды';

  @override
  String get otpHint => '6 сан';

  @override
  String get signIn => 'Кіру';

  @override
  String get loginInvalid => 'Пошта немесе құпиясөз қате';

  @override
  String get loginOtpInvalid => 'Код қате';

  @override
  String get loginNoRole => 'Мобильді қосымшада әзірге оқушы, ата-ана және мұғалім кабинеттері қолжетімді';

  @override
  String get signOut => 'Шығу';

  @override
  String get errorTitle => 'Жүктеу мүмкін болмады';

  @override
  String get errorMessage => 'Интернетті тексеріп, қайталап көріңіз';

  @override
  String get retry => 'Қайталау';

  @override
  String get offlineSaved => 'Телефонда сақталды — желі пайда болғанда жібереміз';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count өзгеріс жіберуді күтуде');
    return '$_temp0';
  }

  @override
  String get syncRejected => 'Сервер өзгерісті қабылдамады. Тексеріп, қайта белгілеңіз';

  @override
  String get synced => 'Бәрі жіберілді';

  @override
  String get tabToday => 'Бүгін';

  @override
  String get tabSchedule => 'Кесте';

  @override
  String get tabGrades => 'Бағалар';

  @override
  String get tabHomework => 'Тапсырмалар';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get tabLessons => 'Сабақтар';

  @override
  String get now => 'Қазір';

  @override
  String get next => 'Келесі';

  @override
  String greetingMorning(String name) {
    return 'Қайырлы таң, $name';
  }

  @override
  String greetingDay(String name) {
    return 'Қайырлы күн, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Қайырлы кеш, $name';
  }

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count сабақ', zero: 'Сабақ жоқ');
    return '$_temp0';
  }

  @override
  String get noLessonsTitle => 'Сабақ жоқ';

  @override
  String get noLessonsMessage => 'Бұл күні сабақ жоқ';

  @override
  String room(String room) {
    return '$room каб.';
  }

  @override
  String lessonEndsIn(int minutes) {
    return '$minutes минуттан кейін аяқталады';
  }

  @override
  String lessonStartsIn(int minutes) {
    return '$minutes минуттан кейін басталады';
  }

  @override
  String get dayDone => 'Бүгінгі сабақтар аяқталды';

  @override
  String get presencePresent => 'Келді';

  @override
  String get presenceAbsent => 'Жоқ';

  @override
  String get presenceTardy => 'Кешікті';

  @override
  String get presenceExcused => 'Себепті';

  @override
  String get presenceAbsentLong => 'Келмеді';

  @override
  String get presenceExcusedLong => 'Себепті жоқ';

  @override
  String get checkInTitle => 'Мен мектептемін';

  @override
  String get checkInAction => 'Белгілену';

  @override
  String get checkInHint => 'Кіреберісте селфи түсіріңіз — мұғалім келгеніңізді көреді';

  @override
  String checkInDone(String time) {
    return '$time белгіленді';
  }

  @override
  String get checkInLate => 'Кешігу';

  @override
  String checkInWindow(String from, String to) {
    return 'Белгілену уақыты: $from–$to';
  }

  @override
  String get checkInNoConsent => 'Ата-ана фото-белгілеуге әлі келісім бермеген';

  @override
  String get checkInSending => 'Жіберілуде…';

  @override
  String get checkInSuccess => 'Дайын, сіз белгілендіңіз';

  @override
  String get checkInLocationDenied => 'Геолокацияға рұқсат беріңіз — мектеп сіздің орныңызды тексереді';

  @override
  String checkInOutside(int meters) {
    return 'Сіз мектеп аумағынан тыссыз ($meters м)';
  }

  @override
  String get checkInStale => 'Дәл қазір түсірілген жаңа фото қажет';

  @override
  String get checkInAlready => 'Сіз бүгін белгіленіп қойдыңыз';

  @override
  String get checkInClosed => 'Белгілену уақыты аяқталды';

  @override
  String childCheckedIn(String time) {
    return 'Мектепке $time келді';
  }

  @override
  String get childNotCheckedIn => 'Мектепте әлі белгіленбеді';

  @override
  String get homeworkDue => 'Тапсырмалар';

  @override
  String get homeworkEmptyTitle => 'Тапсырма жоқ';

  @override
  String get homeworkEmptyMessage => 'Жаңа тапсырмалар осында шығады';

  @override
  String get homeworkActive => 'Өзекті';

  @override
  String get homeworkDoneTab => 'Орындалған';

  @override
  String homeworkMinutes(int minutes) {
    return '≈ $minutes мин';
  }

  @override
  String get dueToday => 'Бүгін тапсыру';

  @override
  String get dueTomorrow => 'Ертең тапсыру';

  @override
  String dueOn(String date) {
    return '$date дейін тапсыру';
  }

  @override
  String get overdue => 'Мерзімі өтті';

  @override
  String get attachments => 'Файлдар';

  @override
  String get markDone => 'Орындалды деп белгілеу';

  @override
  String get markUndone => 'Өзектіге қайтару';

  @override
  String get recentGrades => 'Соңғы бағалар';

  @override
  String get gradesEmptyTitle => 'Әзірге баға жоқ';

  @override
  String get gradesEmptyMessage => 'Барлық пәндер бойынша бағалар осында шығады';

  @override
  String get average => 'Орташа';

  @override
  String gradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count баға');
    return '$_temp0';
  }

  @override
  String get all => 'Барлығы';

  @override
  String get weekPrev => 'Алдыңғы апта';

  @override
  String get weekNext => 'Келесі апта';

  @override
  String get today => 'Бүгін';

  @override
  String get profileChildren => 'Балалар';

  @override
  String get photoConsent => '«Мен мектептемін» фото-белгілеуі';

  @override
  String get photoConsentHint => 'Бала кіреберісте селфимен белгілене алады';

  @override
  String get language => 'Тіл';

  @override
  String get theme => 'Тақырып';

  @override
  String get themeSystem => 'Жүйедегідей';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeLight => 'Ашық';

  @override
  String get themeDark => 'Күңгірт';

  @override
  String get role => 'Кабинет';

  @override
  String get roleTeacher => 'Мұғалім';

  @override
  String get roleParent => 'Ата-ана';

  @override
  String get roleStudent => 'Оқушы';

  @override
  String get signOutConfirm => 'Аккаунттан шығасыз ба?';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get noChildrenTitle => 'Балалар байланыстырылмаған';

  @override
  String get noChildrenMessage => 'Мектептен баланы аккаунтыңызға байланыстыруды сұраңыз';

  @override
  String get teacherTodayEmpty => 'Бүгін сабақ жоқ';

  @override
  String get overdueTitle => 'Толтырылмаған';

  @override
  String get overdueHint => 'Соңғы екі аптадағы белгісіз немесе тақырыпсыз сабақтар';

  @override
  String get missingAttendance => 'Қатысу';

  @override
  String get missingTopic => 'Тақырып';

  @override
  String get missingHomework => 'ҮТ';

  @override
  String get missingGrades => 'Бағалар';

  @override
  String get allFilled => 'Бәрі толтырылды';

  @override
  String get lessonStart => 'Сабақты бастау';

  @override
  String get lessonFinish => 'Сабақты аяқтау';

  @override
  String get lessonFinished => 'Сабақ аяқталды';

  @override
  String get lessonCancelled => 'Сабақ тоқтатылды';

  @override
  String get topic => 'Сабақ тақырыбы';

  @override
  String get topicHint => 'Мысалы: Квадрат теңдеулер';

  @override
  String get allPresent => 'Барлығы орнында';

  @override
  String presentCount(int present, int total) {
    return '$total оқушының $present қатысуда';
  }

  @override
  String get fromCheckIn => 'Өзі белгіленді';

  @override
  String get fromHomeroom => 'Сынып жетекшісінің белгісі';

  @override
  String get workType => 'Жұмыс түрі';

  @override
  String gradeFor(String name) {
    return 'Баға: $name';
  }

  @override
  String get removeGrade => 'Алып тастау';

  @override
  String gradeAbsentWarn(String name) {
    return '$name жоқ. Сонда да баға қоясыз ба?';
  }

  @override
  String get rosterEmpty => 'Сыныпта оқушы жоқ';

  @override
  String get autoNext => 'Бірден келесі оқушыға';

  @override
  String get done => 'Дайын';

  @override
  String get attendanceCodes => 'Қатысу коды';

  @override
  String get save => 'Сақтау';
}
