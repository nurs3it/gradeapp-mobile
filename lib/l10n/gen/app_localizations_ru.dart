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
  String get loginTitle => 'Вход в GradeApp';

  @override
  String get loginSubtitle => 'Используйте почту и пароль от школьного аккаунта';

  @override
  String get email => 'Почта';

  @override
  String get password => 'Пароль';

  @override
  String get otpCode => 'Код из приложения-аутентификатора';

  @override
  String get otpHint => '6 цифр';

  @override
  String get signIn => 'Войти';

  @override
  String get loginInvalid => 'Неверная почта или пароль';

  @override
  String get loginOtpInvalid => 'Неверный код';

  @override
  String get loginNoRole => 'В мобильном приложении пока доступны кабинеты ученика, родителя и учителя';

  @override
  String get signOut => 'Выйти';

  @override
  String get errorTitle => 'Не удалось загрузить';

  @override
  String get errorMessage => 'Проверьте интернет и попробуйте ещё раз';

  @override
  String get retry => 'Повторить';

  @override
  String get offlineSaved => 'Сохранено на телефоне — отправим, когда появится сеть';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count изменений ждут отправки',
      few: '$count изменения ждут отправки',
      one: '$count изменение ждёт отправки',
    );
    return '$_temp0';
  }

  @override
  String get syncRejected => 'Сервер не принял изменение. Проверьте и отметьте ещё раз';

  @override
  String get synced => 'Всё отправлено';

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabSchedule => 'Расписание';

  @override
  String get tabGrades => 'Оценки';

  @override
  String get tabHomework => 'Задания';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get tabLessons => 'Уроки';

  @override
  String get now => 'Сейчас';

  @override
  String get next => 'Далее';

  @override
  String greetingMorning(String name) {
    return 'Доброе утро, $name';
  }

  @override
  String greetingDay(String name) {
    return 'Добрый день, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Добрый вечер, $name';
  }

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
  String get noLessonsTitle => 'Уроков нет';

  @override
  String get noLessonsMessage => 'В этот день занятий нет';

  @override
  String room(String room) {
    return 'каб. $room';
  }

  @override
  String lessonEndsIn(int minutes) {
    return 'Закончится через $minutes мин';
  }

  @override
  String lessonStartsIn(int minutes) {
    return 'Начнётся через $minutes мин';
  }

  @override
  String get dayDone => 'Уроки на сегодня закончились';

  @override
  String get presencePresent => 'Был';

  @override
  String get presenceAbsent => 'Н/Б';

  @override
  String get presenceTardy => 'Опоздал';

  @override
  String get presenceExcused => 'Уваж.';

  @override
  String get presenceAbsentLong => 'Отсутствовал';

  @override
  String get presenceExcusedLong => 'Уважительная причина';

  @override
  String get checkInTitle => 'Я в школе';

  @override
  String get checkInAction => 'Отметиться';

  @override
  String get checkInHint => 'Сделайте селфи у входа — учитель увидит, что вы пришли';

  @override
  String checkInDone(String time) {
    return 'Отмечен в $time';
  }

  @override
  String get checkInLate => 'Опоздание';

  @override
  String checkInWindow(String from, String to) {
    return 'Отметиться можно с $from до $to';
  }

  @override
  String get checkInNoConsent => 'Родитель ещё не дал согласие на фото-отметку';

  @override
  String get checkInSending => 'Отправляем…';

  @override
  String get checkInSuccess => 'Готово, вы отмечены';

  @override
  String get checkInLocationDenied => 'Разрешите доступ к геопозиции — школа проверяет, что вы на месте';

  @override
  String checkInOutside(int meters) {
    return 'Вы вне территории школы ($meters м)';
  }

  @override
  String get checkInStale => 'Нужно новое фото, сделанное сейчас';

  @override
  String get checkInAlready => 'Вы уже отметились сегодня';

  @override
  String get checkInClosed => 'Окно отметки закрыто';

  @override
  String childCheckedIn(String time) {
    return 'Пришёл в школу в $time';
  }

  @override
  String get childNotCheckedIn => 'Ещё не отметился в школе';

  @override
  String get homeworkDue => 'Задания';

  @override
  String get homeworkEmptyTitle => 'Заданий нет';

  @override
  String get homeworkEmptyMessage => 'Новые задания появятся здесь';

  @override
  String get homeworkActive => 'Актуальные';

  @override
  String get homeworkDoneTab => 'Выполненные';

  @override
  String homeworkMinutes(int minutes) {
    return '≈ $minutes мин';
  }

  @override
  String get dueToday => 'Сдать сегодня';

  @override
  String get dueTomorrow => 'Сдать завтра';

  @override
  String dueOn(String date) {
    return 'Сдать до $date';
  }

  @override
  String get overdue => 'Просрочено';

  @override
  String get attachments => 'Файлы';

  @override
  String get markDone => 'Отметить выполненным';

  @override
  String get markUndone => 'Вернуть в актуальные';

  @override
  String get recentGrades => 'Последние оценки';

  @override
  String get gradesEmptyTitle => 'Оценок пока нет';

  @override
  String get gradesEmptyMessage => 'Здесь появятся оценки по всем предметам';

  @override
  String get average => 'Средний';

  @override
  String gradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count оценок',
      few: '$count оценки',
      one: '$count оценка',
    );
    return '$_temp0';
  }

  @override
  String get all => 'Все';

  @override
  String get weekPrev => 'Предыдущая неделя';

  @override
  String get weekNext => 'Следующая неделя';

  @override
  String get today => 'Сегодня';

  @override
  String get profileChildren => 'Дети';

  @override
  String get photoConsent => 'Фото-отметка «Я в школе»';

  @override
  String get photoConsentHint => 'Ребёнок сможет отмечаться селфи при входе';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeAuto => 'Авто';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get role => 'Кабинет';

  @override
  String get roleTeacher => 'Учитель';

  @override
  String get roleParent => 'Родитель';

  @override
  String get roleStudent => 'Ученик';

  @override
  String get signOutConfirm => 'Выйти из аккаунта?';

  @override
  String get cancel => 'Отмена';

  @override
  String get noChildrenTitle => 'Дети не привязаны';

  @override
  String get noChildrenMessage => 'Попросите школу привязать ребёнка к вашему аккаунту';

  @override
  String get teacherTodayEmpty => 'Сегодня уроков нет';

  @override
  String get overdueTitle => 'Не заполнено';

  @override
  String get overdueHint => 'Уроки за последние две недели без отметок или темы';

  @override
  String get missingAttendance => 'Посещаемость';

  @override
  String get missingTopic => 'Тема';

  @override
  String get missingHomework => 'ДЗ';

  @override
  String get missingGrades => 'Оценки';

  @override
  String get allFilled => 'Всё заполнено';

  @override
  String get lessonStart => 'Начать урок';

  @override
  String get lessonFinish => 'Завершить урок';

  @override
  String get lessonFinished => 'Урок завершён';

  @override
  String get lessonCancelled => 'Урок отменён';

  @override
  String get topic => 'Тема урока';

  @override
  String get topicHint => 'Например: Квадратные уравнения';

  @override
  String get allPresent => 'Все на месте';

  @override
  String presentCount(int present, int total) {
    return 'Присутствуют $present из $total';
  }

  @override
  String get fromCheckIn => 'Отметился сам';

  @override
  String get fromHomeroom => 'Отметка классрука';

  @override
  String get workType => 'Вид работы';

  @override
  String gradeFor(String name) {
    return 'Оценка: $name';
  }

  @override
  String get removeGrade => 'Убрать';

  @override
  String gradeAbsentWarn(String name) {
    return '$name отсутствует. Всё равно поставить оценку?';
  }

  @override
  String get rosterEmpty => 'В классе нет учеников';

  @override
  String get autoNext => 'Сразу к следующему';

  @override
  String get done => 'Готово';

  @override
  String get attendanceCodes => 'Код посещаемости';

  @override
  String get save => 'Сохранить';
}
