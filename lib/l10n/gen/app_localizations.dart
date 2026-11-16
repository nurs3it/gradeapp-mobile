import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('kk'), Locale('ru')];

  /// No description provided for @appName.
  ///
  /// In ru, this message translates to:
  /// **'GradeApp'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход в GradeApp'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Используйте почту и пароль от школьного аккаунта'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @otpCode.
  ///
  /// In ru, this message translates to:
  /// **'Код из приложения-аутентификатора'**
  String get otpCode;

  /// No description provided for @otpHint.
  ///
  /// In ru, this message translates to:
  /// **'6 цифр'**
  String get otpHint;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @loginInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверная почта или пароль'**
  String get loginInvalid;

  /// No description provided for @loginOtpInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код'**
  String get loginOtpInvalid;

  /// No description provided for @loginNoRole.
  ///
  /// In ru, this message translates to:
  /// **'В мобильном приложении пока доступны кабинеты ученика, родителя и учителя'**
  String get loginNoRole;

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @errorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте интернет и попробуйте ещё раз'**
  String get errorMessage;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @offlineSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено на телефоне — отправим, когда появится сеть'**
  String get offlineSaved;

  /// No description provided for @syncPending.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} изменение ждёт отправки} few{{count} изменения ждут отправки} other{{count} изменений ждут отправки}}'**
  String syncPending(int count);

  /// No description provided for @syncRejected.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не принял изменение. Проверьте и отметьте ещё раз'**
  String get syncRejected;

  /// No description provided for @synced.
  ///
  /// In ru, this message translates to:
  /// **'Всё отправлено'**
  String get synced;

  /// No description provided for @tabToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get tabToday;

  /// No description provided for @tabSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get tabSchedule;

  /// No description provided for @tabGrades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки'**
  String get tabGrades;

  /// No description provided for @tabHomework.
  ///
  /// In ru, this message translates to:
  /// **'Задания'**
  String get tabHomework;

  /// No description provided for @tabProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get tabProfile;

  /// No description provided for @tabLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get tabLessons;

  /// No description provided for @now.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get now;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @greetingMorning.
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingDay.
  ///
  /// In ru, this message translates to:
  /// **'Добрый день, {name}'**
  String greetingDay(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер, {name}'**
  String greetingEvening(String name);

  /// No description provided for @lessonsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Уроков нет} one{{count} урок} few{{count} урока} other{{count} уроков}}'**
  String lessonsCount(int count);

  /// No description provided for @noLessonsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уроков нет'**
  String get noLessonsTitle;

  /// No description provided for @noLessonsMessage.
  ///
  /// In ru, this message translates to:
  /// **'В этот день занятий нет'**
  String get noLessonsMessage;

  /// No description provided for @room.
  ///
  /// In ru, this message translates to:
  /// **'каб. {room}'**
  String room(String room);

  /// No description provided for @lessonEndsIn.
  ///
  /// In ru, this message translates to:
  /// **'Закончится через {minutes} мин'**
  String lessonEndsIn(int minutes);

  /// No description provided for @lessonStartsIn.
  ///
  /// In ru, this message translates to:
  /// **'Начнётся через {minutes} мин'**
  String lessonStartsIn(int minutes);

  /// No description provided for @dayDone.
  ///
  /// In ru, this message translates to:
  /// **'Уроки на сегодня закончились'**
  String get dayDone;

  /// No description provided for @presencePresent.
  ///
  /// In ru, this message translates to:
  /// **'Был'**
  String get presencePresent;

  /// No description provided for @presenceAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Н/Б'**
  String get presenceAbsent;

  /// No description provided for @presenceTardy.
  ///
  /// In ru, this message translates to:
  /// **'Опоздал'**
  String get presenceTardy;

  /// No description provided for @presenceExcused.
  ///
  /// In ru, this message translates to:
  /// **'Уваж.'**
  String get presenceExcused;

  /// No description provided for @presenceAbsentLong.
  ///
  /// In ru, this message translates to:
  /// **'Отсутствовал'**
  String get presenceAbsentLong;

  /// No description provided for @presenceExcusedLong.
  ///
  /// In ru, this message translates to:
  /// **'Уважительная причина'**
  String get presenceExcusedLong;

  /// No description provided for @checkInTitle.
  ///
  /// In ru, this message translates to:
  /// **'Я в школе'**
  String get checkInTitle;

  /// No description provided for @checkInAction.
  ///
  /// In ru, this message translates to:
  /// **'Отметиться'**
  String get checkInAction;

  /// No description provided for @checkInHint.
  ///
  /// In ru, this message translates to:
  /// **'Сделайте селфи у входа — учитель увидит, что вы пришли'**
  String get checkInHint;

  /// No description provided for @checkInDone.
  ///
  /// In ru, this message translates to:
  /// **'Отмечен в {time}'**
  String checkInDone(String time);

  /// No description provided for @checkInLate.
  ///
  /// In ru, this message translates to:
  /// **'Опоздание'**
  String get checkInLate;

  /// No description provided for @checkInWindow.
  ///
  /// In ru, this message translates to:
  /// **'Отметиться можно с {from} до {to}'**
  String checkInWindow(String from, String to);

  /// No description provided for @checkInNoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Родитель ещё не дал согласие на фото-отметку'**
  String get checkInNoConsent;

  /// No description provided for @checkInSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем…'**
  String get checkInSending;

  /// No description provided for @checkInSuccess.
  ///
  /// In ru, this message translates to:
  /// **'Готово, вы отмечены'**
  String get checkInSuccess;

  /// No description provided for @checkInLocationDenied.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите доступ к геопозиции — школа проверяет, что вы на месте'**
  String get checkInLocationDenied;

  /// No description provided for @checkInOutside.
  ///
  /// In ru, this message translates to:
  /// **'Вы вне территории школы ({meters} м)'**
  String checkInOutside(int meters);

  /// No description provided for @checkInStale.
  ///
  /// In ru, this message translates to:
  /// **'Нужно новое фото, сделанное сейчас'**
  String get checkInStale;

  /// No description provided for @checkInAlready.
  ///
  /// In ru, this message translates to:
  /// **'Вы уже отметились сегодня'**
  String get checkInAlready;

  /// No description provided for @checkInClosed.
  ///
  /// In ru, this message translates to:
  /// **'Окно отметки закрыто'**
  String get checkInClosed;

  /// No description provided for @childCheckedIn.
  ///
  /// In ru, this message translates to:
  /// **'Пришёл в школу в {time}'**
  String childCheckedIn(String time);

  /// No description provided for @childNotCheckedIn.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не отметился в школе'**
  String get childNotCheckedIn;

  /// No description provided for @homeworkDue.
  ///
  /// In ru, this message translates to:
  /// **'Задания'**
  String get homeworkDue;

  /// No description provided for @homeworkEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заданий нет'**
  String get homeworkEmptyTitle;

  /// No description provided for @homeworkEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Новые задания появятся здесь'**
  String get homeworkEmptyMessage;

  /// No description provided for @homeworkActive.
  ///
  /// In ru, this message translates to:
  /// **'Актуальные'**
  String get homeworkActive;

  /// No description provided for @homeworkDoneTab.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные'**
  String get homeworkDoneTab;

  /// No description provided for @homeworkMinutes.
  ///
  /// In ru, this message translates to:
  /// **'≈ {minutes} мин'**
  String homeworkMinutes(int minutes);

  /// No description provided for @dueToday.
  ///
  /// In ru, this message translates to:
  /// **'Сдать сегодня'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Сдать завтра'**
  String get dueTomorrow;

  /// No description provided for @dueOn.
  ///
  /// In ru, this message translates to:
  /// **'Сдать до {date}'**
  String dueOn(String date);

  /// No description provided for @overdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get overdue;

  /// No description provided for @attachments.
  ///
  /// In ru, this message translates to:
  /// **'Файлы'**
  String get attachments;

  /// No description provided for @markDone.
  ///
  /// In ru, this message translates to:
  /// **'Отметить выполненным'**
  String get markDone;

  /// No description provided for @markUndone.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть в актуальные'**
  String get markUndone;

  /// No description provided for @recentGrades.
  ///
  /// In ru, this message translates to:
  /// **'Последние оценки'**
  String get recentGrades;

  /// No description provided for @gradesEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оценок пока нет'**
  String get gradesEmptyTitle;

  /// No description provided for @gradesEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся оценки по всем предметам'**
  String get gradesEmptyMessage;

  /// No description provided for @average.
  ///
  /// In ru, this message translates to:
  /// **'Средний'**
  String get average;

  /// No description provided for @gradesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} оценка} few{{count} оценки} other{{count} оценок}}'**
  String gradesCount(int count);

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @weekPrev.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущая неделя'**
  String get weekPrev;

  /// No description provided for @weekNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующая неделя'**
  String get weekNext;

  /// No description provided for @today.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// No description provided for @profileChildren.
  ///
  /// In ru, this message translates to:
  /// **'Дети'**
  String get profileChildren;

  /// No description provided for @photoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Фото-отметка «Я в школе»'**
  String get photoConsent;

  /// No description provided for @photoConsentHint.
  ///
  /// In ru, this message translates to:
  /// **'Ребёнок сможет отмечаться селфи при входе'**
  String get photoConsentHint;

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @role.
  ///
  /// In ru, this message translates to:
  /// **'Кабинет'**
  String get role;

  /// No description provided for @roleTeacher.
  ///
  /// In ru, this message translates to:
  /// **'Учитель'**
  String get roleTeacher;

  /// No description provided for @roleParent.
  ///
  /// In ru, this message translates to:
  /// **'Родитель'**
  String get roleParent;

  /// No description provided for @roleStudent.
  ///
  /// In ru, this message translates to:
  /// **'Ученик'**
  String get roleStudent;

  /// No description provided for @signOutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @noChildrenTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дети не привязаны'**
  String get noChildrenTitle;

  /// No description provided for @noChildrenMessage.
  ///
  /// In ru, this message translates to:
  /// **'Попросите школу привязать ребёнка к вашему аккаунту'**
  String get noChildrenMessage;

  /// No description provided for @teacherTodayEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков нет'**
  String get teacherTodayEmpty;

  /// No description provided for @overdueTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не заполнено'**
  String get overdueTitle;

  /// No description provided for @overdueHint.
  ///
  /// In ru, this message translates to:
  /// **'Уроки за последние две недели без отметок или темы'**
  String get overdueHint;

  /// No description provided for @missingAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость'**
  String get missingAttendance;

  /// No description provided for @missingTopic.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get missingTopic;

  /// No description provided for @missingHomework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ'**
  String get missingHomework;

  /// No description provided for @missingGrades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки'**
  String get missingGrades;

  /// No description provided for @allFilled.
  ///
  /// In ru, this message translates to:
  /// **'Всё заполнено'**
  String get allFilled;

  /// No description provided for @lessonStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать урок'**
  String get lessonStart;

  /// No description provided for @lessonFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить урок'**
  String get lessonFinish;

  /// No description provided for @lessonFinished.
  ///
  /// In ru, this message translates to:
  /// **'Урок завершён'**
  String get lessonFinished;

  /// No description provided for @lessonCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Урок отменён'**
  String get lessonCancelled;

  /// No description provided for @topic.
  ///
  /// In ru, this message translates to:
  /// **'Тема урока'**
  String get topic;

  /// No description provided for @topicHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Квадратные уравнения'**
  String get topicHint;

  /// No description provided for @allPresent.
  ///
  /// In ru, this message translates to:
  /// **'Все на месте'**
  String get allPresent;

  /// No description provided for @presentCount.
  ///
  /// In ru, this message translates to:
  /// **'Присутствуют {present} из {total}'**
  String presentCount(int present, int total);

  /// No description provided for @fromCheckIn.
  ///
  /// In ru, this message translates to:
  /// **'Отметился сам'**
  String get fromCheckIn;

  /// No description provided for @fromHomeroom.
  ///
  /// In ru, this message translates to:
  /// **'Отметка классрука'**
  String get fromHomeroom;

  /// No description provided for @workType.
  ///
  /// In ru, this message translates to:
  /// **'Вид работы'**
  String get workType;

  /// No description provided for @gradeFor.
  ///
  /// In ru, this message translates to:
  /// **'Оценка: {name}'**
  String gradeFor(String name);

  /// No description provided for @removeGrade.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get removeGrade;

  /// No description provided for @gradeAbsentWarn.
  ///
  /// In ru, this message translates to:
  /// **'{name} отсутствует. Всё равно поставить оценку?'**
  String gradeAbsentWarn(String name);

  /// No description provided for @rosterEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В классе нет учеников'**
  String get rosterEmpty;

  /// No description provided for @autoNext.
  ///
  /// In ru, this message translates to:
  /// **'Сразу к следующему'**
  String get autoNext;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @attendanceCodes.
  ///
  /// In ru, this message translates to:
  /// **'Код посещаемости'**
  String get attendanceCodes;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
