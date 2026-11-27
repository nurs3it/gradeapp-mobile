// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'GradeApp';

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabWeek => 'Неделя';

  @override
  String get tabGrades => 'Оценки';

  @override
  String get tabTasks => 'Задания';

  @override
  String get tabFamily => 'Семья';

  @override
  String get tabInbox => 'Входящие';

  @override
  String tabWithBadge(String tab, int count) {
    return '$tab, новых: $count';
  }

  @override
  String get back => 'Назад';

  @override
  String get close => 'Закрыть';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get retry => 'Повторить';

  @override
  String get undo => 'Отменить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get skip => 'Пропустить';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get change => 'Изменить';

  @override
  String get add => 'Добавить';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get send => 'Отправить';

  @override
  String get errorTitle => 'Не получилось загрузить';

  @override
  String get errorOffline => 'Нет сети. Проверьте интернет и повторите';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз';

  @override
  String offlineBar(String time) {
    return 'Нет сети. Показаны данные от $time';
  }

  @override
  String get offlineBarNoTime => 'Нет сети. Показаны сохранённые данные';

  @override
  String updatedAt(String time) {
    return 'Обновлено в $time';
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
    return 'через $m мин';
  }

  @override
  String room(String room) {
    return 'каб. $room';
  }

  @override
  String nOfM(int n, int m) {
    return '$n из $m';
  }

  @override
  String get yesterday => 'Вчера';

  @override
  String get tomorrow => 'Завтра';

  @override
  String get todayWord => 'Сегодня';

  @override
  String lessonsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков',
      few: '$count урока',
      one: '$count урок',
      zero: 'Уроков нет',
    );
    return '$_temp0';
  }

  @override
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заданий',
      few: '$count задания',
      one: '$count задание',
    );
    return '$_temp0';
  }

  @override
  String tasksUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'заданий', few: 'задания', one: 'задание');
    return '$_temp0';
  }

  @override
  String get roleTeacher => 'Учитель';

  @override
  String get roleParent => 'Родитель';

  @override
  String get roleStudent => 'Ученик';

  @override
  String get notifications => 'Уведомления';

  @override
  String notificationsUnread(int count) {
    return 'Уведомления, непрочитанных: $count';
  }

  @override
  String get profile => 'Профиль';

  @override
  String switchChild(String name) {
    return 'Сменить ребёнка, сейчас $name';
  }

  @override
  String get profileSchools => 'Школы';

  @override
  String get profileChildren => 'Дети';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsTheme => 'Оформление';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлое';

  @override
  String get themeDark => 'Тёмное';

  @override
  String get langSystem => 'Как в системе';

  @override
  String get langKk => 'Қазақша';

  @override
  String get langRu => 'Русский';

  @override
  String get langEn => 'English';

  @override
  String get openWeb => 'Открыть веб-версию';

  @override
  String get about => 'О приложении';

  @override
  String version(String v) {
    return 'Версия $v';
  }

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutConfirm => 'Выйти из аккаунта?';

  @override
  String signOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей не отправлено',
      few: '$count записи не отправлены',
      one: '$count запись не отправлена',
    );
    return '$_temp0. Если выйти, они пропадут';
  }

  @override
  String get signOutSendFirst => 'Отправить и выйти';

  @override
  String get signOutAnyway => 'Выйти без отправки';

  @override
  String get signOutWaitNet => 'Нет сети — записи ещё не ушли';

  @override
  String get photoConsent => 'Отметка по селфи';

  @override
  String get consentOn => 'разрешена';

  @override
  String get consentOff => 'не разрешена';

  @override
  String get consentRevoke => 'Запретить отметку по селфи?';

  @override
  String get consentRevokeBody => 'Ребёнок не сможет отмечаться «Я в школе» по фото';

  @override
  String get consentRevokeAction => 'Запретить';

  @override
  String get switchSchoolFailed => 'Не получилось сменить школу';

  @override
  String get noChildrenTitle => 'Дети не привязаны';

  @override
  String get noChildrenMessage => 'Попросите школу привязать ребёнка к вашему аккаунту';

  @override
  String get allFamily => 'Вся семья';

  @override
  String className(String name) {
    return 'класс $name';
  }

  @override
  String get loginTagline => 'Расписание, оценки и журнал школы — в одном приложении';

  @override
  String get loginHow => 'Как вы войдёте?';

  @override
  String get loginWithPassword => 'Логин и пароль';

  @override
  String get loginWithPasswordHint => 'Почта или логин, который дала школа';

  @override
  String get loginWithCode => 'Код из школы';

  @override
  String get loginWithCodeHint => 'Листок с кодом вида ABCDE-12345';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginField => 'Почта или логин';

  @override
  String get password => 'Пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get signIn => 'Войти';

  @override
  String get loginInvalid => 'Неверный логин или пароль';

  @override
  String get loginBlocked => 'Аккаунт заблокирован — обратитесь в школу';

  @override
  String get loginThrottled => 'Слишком много попыток. Подождите минуту';

  @override
  String get loginNoRole => 'В приложении пока есть кабинеты ученика, родителя и учителя';

  @override
  String get otpTitle => 'Код подтверждения';

  @override
  String get otpHint => 'Введите 6 цифр из приложения-аутентификатора';

  @override
  String get otpInvalid => 'Неверный код';

  @override
  String get resetTitle => 'Восстановить пароль';

  @override
  String get resetHint => 'Пришлём на почту ссылку, чтобы задать новый пароль';

  @override
  String get resetEmail => 'Почта';

  @override
  String get resetSend => 'Отправить ссылку';

  @override
  String get resetSentTitle => 'Проверьте почту';

  @override
  String resetSentBody(String email) {
    return 'Если адрес $email есть в GradeApp, на него придёт письмо со ссылкой';
  }

  @override
  String get resetOtherEmail => 'Ввести другой адрес';

  @override
  String get codeTitle => 'Код из школы';

  @override
  String get codeHint => 'Код напечатан на листке, который выдала школа';

  @override
  String get codeInvalid => 'Код не найден или уже использован';

  @override
  String get codeIncomplete => 'В коде 10 знаков';

  @override
  String get codePasswordTitle => 'Придумайте пароль';

  @override
  String get codePasswordHint => 'С ним вы будете входить в приложение и на сайт';

  @override
  String get codePwLength => 'Не короче 8 знаков';

  @override
  String get codePwMixed => 'Есть буквы и цифры';

  @override
  String get codePwMatch => 'Пароли совпадают';

  @override
  String get codePwRepeat => 'Повторите пароль';

  @override
  String get codeLoginTitle => 'Ваш логин';

  @override
  String get codeLoginHint => 'Им можно войти и в веб-версии';

  @override
  String get copy => 'Скопировать';

  @override
  String get copied => 'Скопировано';

  @override
  String stepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get heroNow => 'Сейчас';

  @override
  String get heroNext => 'Дальше';

  @override
  String heroLessonN(int n) {
    return '$n-й урок';
  }

  @override
  String get heroLast => 'последний';

  @override
  String get heroPause => 'Перемена';

  @override
  String get heroPauseNext => 'следующий';

  @override
  String get heroUntilBell => 'до звонка';

  @override
  String get heroUntilStart => 'до начала';

  @override
  String get heroUntilLesson => 'до урока';

  @override
  String get heroMin => 'мин';

  @override
  String get heroDayOver => 'День закончен';

  @override
  String get heroForTomorrow => 'На завтра';

  @override
  String get heroOpenTasks => 'Открыть задания';

  @override
  String get heroNoLessons => 'Сегодня уроков нет';

  @override
  String get heroRest => 'Можно отдохнуть';

  @override
  String get heroCancelled => 'отменён';

  @override
  String get heroThen => 'Потом';

  @override
  String heroInstead(String who, String whom) {
    return '$who вместо $whom';
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
    return 'Дальше $time $subject';
  }

  @override
  String heroTomorrowPlan(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков',
      few: '$count урока',
      one: '$count урок',
    );
    return 'Завтра $_temp0 с $time';
  }

  @override
  String heroTasksDone(int done, int total) {
    return 'ДЗ готово: $done из $total';
  }

  @override
  String get tileTomorrow => 'На завтра';

  @override
  String get tileNewGrades => 'Новые оценки';

  @override
  String get tileOverdue => 'Просрочено';

  @override
  String get dayPlan => 'План дня';

  @override
  String lessonsPassed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков прошли',
      few: '$count урока прошли',
      one: '$count урок прошёл',
    );
    return '$_temp0';
  }

  @override
  String get pillNow => 'сейчас';

  @override
  String get pillSubstitution => 'замена';

  @override
  String get pillCancelled => 'отменён';

  @override
  String get pillJoint => 'совмещённый';

  @override
  String breakLine(int m) {
    return 'перемена $m мин';
  }

  @override
  String get checkInTitle => 'Я в школе';

  @override
  String checkInBy(String time) {
    return 'Отметка до $time';
  }

  @override
  String get checkInSubtitle => 'Селфи у входа — 5 секунд';

  @override
  String checkInOpensAt(String time) {
    return 'Отметка откроется в $time';
  }

  @override
  String checkInDoneAt(String time) {
    return 'В школе с $time';
  }

  @override
  String get checkInOnTime => 'Отметка вовремя';

  @override
  String checkInLateAt(String time) {
    return 'Отмечено в $time · опоздание';
  }

  @override
  String checkInClosed(String time) {
    return 'Окно отметки закрыто в $time';
  }

  @override
  String get checkInClosedHint => 'Если вы уже в школе, скажите классному руководителю';

  @override
  String get checkInNoConsent => 'Нужно разрешение родителя на фото';

  @override
  String get checkInAskParent => 'Как попросить родителя';

  @override
  String get checkInAskParentHint =>
      'Родитель разрешает это в своём приложении GradeApp: «Сегодня» → «Разрешить». Это займёт минуту';

  @override
  String get checkInSending => 'Отправляем фото…';

  @override
  String checkInSendingPct(int pct) {
    return 'Отправляем… $pct %';
  }

  @override
  String checkInOutside(int meters) {
    return 'Вы в $meters м от школы. Подойдите ближе ко входу и повторите';
  }

  @override
  String get checkInNeedLocation => 'Включите геолокацию';

  @override
  String get checkInStale => 'Сделайте новый снимок';

  @override
  String get checkInOffline => 'Нет сети. Повторим без нового снимка, пока окно открыто';

  @override
  String get checkInAlready => 'Вы уже отметились сегодня';

  @override
  String get checkInWindowClosed => 'Окно отметки закрыто';

  @override
  String get checkInFailed => 'Не получилось отправить фото';

  @override
  String get checkInOpenCamera => 'Открыть камеру';

  @override
  String get camLocating => 'Ищем геопозицию…';

  @override
  String camAtSchool(String time) {
    return 'Вы у школы · окно до $time';
  }

  @override
  String camWindowUntil(String time) {
    return 'Окно до $time';
  }

  @override
  String get camFar => 'Далеко от школы';

  @override
  String get camHint => 'Лицо в овале — и снимок';

  @override
  String get camPrivacy => 'Фото увидит только персонал школы. Оно удалится через 30 дней';

  @override
  String get camShutter => 'Сделать снимок';

  @override
  String get camFlashOn => 'Включить вспышку экраном';

  @override
  String get camFlashOff => 'Выключить вспышку экраном';

  @override
  String get camRetake => 'Переснять';

  @override
  String get camUnavailable => 'Камера недоступна';

  @override
  String get camDenied => 'Включите «Камера» для GradeApp в настройках телефона';

  @override
  String get camExplainTitle => 'Отметка по селфи';

  @override
  String get camExplainWhy => 'Селфи у входа подтверждает, что вы в школе';

  @override
  String get camExplainWho => 'Фото видит только персонал школы';

  @override
  String get camExplainKeep => 'Фото удаляется через 30 дней';

  @override
  String get doneTitle => 'Отмечено';

  @override
  String doneOnTime(String time) {
    return '$time · вовремя';
  }

  @override
  String doneLate(String time) {
    return '$time · опоздание';
  }

  @override
  String doneLateMin(String time, int m) {
    return '$time · опоздание на $m мин';
  }

  @override
  String doneFirstLesson(String time) {
    return 'Первый урок · $time';
  }

  @override
  String get doneParents => 'Родители увидят отметку в приложении';

  @override
  String weekEyebrow(String range, String term) {
    return '$range · $term';
  }

  @override
  String get weekGoToday => 'Сегодня';

  @override
  String weekDaySpan(String lessons, String from, String to) {
    return '$lessons · $from–$to';
  }

  @override
  String get weekNoLessons => 'Уроков нет';

  @override
  String get weekNoLessonsHint => 'В этот день занятий нет';

  @override
  String get weekPrev => 'Предыдущая неделя';

  @override
  String get weekNext => 'Следующая неделя';

  @override
  String get hwShort => 'ДЗ';

  @override
  String get dotChanges => 'есть изменения';

  @override
  String get dotHomework => 'есть ДЗ';

  @override
  String get dotExam => 'СОР или СОЧ';

  @override
  String lessonOrdinal(String weekday, int n) {
    return '$weekday · $n-й урок';
  }

  @override
  String get teacher => 'Учитель';

  @override
  String get topicLabel => 'Тема';

  @override
  String get lessonHomework => 'Задание к уроку';

  @override
  String get myMarks => 'Мои отметки';

  @override
  String get childMarks => 'Отметки';

  @override
  String get notFilledYet => 'Учитель ещё не заполнил';

  @override
  String get explainAbsence => 'Объяснить пропуск';

  @override
  String get openLesson => 'Открыть урок';

  @override
  String get presencePresent => 'был на уроке';

  @override
  String get presenceAbsent => 'пропуск';

  @override
  String get presenceTardy => 'опоздание';

  @override
  String get presenceExcused => 'уважительная';

  @override
  String gradesEyebrow(String term, int week) {
    return '$term · $week-я неделя';
  }

  @override
  String termShort(int n) {
    return '$n четв.';
  }

  @override
  String get termRunning => 'идёт';

  @override
  String termPick(String term) {
    return 'Выбрать $term';
  }

  @override
  String get segSubjects => 'Предметы';

  @override
  String get segFeed => 'Лента';

  @override
  String subjectsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count предметов',
      few: '$count предмета',
      one: '$count предмет',
    );
    return '$_temp0';
  }

  @override
  String get sortAttention => 'Сначала требующие внимания';

  @override
  String get sortAlpha => 'По алфавиту';

  @override
  String get prelim => 'предв.';

  @override
  String get gradesEmpty => 'Оценок в этой четверти пока нет';

  @override
  String get gradesEmptyHint => 'Первая появится после урока';

  @override
  String insightStrong(String subject) {
    return 'Сильнее всего — $subject.';
  }

  @override
  String insightWeak(String subject, int pct) {
    return 'Внимания требует $subject: $pct %.';
  }

  @override
  String quarterResults(String term) {
    return 'Итоги: $term';
  }

  @override
  String get howCalculated => 'Как считается четвертная';

  @override
  String get howCalcBody => 'Так же считает школа и табель';

  @override
  String get howCalcMissing => 'Если какой-то части пока нет, её вес делится между остальными';

  @override
  String get pctToMark => '% → отметка';

  @override
  String pctFrom(int pct) {
    return 'от $pct %';
  }

  @override
  String get formulaMissing => 'Формула школы не загрузилась, поэтому четвертная скрыта';

  @override
  String subjectPrelim(String term) {
    return '$term · предварительно';
  }

  @override
  String subjectFinal(String term) {
    return '$term · итог';
  }

  @override
  String worksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count работ',
      few: '$count работы',
      one: '$count работа',
    );
    return '$_temp0';
  }

  @override
  String toNextMark(String mark, int pct) {
    return 'до «$mark» не хватает $pct %';
  }

  @override
  String get works => 'Работы';

  @override
  String get newestFirst => 'новые сверху';

  @override
  String get kindFo => 'ФО';

  @override
  String get kindSor => 'СОР';

  @override
  String get kindSoch => 'СОЧ';

  @override
  String gradeSemantic(String value, String tone) {
    return 'Оценка $value, $tone';
  }

  @override
  String get toneExcellent => 'отлично';

  @override
  String get toneGood => 'хорошо';

  @override
  String get toneFair => 'удовлетворительно';

  @override
  String get tonePoor => 'неудовлетворительно';

  @override
  String get newWord => 'новая';

  @override
  String tasksEyebrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заданий',
      few: '$count задания',
      one: '$count задание',
    );
    return 'На неделе: $_temp0';
  }

  @override
  String get sectionOverdue => 'Просрочено';

  @override
  String get sectionToday => 'Сегодня';

  @override
  String get sectionTomorrow => 'Завтра';

  @override
  String get sectionWeek => 'На этой неделе';

  @override
  String get sectionLater => 'Позже';

  @override
  String sectionDone(int count) {
    return 'Выполнено: $count';
  }

  @override
  String get allSubjects => 'Все';

  @override
  String get markDone => 'Отметить готовым';

  @override
  String get markUndone => 'Вернуть в невыполненные';

  @override
  String get doneToast => 'Задание отмечено готовым';

  @override
  String get undoneToast => 'Задание вернулось в список';

  @override
  String get hwDone => 'сделано';

  @override
  String get hwNotDone => 'не сделано';

  @override
  String dueBy(String date) {
    return 'к $date';
  }

  @override
  String attachmentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вложений',
      few: '$count вложения',
      one: '$count вложение',
    );
    return '$_temp0';
  }

  @override
  String get tasksEmpty => 'Заданий нет';

  @override
  String get tasksEmptyHint => 'Новые задания от учителей появятся здесь';

  @override
  String taskToggleDone(String title) {
    return 'Отметить «$title» готовым';
  }

  @override
  String taskToggleUndone(String title) {
    return 'Вернуть «$title»';
  }

  @override
  String get openFile => 'Открыть файл';

  @override
  String loadToday(int used, int norm) {
    return 'Нагрузка $used из $norm мин';
  }

  @override
  String get verdictOk => 'Всё в порядке';

  @override
  String get verdictQuestion => 'Есть вопрос';

  @override
  String get verdictAction => 'Нужно действие';

  @override
  String get verdictAlarm => 'Не отметился в школе';

  @override
  String get verdictNoLessons => 'Сегодня уроков нет';

  @override
  String verdictUpdated(String time) {
    return 'Данные на $time';
  }

  @override
  String factArrived(String time) {
    return 'В школе с $time.';
  }

  @override
  String factLessons(int done, int total) {
    return '$done из $total уроков.';
  }

  @override
  String factBeforeLessons(String time) {
    return 'Первый урок в $time.';
  }

  @override
  String factAbsent(String subject) {
    return 'Пропущен урок: $subject';
  }

  @override
  String get factNoReason => 'причина не указана.';

  @override
  String factLate(String time) {
    return 'Опоздание: отметка в $time.';
  }

  @override
  String factLowGrade(String subject, String value) {
    return 'Низкая оценка: $subject $value.';
  }

  @override
  String get factExcused => 'Отпрошен(а) на сегодня.';

  @override
  String factAlarm(String time) {
    return 'Первый урок начался в $time. Отметки и заявки нет.';
  }

  @override
  String get factNoConsent => 'Отметка по селфи ждёт вашего разрешения.';

  @override
  String factTomorrow(String lessons, String time) {
    return 'Завтра $lessons с $time.';
  }

  @override
  String factNewGrade(String subject) {
    return 'новая оценка · $subject';
  }

  @override
  String get actExcuse => 'Отпросить';

  @override
  String get actExplain => 'Объяснить пропуск';

  @override
  String get actAllow => 'Разрешить';

  @override
  String get attentionTitle => 'Требует внимания';

  @override
  String attAbsent(String time) {
    return 'Пропуск · $time';
  }

  @override
  String get attNoConsent => 'Отметка по селфи';

  @override
  String get attNoConsentSub => 'Нужно ваше разрешение';

  @override
  String get attRejected => 'Заявка отклонена';

  @override
  String get attPending => 'Заявка на рассмотрении у классрука';

  @override
  String get feedTitle => 'Лента дня';

  @override
  String get feedNewest => 'новое сверху';

  @override
  String get feedArrived => 'Пришёл(ла) в школу';

  @override
  String feedArrivedSub(String state) {
    return 'отметка по селфи · $state';
  }

  @override
  String get feedOnTime => 'вовремя';

  @override
  String get feedLate => 'опоздание';

  @override
  String get feedNow => 'идёт сейчас';

  @override
  String get feedMarkedAbsent => 'отмечен пропуск';

  @override
  String get feedEmpty => 'Пока ничего не произошло';

  @override
  String forTomorrowLine(String tasks, int m, int done) {
    return '$tasks · ≈ $m мин · готово $done';
  }

  @override
  String get familyTitle => 'Семья';

  @override
  String get familyNotChecked => 'не отмечен';

  @override
  String get familyAllGood => 'всё в порядке';

  @override
  String get familyQuestion => 'есть вопрос';

  @override
  String get familyNoLessons => 'нет уроков';

  @override
  String get familyExcuseCard => 'Отпросить ребёнка';

  @override
  String get familyExcuseHint => 'Болезнь, семейные дела, врач — заявка уйдёт классруку';

  @override
  String get requests => 'Заявки';

  @override
  String get reqPending => 'на рассмотрении';

  @override
  String get reqApproved => 'одобрена';

  @override
  String get reqRejected => 'отклонена';

  @override
  String get reqCancelled => 'отозвана';

  @override
  String get reqWithdraw => 'Отозвать заявку';

  @override
  String get reqWithdrawConfirm => 'Отозвать заявку?';

  @override
  String get reqEmpty => 'Заявок пока нет';

  @override
  String get reqEmptyHint => 'Когда отпросите ребёнка, заявка появится здесь';

  @override
  String get catIllness => 'Болезнь';

  @override
  String get catFamily => 'Семейные';

  @override
  String get catAppointment => 'Врач или дела';

  @override
  String get catOther => 'Другое';

  @override
  String excuseTitle(String name) {
    return 'Отпросить: $name';
  }

  @override
  String get excuseWhen => 'Когда';

  @override
  String get excuseDates => 'Даты';

  @override
  String get excuseLessons => 'Уроки';

  @override
  String get excuseFrom => 'С';

  @override
  String get excuseTo => 'По';

  @override
  String get excuseReason => 'Причина';

  @override
  String get excuseComment => 'Комментарий';

  @override
  String get excuseCommentHint => 'Необязательно';

  @override
  String get excuseProof => 'Справка';

  @override
  String get excuseCamera => 'Камера';

  @override
  String get excuseGallery => 'Галерея';

  @override
  String get excuseRemoveProof => 'Убрать справку';

  @override
  String get excuseSend => 'Отправить классруку';

  @override
  String get excuseSent => 'Заявка отправлена';

  @override
  String get excusePickLessons => 'Выберите хотя бы один урок';

  @override
  String get excuseOffline => 'Нет сети. Отправьте, когда появится связь';

  @override
  String get excuseFailed => 'Не получилось отправить заявку';

  @override
  String get consentSheetTitle => 'Разрешить отметку по селфи?';

  @override
  String get consentWho => 'Фото видит только персонал школы';

  @override
  String get consentKeep => 'Удаляется через 30 дней';

  @override
  String get consentWhere => 'Можно отозвать в профиле ребёнка';

  @override
  String consentAllowed(String name) {
    return '$name может отмечаться';
  }

  @override
  String get consentFailed => 'Не получилось сохранить разрешение';

  @override
  String tUntilBell(int m) {
    return 'до звонка $m мин';
  }

  @override
  String tStartsIn(int m) {
    return 'через $m мин';
  }

  @override
  String tFree(int m) {
    return 'окно $m мин';
  }

  @override
  String tStudents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      few: '$count ученика',
      one: '$count ученик',
    );
    return '$_temp0';
  }

  @override
  String get tRollNotDone => 'Перекличка не сделана';

  @override
  String get tRollDone => 'Перекличка сделана';

  @override
  String get tTopicDone => 'тема ✓';

  @override
  String get tCloseDay => 'Закрыть день';

  @override
  String tActions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count действий',
      few: '$count действия',
      one: '$count действие',
    );
    return '$_temp0';
  }

  @override
  String get tDayClosed => 'День закрыт';

  @override
  String get tDayClosedHint => 'Все уроки заполнены';

  @override
  String get tNoLessons => 'Сегодня уроков нет';

  @override
  String get tUnmarked => 'не отмечено';

  @override
  String get tNoTopic => 'без темы';

  @override
  String get tLessons => 'Уроки';

  @override
  String tTodayCount(int count) {
    return '$count сегодня';
  }

  @override
  String get missingAttendance => 'посещаемость';

  @override
  String get missingTopic => 'тема';

  @override
  String get missingHomework => 'ДЗ';

  @override
  String get missingGrades => 'оценки';

  @override
  String tMissingWhat(String what, String lesson) {
    return '$what: $lesson';
  }

  @override
  String get tDebts => 'Долги за 14 дней';

  @override
  String tDebtsUnmarked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков без отметки',
      few: '$count урока без отметки',
      one: '$count урок без отметки',
    );
    return '$_temp0';
  }

  @override
  String get tCloseAll => 'Закрыть все без отсутствующих';

  @override
  String get tCloseAllConfirm => 'Отметить всех присутствующими?';

  @override
  String get tCloseAllBody => 'Только уроки, где отметок ещё нет. Исправить можно потом в уроке';

  @override
  String tAllPresentToast(String cls) {
    return '$cls: все на месте';
  }

  @override
  String get tAllPresent => 'Все на месте';

  @override
  String tLessonRowSemantic(String time, String cls, String subject, String state) {
    return '$time, $cls, $subject. $state';
  }

  @override
  String get tAllFilled => 'всё заполнено';

  @override
  String tJointClasses(String a, String b) {
    return '$a + $b';
  }

  @override
  String get lessonOver => 'урок закончился';

  @override
  String get topicCard => 'Тема урока';

  @override
  String ktpChip(String topic) {
    return 'КТП: $topic';
  }

  @override
  String get sameAsLast => 'Как в прошлый раз';

  @override
  String get topicHint => 'Например: Подобие треугольников';

  @override
  String get topicSaved => 'Тема сохранена';

  @override
  String get presentLabel => 'Присутствуют';

  @override
  String get searchStudent => 'Найти ученика';

  @override
  String get viewList => 'Список';

  @override
  String get viewFaces => 'Лица';

  @override
  String sourceCheckIn(String time) {
    return 'отметился сам · $time';
  }

  @override
  String get sourceCheckInShort => 'отметился сам';

  @override
  String get sourceHomeroom => 'отметка классрука';

  @override
  String lateBy(int m) {
    return 'опоздал на $m мин';
  }

  @override
  String notSaved(String reason) {
    return 'не сохранено: $reason';
  }

  @override
  String get reasonSochShort => 'день СОЧ';

  @override
  String get reasonSoch => 'День СОЧ — отметки не принимаются';

  @override
  String get reasonForbiddenShort => 'нет прав на урок';

  @override
  String get reasonForbidden => 'Нет прав на этот урок';

  @override
  String get reasonNotFound => 'Урок или ученик удалён';

  @override
  String get reasonInvalid => 'Сервер не принял запись';

  @override
  String sochBanner(String subject) {
    return 'Сегодня СОЧ по предмету «$subject».';
  }

  @override
  String get sochBannerBody => 'Текущие оценки и посещаемость не выставляются';

  @override
  String pendingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отметок ждут сети.',
      few: '$count отметки ждут сети.',
      one: '$count отметка ждёт сети.',
    );
    return '$_temp0';
  }

  @override
  String get pendingBannerBody => 'Отправим сами';

  @override
  String rejectedBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записей не сохранено.',
      few: '$count записи не сохранены.',
      one: '$count запись не сохранена.',
    );
    return '$_temp0';
  }

  @override
  String get openQueue => 'Открыть';

  @override
  String get dockHomework => 'ДЗ';

  @override
  String get dockSummary => 'Итог';

  @override
  String dockAllPresent(int count) {
    return 'Все на месте · $count';
  }

  @override
  String dockDone(int n, int m) {
    return 'Готово · $n из $m';
  }

  @override
  String get dockFinish => 'Завершить урок';

  @override
  String get dockSochDay => 'День СОЧ';

  @override
  String get rollSaved => 'Перекличка сохранена';

  @override
  String markedToast(String name, String state) {
    return '$name — $state';
  }

  @override
  String get stateAbsent => 'Н';

  @override
  String get statePresent => 'есть';

  @override
  String get rowPresentHint => 'Двойное касание — отметить отсутствие';

  @override
  String get rowAbsentHint => 'Двойное касание — отметить присутствие';

  @override
  String get actionCodes => 'Коды посещаемости';

  @override
  String codesTitle(String name) {
    return '$name';
  }

  @override
  String get codeLate => 'Опоздал';

  @override
  String get codeLateMinutes => 'На сколько минут';

  @override
  String get codeCustom => 'Своё';

  @override
  String get codeSick => 'Болеет';

  @override
  String get codeExcused => 'Уважительная';

  @override
  String get codePresent => 'Есть';

  @override
  String get codeAbsent => 'Отсутствует';

  @override
  String get lessonStartedToast => 'Урок начат';

  @override
  String padOf(int n, int total) {
    return '$n из $total';
  }

  @override
  String get padComment => 'Комментарий';

  @override
  String get padCommentHint => 'Привяжется к следующей оценке';

  @override
  String padAbsentWarn(String name) {
    return '$name отмечен «Н». Поставить оценку?';
  }

  @override
  String get padPut => 'Поставить';

  @override
  String get padRemoved => 'Оценка снята';

  @override
  String padKey(String v, String tone) {
    return 'Поставить $v, $tone';
  }

  @override
  String padSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get padPrev => 'Предыдущий ученик';

  @override
  String get padNext => 'Следующий ученик';

  @override
  String gradeSlot(String name) {
    return 'Оценка: $name';
  }

  @override
  String get gradeLocked => 'Оценки закрыты';

  @override
  String get scaleViewOnly => 'Эту шкалу выставляют в веб-журнале';

  @override
  String get selectMode => 'Выбор учеников';

  @override
  String get workType => 'Вид работы';

  @override
  String get menuMore => 'Ещё';

  @override
  String get menuGradeAll => 'Оценить всех';

  @override
  String get menuOpenWeb => 'Открыть журнал в вебе';

  @override
  String get menuStart => 'Начать урок';

  @override
  String jointPill(int count) {
    return 'совмещённый · $count';
  }

  @override
  String classHeader(String cls, int count) {
    return '$cls · $count';
  }

  @override
  String get rosterEmpty => 'В классе нет учеников';

  @override
  String hwSheetTitle(String cls) {
    return 'Задание для $cls';
  }

  @override
  String get hwTextHint => 'Параграф 12, номера 3–7';

  @override
  String get hwDue => 'Срок';

  @override
  String hwDueNextLesson(String date) {
    return 'Следующий урок · $date';
  }

  @override
  String get hwTime => 'Время на выполнение';

  @override
  String hwLoad(String day, int used, int norm) {
    return '$day: уже $used из $norm мин';
  }

  @override
  String hwOverNorm(int m) {
    return 'больше нормы на $m мин';
  }

  @override
  String get hwAssign => 'Задать';

  @override
  String hwAssigned(String cls) {
    return 'ДЗ задано · $cls';
  }

  @override
  String get hwExisting => 'Уже задано';

  @override
  String get hwFailed => 'Не получилось задать ДЗ';

  @override
  String get hwOffline => 'Нет сети — задание уйдёт, когда появится связь';

  @override
  String get hwOtherDate => 'Другая дата';

  @override
  String get sumTitle => 'Итог урока';

  @override
  String sumAttendance(int n, int m) {
    return 'Посещаемость · $n из $m';
  }

  @override
  String get sumTopic => 'Тема';

  @override
  String get sumHomework => 'ДЗ';

  @override
  String sumGrades(int count) {
    return 'Оценки · $count';
  }

  @override
  String get sumField => 'Итог урока, необязательно';

  @override
  String get lessonFinishedToast => 'Урок завершён';

  @override
  String get syncTitle => 'Синхронизация';

  @override
  String syncLast(String time) {
    return 'Последняя отправка в $time';
  }

  @override
  String syncRejected(int count) {
    return 'Отклонено · $count';
  }

  @override
  String syncWaiting(int count) {
    return 'Ждут сети · $count';
  }

  @override
  String get syncAllSent => 'Всё отправлено';

  @override
  String get syncAllSentHint => 'Отметки, оценки и темы уже на сервере';

  @override
  String get syncDeleteConfirm => 'Удалить запись?';

  @override
  String get syncDeleteBody => 'Она пропадёт без отправки';

  @override
  String get syncSending => 'Отправляем';

  @override
  String syncPendingN(int count) {
    return 'Ждут отправки: $count';
  }

  @override
  String syncRejectedN(int count) {
    return 'Не сохранено: $count';
  }

  @override
  String whatAttendance(String state) {
    return 'Посещаемость «$state»';
  }

  @override
  String whatGrade(String v) {
    return 'Оценка $v';
  }

  @override
  String get whatGradeRemoved => 'Оценка снята';

  @override
  String get whatTopic => 'Тема урока';

  @override
  String get whatStart => 'Начало урока';

  @override
  String get whatFinish => 'Завершение урока';

  @override
  String get whatHomework => 'Домашнее задание';

  @override
  String whatAllPresent(int count) {
    return 'Все на месте · $count';
  }

  @override
  String get whatSummary => 'Итог урока';

  @override
  String createdAt(String time) {
    return 'создано в $time';
  }

  @override
  String get inboxAction => 'Требует действия';

  @override
  String get inboxSchedule => 'Расписание';

  @override
  String get inboxOther => 'Остальное';

  @override
  String get inboxEmpty => 'Входящих нет';

  @override
  String get inboxEmptyHint => 'Здесь будут уроки без отметки, отклонённые записи, замены и объявления';

  @override
  String get inboxRejected => 'Записи не сохранены';

  @override
  String get inboxRejectedSub => 'Откройте очередь, чтобы повторить или удалить';

  @override
  String inboxExcuses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заявок на отсутствие',
      few: '$count заявки на отсутствие',
      one: '$count заявка на отсутствие',
    );
    return '$_temp0';
  }

  @override
  String get inboxExcusesSub => 'Одобрить или отклонить можно в веб-версии';

  @override
  String get markRead => 'Прочитано';

  @override
  String get markAllRead => 'Прочитать всё';

  @override
  String get notifEmpty => 'Уведомлений нет';

  @override
  String get notifEmptyHint => 'Здесь будут оценки, задания, замены и решения по заявкам';

  @override
  String get notifUnavailable => 'Запись удалена или недоступна';

  @override
  String get notifUnavailableHint => 'Возможно, её изменили в школе. Остальное в приложении работает как обычно';

  @override
  String get ntGradeCreated => 'Новая оценка';

  @override
  String get ntGradeUpdated => 'Оценка изменена';

  @override
  String get ntHomework => 'Домашнее задание';

  @override
  String get ntHomeworkReminder => 'Напоминание о задании';

  @override
  String get ntLessonCancelled => 'Урок отменён';

  @override
  String get ntLessonRescheduled => 'Урок перенесён';

  @override
  String get ntSubstitution => 'Замена';

  @override
  String get ntLessonStarted => 'Урок начался';

  @override
  String get ntCheckIn => 'Ребёнок пришёл в школу';

  @override
  String get ntAttendance => 'Посещаемость';

  @override
  String get ntUnmarked => 'Отметьте посещаемость';

  @override
  String get ntGradesReminder => 'Поставьте оценки';

  @override
  String get ntExcusePending => 'Новая заявка';

  @override
  String get ntExcuseApproved => 'Заявка одобрена';

  @override
  String get ntExcuseRejected => 'Заявка отклонена';

  @override
  String get ntExcuseCancelled => 'Заявка отозвана';

  @override
  String get ntInvoice => 'Счёт на оплату';

  @override
  String get ntEvent => 'Событие школы';

  @override
  String get ntChat => 'Новое сообщение';

  @override
  String get ntOther => 'Уведомление';

  @override
  String get ngGrades => 'Оценки';

  @override
  String get ngHomework => 'Задания';

  @override
  String get ngSchedule => 'Расписание и замены';

  @override
  String get ngAttendance => 'Посещаемость и приход в школу';

  @override
  String get ngChat => 'Сообщения';

  @override
  String get ngBilling => 'Оплата';

  @override
  String get ngGeneral => 'Важное';

  @override
  String get pushAskTitle => 'Включить уведомления?';

  @override
  String get pushAskAllow => 'Включить';

  @override
  String get pushWhyStudent => 'Сразу узнаешь о новой оценке, задании или замене урока.';

  @override
  String get pushWhyParent =>
      'Узнавайте сразу, когда ребёнок пришёл в школу, получил оценку или пропустил урок. Сами оценки на заблокированном экране не показываются.';

  @override
  String get pushWhyTeacher => 'Напомним о неотмеченной посещаемости и сообщим о заменах и новых заявках.';

  @override
  String get notifSettings => 'Уведомления';

  @override
  String get notifSettingsHint => 'В колокольчике приложения видно всё. Здесь — что приходит пушем на телефон.';

  @override
  String get pushOffTitle => 'Уведомления выключены в настройках телефона';

  @override
  String get pushOffOpen => 'Открыть настройки';

  @override
  String get pushTurnOn => 'Включить уведомления';

  @override
  String get pushUnavailable => 'В этой сборке пуши недоступны';

  @override
  String get notifOpen => 'Открыть';

  @override
  String get presenceOnline => 'В сети';

  @override
  String get lockSetting => 'Блокировка приложения';

  @override
  String get lockSettingHint => 'Face ID, отпечаток или код телефона при запуске и после 5 минут в фоне';

  @override
  String get lockReason => 'Подтвердите, что это вы';

  @override
  String get lockTitle => 'GradeApp заблокирован';

  @override
  String get lockUnlock => 'Разблокировать';

  @override
  String get lockUnavailable => 'Включите Face ID, отпечаток или код-пароль в настройках телефона';

  @override
  String reportCardRow(String term) {
    return 'Табель за $term';
  }

  @override
  String get reportCardHint => 'PDF · отправить или сохранить';

  @override
  String get reportCardPreparing => 'Готовим табель…';

  @override
  String get reportCardOffline => 'Нет сети — табель не скачать. Попробуйте, когда появится интернет.';

  @override
  String get reportCardDenied => 'Нет доступа к табелю';

  @override
  String get reportCardFailed => 'Не удалось получить табель. Попробуйте ещё раз.';

  @override
  String get feedbackTitle => 'Отзывы учителей';

  @override
  String get feedbackPraise => 'Похвала';

  @override
  String get feedbackRemark => 'Замечание';

  @override
  String get feedbackAction => 'Отзыв ученику';

  @override
  String feedbackSheetTitle(String name) {
    return 'Отзыв: $name';
  }

  @override
  String get feedbackHint => 'Что получилось или над чем стоит поработать';

  @override
  String get feedbackSend => 'Отправить отзыв';

  @override
  String feedbackSent(String name) {
    return 'Отзыв для $name отправляется';
  }

  @override
  String get whatFeedback => 'Отзыв ученику';

  @override
  String get hwAttachCamera => 'Камера';

  @override
  String get hwAttachPhoto => 'Фото';

  @override
  String get hwAttachFile => 'Файл';

  @override
  String hwRemoveFile(String name) {
    return 'Убрать $name';
  }

  @override
  String hwFileTooBig(String name) {
    return '$name больше 10 МБ — не прикреплён';
  }

  @override
  String hwUploading(int done, int total) {
    return 'Загружаем файлы ($done из $total)…';
  }

  @override
  String hwFilesFailed(int n) {
    return 'Задание выдано, но не загрузились файлы: $n. Прикрепите их позже на сайте.';
  }

  @override
  String get hwFilesOffline =>
      'Нет сети: задание сохранено без файлов и уйдёт позже. Файлы прикрепите, когда появится интернет.';

  @override
  String get hwFilesError => 'Не удалось выдать задание. Попробуйте ещё раз.';

  @override
  String get attachmentOpenFailed => 'Не удалось открыть файл';

  @override
  String get actApprove => 'Одобрить';

  @override
  String get excuseApprovedToast => 'Заявка одобрена';

  @override
  String get excuseApproveFailed => 'Не удалось одобрить заявку';

  @override
  String get liveNow => 'Идёт урок';

  @override
  String liveMarked(int done, int total) {
    return 'Отмечено $done/$total';
  }

  @override
  String get liveEnded => 'Урок закончен';

  @override
  String get liveEndedTopic => 'Урок закончен: не заполнена тема';

  @override
  String get liveUntilBell => 'До звонка';

  @override
  String get notifPublicTitle => 'GradeApp';

  @override
  String get notifPublicBody => 'Новое уведомление';

  @override
  String liveShortMinutes(int n) {
    return '$n мин';
  }

  @override
  String get liveChannel => 'Идёт урок';

  @override
  String get remChannel => 'Напоминания';

  @override
  String remTitle(String cls) {
    return '$cls: посещаемость не отмечена';
  }

  @override
  String remBody(String subject, String start, String end) {
    return '$subject, $start–$end';
  }

  @override
  String get wgNext => 'Следующий урок';

  @override
  String get wgNow => 'Сейчас';

  @override
  String get wgDay => 'День';

  @override
  String wgUpdated(String time) {
    return 'Обновлено $time';
  }

  @override
  String get wgStale => 'Откройте приложение, чтобы обновить';

  @override
  String get wgNoMore => 'Сегодня уроков больше нет';

  @override
  String get wgNoLessons => 'Сегодня уроков нет';

  @override
  String get wgHomeworkTomorrow => 'ДЗ на завтра';

  @override
  String get wgNoHomework => 'На завтра ничего не задано';

  @override
  String get wgSignedOut => 'Войдите в GradeApp';

  @override
  String get wgTomorrow => 'Завтра';

  @override
  String get wgStartsIn => 'Начнётся через';

  @override
  String get wgEndsIn => 'До конца';

  @override
  String get setLocalTitle => 'На этом телефоне';

  @override
  String get setReminders => 'Напоминания об отметке посещаемости';

  @override
  String get setLive => '«Идёт урок» на экране блокировки';

  @override
  String get ntCheckInMissing => 'Не отметился в школе';

  @override
  String get wgNextShort => 'Дальше';

  @override
  String get t6Praise => 'Похвалить';

  @override
  String get t6Remark => 'Замечание';

  @override
  String t6PraiseTitle(String name) {
    return 'Похвала: $name';
  }

  @override
  String t6RemarkTitle(String name) {
    return 'Замечание: $name';
  }

  @override
  String get t6TextHint => 'Пара слов, если нужно (необязательно)';

  @override
  String get t6TagActive => 'Был активен';

  @override
  String get t6TagHelped => 'Помогал другим';

  @override
  String get t6TagProgress => 'Заметный прогресс';

  @override
  String get t6TagGreatAnswer => 'Отличный ответ';

  @override
  String get t6TagLate => 'Опоздал';

  @override
  String get t6TagNoHomework => 'Нет домашнего задания';

  @override
  String get t6TagDistracted => 'Отвлекался';

  @override
  String get t6TagNoMaterials => 'Нет принадлежностей';

  @override
  String get t9Substitution => 'Замена';

  @override
  String t9ForTeacher(String name) {
    return 'за $name';
  }

  @override
  String t9TaughtBy(String name) {
    return 'ведёт $name';
  }

  @override
  String get t12Title => 'Выполнение ДЗ';

  @override
  String t12Done(int done, int total) {
    return 'Выполнили $done из $total';
  }

  @override
  String get t12AllDone => 'Все выполнили';

  @override
  String t12NotDone(int count) {
    return 'Не выполнили: $count';
  }

  @override
  String get t12Remind => 'Напомнить';

  @override
  String t12Reminded(int count) {
    return 'Напоминание получили $count';
  }

  @override
  String get t12TooSoon => 'Можно раз в час';

  @override
  String get t12RemindFailed => 'Не удалось отправить напоминание';

  @override
  String get t12Loading => 'Считаем, кто сделал…';

  @override
  String get t12Open => 'Кто сделал';

  @override
  String get t8Tab => 'Мой класс';

  @override
  String t8Came(int came, int total) {
    return 'Пришли $came из $total';
  }

  @override
  String t8Unmarked(int count) {
    return 'Без отметки: $count';
  }

  @override
  String get t8AllMarked => 'Все отмечены';

  @override
  String t8NextLesson(String subject, String time) {
    return 'Дальше: $subject в $time';
  }

  @override
  String get t8RollCall => 'Утренняя отметка';

  @override
  String get t8MarkClass => 'Отметить класс за день';

  @override
  String get t8AllCame => 'Все пришли';

  @override
  String get t8MarkSent => 'Отметка класса отправляется';

  @override
  String get t8SourceExcuse => 'По заявке';

  @override
  String get t8SourcePending => 'Есть заявка';

  @override
  String get t8Requests => 'Заявки на отсутствие';

  @override
  String get t8Approve => 'Одобрить';

  @override
  String get t8Reject => 'Отклонить';

  @override
  String get t8RejectTitle => 'Почему отклоняете?';

  @override
  String get t8RejectHint => 'Родитель увидит это сообщение';

  @override
  String get t8RejectSend => 'Отклонить заявку';

  @override
  String get t8Approved => 'Заявка одобрена';

  @override
  String get t8Rejected => 'Заявка отклонена';

  @override
  String get t8ReviewFailed => 'Не удалось отправить решение';

  @override
  String get t8Photo => 'Фото к заявке';

  @override
  String t8From(String name) {
    return 'Подала: $name';
  }

  @override
  String get t8Week => 'Неделя класса';

  @override
  String t8WeekRate(String rate) {
    return 'Посещаемость $rate%';
  }

  @override
  String t8WeekAbsent(int count) {
    return 'Пропусков: $count';
  }

  @override
  String t8WeekTardy(int count) {
    return 'Опозданий: $count';
  }

  @override
  String get t8AtRisk => 'В зоне риска';

  @override
  String get t8AtRiskNone => 'Никого в зоне риска';

  @override
  String get t8OpenWeb => 'Открыть в вебе';

  @override
  String get t8Empty => 'В классе нет учеников';

  @override
  String get t8NotHomeroom => 'Раздел для классных руководителей';

  @override
  String get t8InboxSub => 'Одобрить можно в разделе «Мой класс»';

  @override
  String t8WhatDay(int count) {
    return 'Отметка класса за день: $count';
  }

  @override
  String t8ClassPick(String name) {
    return 'Класс $name';
  }

  @override
  String wgChildIn(String time) {
    return 'В школе с $time';
  }

  @override
  String get wgChildInNoTime => 'В школе';

  @override
  String get wgChildNotYet => 'Ещё нет отметки';

  @override
  String wgChildNewGrades(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count новых оценок',
      few: '$count новые оценки',
      one: '$count новая оценка',
    );
    return '$_temp0';
  }

  @override
  String get wgChildNoNew => 'Новых оценок нет';

  @override
  String get wgChildAbsent => 'Не в школе';
}
