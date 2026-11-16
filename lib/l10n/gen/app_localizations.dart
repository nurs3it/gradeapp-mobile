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

  /// No description provided for @tabToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get tabToday;

  /// No description provided for @tabWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get tabWeek;

  /// No description provided for @tabGrades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки'**
  String get tabGrades;

  /// No description provided for @tabTasks.
  ///
  /// In ru, this message translates to:
  /// **'Задания'**
  String get tabTasks;

  /// No description provided for @tabFamily.
  ///
  /// In ru, this message translates to:
  /// **'Семья'**
  String get tabFamily;

  /// No description provided for @tabInbox.
  ///
  /// In ru, this message translates to:
  /// **'Входящие'**
  String get tabInbox;

  /// No description provided for @tabWithBadge.
  ///
  /// In ru, this message translates to:
  /// **'{tab}, новых: {count}'**
  String tabWithBadge(String tab, int count);

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @close.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// No description provided for @undo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get undo;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// No description provided for @skip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get skip;

  /// No description provided for @notNow.
  ///
  /// In ru, this message translates to:
  /// **'Не сейчас'**
  String get notNow;

  /// No description provided for @continueAction.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continueAction;

  /// No description provided for @change.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get change;

  /// No description provided for @add.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// No description provided for @openSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get openSettings;

  /// No description provided for @send.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get send;

  /// No description provided for @errorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось загрузить'**
  String get errorTitle;

  /// No description provided for @errorOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Проверьте интернет и повторите'**
  String get errorOffline;

  /// No description provided for @errorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так. Попробуйте ещё раз'**
  String get errorGeneric;

  /// No description provided for @offlineBar.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Показаны данные от {time}'**
  String offlineBar(String time);

  /// No description provided for @offlineBarNoTime.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Показаны сохранённые данные'**
  String get offlineBarNoTime;

  /// No description provided for @updatedAt.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено в {time}'**
  String updatedAt(String time);

  /// No description provided for @minutesShort.
  ///
  /// In ru, this message translates to:
  /// **'{m} мин'**
  String minutesShort(int m);

  /// No description provided for @approxMinutes.
  ///
  /// In ru, this message translates to:
  /// **'≈ {m} мин'**
  String approxMinutes(int m);

  /// No description provided for @inMinutes.
  ///
  /// In ru, this message translates to:
  /// **'через {m} мин'**
  String inMinutes(int m);

  /// No description provided for @room.
  ///
  /// In ru, this message translates to:
  /// **'каб. {room}'**
  String room(String room);

  /// No description provided for @nOfM.
  ///
  /// In ru, this message translates to:
  /// **'{n} из {m}'**
  String nOfM(int n, int m);

  /// No description provided for @yesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get tomorrow;

  /// No description provided for @todayWord.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get todayWord;

  /// No description provided for @lessonsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Уроков нет} one{{count} урок} few{{count} урока} other{{count} уроков}}'**
  String lessonsCount(int count);

  /// No description provided for @tasksCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} задание} few{{count} задания} other{{count} заданий}}'**
  String tasksCount(int count);

  /// No description provided for @tasksUnit.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{задание} few{задания} other{заданий}}'**
  String tasksUnit(int count);

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

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @notificationsUnread.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления, непрочитанных: {count}'**
  String notificationsUnread(int count);

  /// No description provided for @profile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// No description provided for @switchChild.
  ///
  /// In ru, this message translates to:
  /// **'Сменить ребёнка, сейчас {name}'**
  String switchChild(String name);

  /// No description provided for @profileSchools.
  ///
  /// In ru, this message translates to:
  /// **'Школы'**
  String get profileSchools;

  /// No description provided for @profileChildren.
  ///
  /// In ru, this message translates to:
  /// **'Дети'**
  String get profileChildren;

  /// No description provided for @settingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settingsNotifications;

  /// No description provided for @settingsLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлое'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмное'**
  String get themeDark;

  /// No description provided for @langSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get langSystem;

  /// No description provided for @langKk.
  ///
  /// In ru, this message translates to:
  /// **'Қазақша'**
  String get langKk;

  /// No description provided for @langRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get langRu;

  /// No description provided for @langEn.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @openWeb.
  ///
  /// In ru, this message translates to:
  /// **'Открыть веб-версию'**
  String get openWeb;

  /// No description provided for @about.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {v}'**
  String version(String v);

  /// No description provided for @signOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get signOutConfirm;

  /// No description provided for @signOutPending.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись не отправлена} few{{count} записи не отправлены} other{{count} записей не отправлено}}. Если выйти, они пропадут'**
  String signOutPending(int count);

  /// No description provided for @signOutSendFirst.
  ///
  /// In ru, this message translates to:
  /// **'Отправить и выйти'**
  String get signOutSendFirst;

  /// No description provided for @signOutAnyway.
  ///
  /// In ru, this message translates to:
  /// **'Выйти без отправки'**
  String get signOutAnyway;

  /// No description provided for @signOutWaitNet.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети — записи ещё не ушли'**
  String get signOutWaitNet;

  /// No description provided for @photoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Отметка по селфи'**
  String get photoConsent;

  /// No description provided for @consentOn.
  ///
  /// In ru, this message translates to:
  /// **'разрешена'**
  String get consentOn;

  /// No description provided for @consentOff.
  ///
  /// In ru, this message translates to:
  /// **'не разрешена'**
  String get consentOff;

  /// No description provided for @consentRevoke.
  ///
  /// In ru, this message translates to:
  /// **'Запретить отметку по селфи?'**
  String get consentRevoke;

  /// No description provided for @consentRevokeBody.
  ///
  /// In ru, this message translates to:
  /// **'Ребёнок не сможет отмечаться «Я в школе» по фото'**
  String get consentRevokeBody;

  /// No description provided for @consentRevokeAction.
  ///
  /// In ru, this message translates to:
  /// **'Запретить'**
  String get consentRevokeAction;

  /// No description provided for @switchSchoolFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось сменить школу'**
  String get switchSchoolFailed;

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

  /// No description provided for @allFamily.
  ///
  /// In ru, this message translates to:
  /// **'Вся семья'**
  String get allFamily;

  /// No description provided for @className.
  ///
  /// In ru, this message translates to:
  /// **'класс {name}'**
  String className(String name);

  /// No description provided for @loginTagline.
  ///
  /// In ru, this message translates to:
  /// **'Расписание, оценки и журнал школы — в одном приложении'**
  String get loginTagline;

  /// No description provided for @loginHow.
  ///
  /// In ru, this message translates to:
  /// **'Как вы войдёте?'**
  String get loginHow;

  /// No description provided for @loginWithPassword.
  ///
  /// In ru, this message translates to:
  /// **'Логин и пароль'**
  String get loginWithPassword;

  /// No description provided for @loginWithPasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'Почта или логин, который дала школа'**
  String get loginWithPasswordHint;

  /// No description provided for @loginWithCode.
  ///
  /// In ru, this message translates to:
  /// **'Код из школы'**
  String get loginWithCode;

  /// No description provided for @loginWithCodeHint.
  ///
  /// In ru, this message translates to:
  /// **'Листок с кодом вида ABCDE-12345'**
  String get loginWithCodeHint;

  /// No description provided for @loginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get loginTitle;

  /// No description provided for @loginField.
  ///
  /// In ru, this message translates to:
  /// **'Почта или логин'**
  String get loginField;

  /// No description provided for @password.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get signIn;

  /// No description provided for @loginInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный логин или пароль'**
  String get loginInvalid;

  /// No description provided for @loginBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт заблокирован — обратитесь в школу'**
  String get loginBlocked;

  /// No description provided for @loginThrottled.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Подождите минуту'**
  String get loginThrottled;

  /// No description provided for @loginNoRole.
  ///
  /// In ru, this message translates to:
  /// **'В приложении пока есть кабинеты ученика, родителя и учителя'**
  String get loginNoRole;

  /// No description provided for @otpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Код подтверждения'**
  String get otpTitle;

  /// No description provided for @otpHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите 6 цифр из приложения-аутентификатора'**
  String get otpHint;

  /// No description provided for @otpInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код'**
  String get otpInvalid;

  /// No description provided for @resetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить пароль'**
  String get resetTitle;

  /// No description provided for @resetHint.
  ///
  /// In ru, this message translates to:
  /// **'Пришлём на почту ссылку, чтобы задать новый пароль'**
  String get resetHint;

  /// No description provided for @resetEmail.
  ///
  /// In ru, this message translates to:
  /// **'Почта'**
  String get resetEmail;

  /// No description provided for @resetSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить ссылку'**
  String get resetSend;

  /// No description provided for @resetSentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте почту'**
  String get resetSentTitle;

  /// No description provided for @resetSentBody.
  ///
  /// In ru, this message translates to:
  /// **'Если адрес {email} есть в GradeApp, на него придёт письмо со ссылкой'**
  String resetSentBody(String email);

  /// No description provided for @resetOtherEmail.
  ///
  /// In ru, this message translates to:
  /// **'Ввести другой адрес'**
  String get resetOtherEmail;

  /// No description provided for @codeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Код из школы'**
  String get codeTitle;

  /// No description provided for @codeHint.
  ///
  /// In ru, this message translates to:
  /// **'Код напечатан на листке, который выдала школа'**
  String get codeHint;

  /// No description provided for @codeInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Код не найден или уже использован'**
  String get codeInvalid;

  /// No description provided for @codeIncomplete.
  ///
  /// In ru, this message translates to:
  /// **'В коде 10 знаков'**
  String get codeIncomplete;

  /// No description provided for @codePasswordTitle.
  ///
  /// In ru, this message translates to:
  /// **'Придумайте пароль'**
  String get codePasswordTitle;

  /// No description provided for @codePasswordHint.
  ///
  /// In ru, this message translates to:
  /// **'С ним вы будете входить в приложение и на сайт'**
  String get codePasswordHint;

  /// No description provided for @codePwLength.
  ///
  /// In ru, this message translates to:
  /// **'Не короче 8 знаков'**
  String get codePwLength;

  /// No description provided for @codePwMixed.
  ///
  /// In ru, this message translates to:
  /// **'Есть буквы и цифры'**
  String get codePwMixed;

  /// No description provided for @codePwMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли совпадают'**
  String get codePwMatch;

  /// No description provided for @codePwRepeat.
  ///
  /// In ru, this message translates to:
  /// **'Повторите пароль'**
  String get codePwRepeat;

  /// No description provided for @codeLoginTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ваш логин'**
  String get codeLoginTitle;

  /// No description provided for @codeLoginHint.
  ///
  /// In ru, this message translates to:
  /// **'Им можно войти и в веб-версии'**
  String get codeLoginHint;

  /// No description provided for @copy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied;

  /// No description provided for @stepOf.
  ///
  /// In ru, this message translates to:
  /// **'Шаг {step} из {total}'**
  String stepOf(int step, int total);

  /// No description provided for @heroNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get heroNow;

  /// No description provided for @heroNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get heroNext;

  /// No description provided for @heroLessonN.
  ///
  /// In ru, this message translates to:
  /// **'{n}-й урок'**
  String heroLessonN(int n);

  /// No description provided for @heroLast.
  ///
  /// In ru, this message translates to:
  /// **'последний'**
  String get heroLast;

  /// No description provided for @heroPause.
  ///
  /// In ru, this message translates to:
  /// **'Перемена'**
  String get heroPause;

  /// No description provided for @heroPauseNext.
  ///
  /// In ru, this message translates to:
  /// **'следующий'**
  String get heroPauseNext;

  /// No description provided for @heroUntilBell.
  ///
  /// In ru, this message translates to:
  /// **'до звонка'**
  String get heroUntilBell;

  /// No description provided for @heroUntilStart.
  ///
  /// In ru, this message translates to:
  /// **'до начала'**
  String get heroUntilStart;

  /// No description provided for @heroUntilLesson.
  ///
  /// In ru, this message translates to:
  /// **'до урока'**
  String get heroUntilLesson;

  /// No description provided for @heroMin.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get heroMin;

  /// No description provided for @heroDayOver.
  ///
  /// In ru, this message translates to:
  /// **'День закончен'**
  String get heroDayOver;

  /// No description provided for @heroForTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'На завтра'**
  String get heroForTomorrow;

  /// No description provided for @heroOpenTasks.
  ///
  /// In ru, this message translates to:
  /// **'Открыть задания'**
  String get heroOpenTasks;

  /// No description provided for @heroNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков нет'**
  String get heroNoLessons;

  /// No description provided for @heroRest.
  ///
  /// In ru, this message translates to:
  /// **'Можно отдохнуть'**
  String get heroRest;

  /// No description provided for @heroCancelled.
  ///
  /// In ru, this message translates to:
  /// **'отменён'**
  String get heroCancelled;

  /// No description provided for @heroThen.
  ///
  /// In ru, this message translates to:
  /// **'Потом'**
  String get heroThen;

  /// No description provided for @heroInstead.
  ///
  /// In ru, this message translates to:
  /// **'{who} вместо {whom}'**
  String heroInstead(String who, String whom);

  /// No description provided for @heroSemantic.
  ///
  /// In ru, this message translates to:
  /// **'{state} {subject}, {details}. {countdown}'**
  String heroSemantic(String state, String subject, String details, String countdown);

  /// No description provided for @heroCountdown.
  ///
  /// In ru, this message translates to:
  /// **'{label}: {m} мин'**
  String heroCountdown(String label, int m);

  /// No description provided for @heroNextLine.
  ///
  /// In ru, this message translates to:
  /// **'Дальше {time} {subject}'**
  String heroNextLine(String time, String subject);

  /// No description provided for @heroTomorrowPlan.
  ///
  /// In ru, this message translates to:
  /// **'Завтра {count, plural, one{{count} урок} few{{count} урока} other{{count} уроков}} с {time}'**
  String heroTomorrowPlan(int count, String time);

  /// No description provided for @heroTasksDone.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ готово: {done} из {total}'**
  String heroTasksDone(int done, int total);

  /// No description provided for @tileTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'На завтра'**
  String get tileTomorrow;

  /// No description provided for @tileNewGrades.
  ///
  /// In ru, this message translates to:
  /// **'Новые оценки'**
  String get tileNewGrades;

  /// No description provided for @tileOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get tileOverdue;

  /// No description provided for @dayPlan.
  ///
  /// In ru, this message translates to:
  /// **'План дня'**
  String get dayPlan;

  /// No description provided for @lessonsPassed.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} урок прошёл} few{{count} урока прошли} other{{count} уроков прошли}}'**
  String lessonsPassed(int count);

  /// No description provided for @pillNow.
  ///
  /// In ru, this message translates to:
  /// **'сейчас'**
  String get pillNow;

  /// No description provided for @pillSubstitution.
  ///
  /// In ru, this message translates to:
  /// **'замена'**
  String get pillSubstitution;

  /// No description provided for @pillCancelled.
  ///
  /// In ru, this message translates to:
  /// **'отменён'**
  String get pillCancelled;

  /// No description provided for @pillJoint.
  ///
  /// In ru, this message translates to:
  /// **'совмещённый'**
  String get pillJoint;

  /// No description provided for @breakLine.
  ///
  /// In ru, this message translates to:
  /// **'перемена {m} мин'**
  String breakLine(int m);

  /// No description provided for @checkInTitle.
  ///
  /// In ru, this message translates to:
  /// **'Я в школе'**
  String get checkInTitle;

  /// No description provided for @checkInBy.
  ///
  /// In ru, this message translates to:
  /// **'Отметка до {time}'**
  String checkInBy(String time);

  /// No description provided for @checkInSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Селфи у входа — 5 секунд'**
  String get checkInSubtitle;

  /// No description provided for @checkInOpensAt.
  ///
  /// In ru, this message translates to:
  /// **'Отметка откроется в {time}'**
  String checkInOpensAt(String time);

  /// No description provided for @checkInDoneAt.
  ///
  /// In ru, this message translates to:
  /// **'В школе с {time}'**
  String checkInDoneAt(String time);

  /// No description provided for @checkInOnTime.
  ///
  /// In ru, this message translates to:
  /// **'Отметка вовремя'**
  String get checkInOnTime;

  /// No description provided for @checkInLateAt.
  ///
  /// In ru, this message translates to:
  /// **'Отмечено в {time} · опоздание'**
  String checkInLateAt(String time);

  /// No description provided for @checkInClosed.
  ///
  /// In ru, this message translates to:
  /// **'Окно отметки закрыто в {time}'**
  String checkInClosed(String time);

  /// No description provided for @checkInClosedHint.
  ///
  /// In ru, this message translates to:
  /// **'Если вы уже в школе, скажите классному руководителю'**
  String get checkInClosedHint;

  /// No description provided for @checkInNoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Нужно разрешение родителя на фото'**
  String get checkInNoConsent;

  /// No description provided for @checkInAskParent.
  ///
  /// In ru, this message translates to:
  /// **'Как попросить родителя'**
  String get checkInAskParent;

  /// No description provided for @checkInAskParentHint.
  ///
  /// In ru, this message translates to:
  /// **'Родитель разрешает это в своём приложении GradeApp: «Сегодня» → «Разрешить». Это займёт минуту'**
  String get checkInAskParentHint;

  /// No description provided for @checkInSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем фото…'**
  String get checkInSending;

  /// No description provided for @checkInSendingPct.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем… {pct} %'**
  String checkInSendingPct(int pct);

  /// No description provided for @checkInOutside.
  ///
  /// In ru, this message translates to:
  /// **'Вы в {meters} м от школы. Подойдите ближе ко входу и повторите'**
  String checkInOutside(int meters);

  /// No description provided for @checkInNeedLocation.
  ///
  /// In ru, this message translates to:
  /// **'Включите геолокацию'**
  String get checkInNeedLocation;

  /// No description provided for @checkInStale.
  ///
  /// In ru, this message translates to:
  /// **'Сделайте новый снимок'**
  String get checkInStale;

  /// No description provided for @checkInOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Повторим без нового снимка, пока окно открыто'**
  String get checkInOffline;

  /// No description provided for @checkInAlready.
  ///
  /// In ru, this message translates to:
  /// **'Вы уже отметились сегодня'**
  String get checkInAlready;

  /// No description provided for @checkInWindowClosed.
  ///
  /// In ru, this message translates to:
  /// **'Окно отметки закрыто'**
  String get checkInWindowClosed;

  /// No description provided for @checkInFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось отправить фото'**
  String get checkInFailed;

  /// No description provided for @checkInOpenCamera.
  ///
  /// In ru, this message translates to:
  /// **'Открыть камеру'**
  String get checkInOpenCamera;

  /// No description provided for @camLocating.
  ///
  /// In ru, this message translates to:
  /// **'Ищем геопозицию…'**
  String get camLocating;

  /// No description provided for @camAtSchool.
  ///
  /// In ru, this message translates to:
  /// **'Вы у школы · окно до {time}'**
  String camAtSchool(String time);

  /// No description provided for @camWindowUntil.
  ///
  /// In ru, this message translates to:
  /// **'Окно до {time}'**
  String camWindowUntil(String time);

  /// No description provided for @camFar.
  ///
  /// In ru, this message translates to:
  /// **'Далеко от школы'**
  String get camFar;

  /// No description provided for @camHint.
  ///
  /// In ru, this message translates to:
  /// **'Лицо в овале — и снимок'**
  String get camHint;

  /// No description provided for @camPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Фото увидит только персонал школы. Оно удалится через 30 дней'**
  String get camPrivacy;

  /// No description provided for @camShutter.
  ///
  /// In ru, this message translates to:
  /// **'Сделать снимок'**
  String get camShutter;

  /// No description provided for @camFlashOn.
  ///
  /// In ru, this message translates to:
  /// **'Включить вспышку экраном'**
  String get camFlashOn;

  /// No description provided for @camFlashOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключить вспышку экраном'**
  String get camFlashOff;

  /// No description provided for @camRetake.
  ///
  /// In ru, this message translates to:
  /// **'Переснять'**
  String get camRetake;

  /// No description provided for @camUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна'**
  String get camUnavailable;

  /// No description provided for @camDenied.
  ///
  /// In ru, this message translates to:
  /// **'Включите «Камера» для GradeApp в настройках телефона'**
  String get camDenied;

  /// No description provided for @camExplainTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отметка по селфи'**
  String get camExplainTitle;

  /// No description provided for @camExplainWhy.
  ///
  /// In ru, this message translates to:
  /// **'Селфи у входа подтверждает, что вы в школе'**
  String get camExplainWhy;

  /// No description provided for @camExplainWho.
  ///
  /// In ru, this message translates to:
  /// **'Фото видит только персонал школы'**
  String get camExplainWho;

  /// No description provided for @camExplainKeep.
  ///
  /// In ru, this message translates to:
  /// **'Фото удаляется через 30 дней'**
  String get camExplainKeep;

  /// No description provided for @doneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отмечено'**
  String get doneTitle;

  /// No description provided for @doneOnTime.
  ///
  /// In ru, this message translates to:
  /// **'{time} · вовремя'**
  String doneOnTime(String time);

  /// No description provided for @doneLate.
  ///
  /// In ru, this message translates to:
  /// **'{time} · опоздание'**
  String doneLate(String time);

  /// No description provided for @doneLateMin.
  ///
  /// In ru, this message translates to:
  /// **'{time} · опоздание на {m} мин'**
  String doneLateMin(String time, int m);

  /// No description provided for @doneFirstLesson.
  ///
  /// In ru, this message translates to:
  /// **'Первый урок · {time}'**
  String doneFirstLesson(String time);

  /// No description provided for @doneParents.
  ///
  /// In ru, this message translates to:
  /// **'Родители увидят отметку в приложении'**
  String get doneParents;

  /// No description provided for @weekEyebrow.
  ///
  /// In ru, this message translates to:
  /// **'{range} · {term}'**
  String weekEyebrow(String range, String term);

  /// No description provided for @weekGoToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get weekGoToday;

  /// No description provided for @weekDaySpan.
  ///
  /// In ru, this message translates to:
  /// **'{lessons} · {from}–{to}'**
  String weekDaySpan(String lessons, String from, String to);

  /// No description provided for @weekNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроков нет'**
  String get weekNoLessons;

  /// No description provided for @weekNoLessonsHint.
  ///
  /// In ru, this message translates to:
  /// **'В этот день занятий нет'**
  String get weekNoLessonsHint;

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

  /// No description provided for @hwShort.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ'**
  String get hwShort;

  /// No description provided for @dotChanges.
  ///
  /// In ru, this message translates to:
  /// **'есть изменения'**
  String get dotChanges;

  /// No description provided for @dotHomework.
  ///
  /// In ru, this message translates to:
  /// **'есть ДЗ'**
  String get dotHomework;

  /// No description provided for @dotExam.
  ///
  /// In ru, this message translates to:
  /// **'СОР или СОЧ'**
  String get dotExam;

  /// No description provided for @lessonOrdinal.
  ///
  /// In ru, this message translates to:
  /// **'{weekday} · {n}-й урок'**
  String lessonOrdinal(String weekday, int n);

  /// No description provided for @teacher.
  ///
  /// In ru, this message translates to:
  /// **'Учитель'**
  String get teacher;

  /// No description provided for @topicLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get topicLabel;

  /// No description provided for @lessonHomework.
  ///
  /// In ru, this message translates to:
  /// **'Задание к уроку'**
  String get lessonHomework;

  /// No description provided for @myMarks.
  ///
  /// In ru, this message translates to:
  /// **'Мои отметки'**
  String get myMarks;

  /// No description provided for @childMarks.
  ///
  /// In ru, this message translates to:
  /// **'Отметки'**
  String get childMarks;

  /// No description provided for @notFilledYet.
  ///
  /// In ru, this message translates to:
  /// **'Учитель ещё не заполнил'**
  String get notFilledYet;

  /// No description provided for @explainAbsence.
  ///
  /// In ru, this message translates to:
  /// **'Объяснить пропуск'**
  String get explainAbsence;

  /// No description provided for @openLesson.
  ///
  /// In ru, this message translates to:
  /// **'Открыть урок'**
  String get openLesson;

  /// No description provided for @presencePresent.
  ///
  /// In ru, this message translates to:
  /// **'был на уроке'**
  String get presencePresent;

  /// No description provided for @presenceAbsent.
  ///
  /// In ru, this message translates to:
  /// **'пропуск'**
  String get presenceAbsent;

  /// No description provided for @presenceTardy.
  ///
  /// In ru, this message translates to:
  /// **'опоздание'**
  String get presenceTardy;

  /// No description provided for @presenceExcused.
  ///
  /// In ru, this message translates to:
  /// **'уважительная'**
  String get presenceExcused;

  /// No description provided for @gradesEyebrow.
  ///
  /// In ru, this message translates to:
  /// **'{term} · {week}-я неделя'**
  String gradesEyebrow(String term, int week);

  /// No description provided for @termShort.
  ///
  /// In ru, this message translates to:
  /// **'{n} четв.'**
  String termShort(int n);

  /// No description provided for @termRunning.
  ///
  /// In ru, this message translates to:
  /// **'идёт'**
  String get termRunning;

  /// No description provided for @termPick.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать {term}'**
  String termPick(String term);

  /// No description provided for @segSubjects.
  ///
  /// In ru, this message translates to:
  /// **'Предметы'**
  String get segSubjects;

  /// No description provided for @segFeed.
  ///
  /// In ru, this message translates to:
  /// **'Лента'**
  String get segFeed;

  /// No description provided for @subjectsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} предмет} few{{count} предмета} other{{count} предметов}}'**
  String subjectsCount(int count);

  /// No description provided for @sortAttention.
  ///
  /// In ru, this message translates to:
  /// **'Сначала требующие внимания'**
  String get sortAttention;

  /// No description provided for @sortAlpha.
  ///
  /// In ru, this message translates to:
  /// **'По алфавиту'**
  String get sortAlpha;

  /// No description provided for @prelim.
  ///
  /// In ru, this message translates to:
  /// **'предв.'**
  String get prelim;

  /// No description provided for @gradesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Оценок в этой четверти пока нет'**
  String get gradesEmpty;

  /// No description provided for @gradesEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Первая появится после урока'**
  String get gradesEmptyHint;

  /// No description provided for @insightStrong.
  ///
  /// In ru, this message translates to:
  /// **'Сильнее всего — {subject}.'**
  String insightStrong(String subject);

  /// No description provided for @insightWeak.
  ///
  /// In ru, this message translates to:
  /// **'Внимания требует {subject}: {pct} %.'**
  String insightWeak(String subject, int pct);

  /// No description provided for @quarterResults.
  ///
  /// In ru, this message translates to:
  /// **'Итоги: {term}'**
  String quarterResults(String term);

  /// No description provided for @howCalculated.
  ///
  /// In ru, this message translates to:
  /// **'Как считается четвертная'**
  String get howCalculated;

  /// No description provided for @howCalcBody.
  ///
  /// In ru, this message translates to:
  /// **'Так же считает школа и табель'**
  String get howCalcBody;

  /// No description provided for @howCalcMissing.
  ///
  /// In ru, this message translates to:
  /// **'Если какой-то части пока нет, её вес делится между остальными'**
  String get howCalcMissing;

  /// No description provided for @pctToMark.
  ///
  /// In ru, this message translates to:
  /// **'% → отметка'**
  String get pctToMark;

  /// No description provided for @pctFrom.
  ///
  /// In ru, this message translates to:
  /// **'от {pct} %'**
  String pctFrom(int pct);

  /// No description provided for @formulaMissing.
  ///
  /// In ru, this message translates to:
  /// **'Формула школы не загрузилась, поэтому четвертная скрыта'**
  String get formulaMissing;

  /// No description provided for @subjectPrelim.
  ///
  /// In ru, this message translates to:
  /// **'{term} · предварительно'**
  String subjectPrelim(String term);

  /// No description provided for @subjectFinal.
  ///
  /// In ru, this message translates to:
  /// **'{term} · итог'**
  String subjectFinal(String term);

  /// No description provided for @worksCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} работа} few{{count} работы} other{{count} работ}}'**
  String worksCount(int count);

  /// No description provided for @toNextMark.
  ///
  /// In ru, this message translates to:
  /// **'до «{mark}» не хватает {pct} %'**
  String toNextMark(String mark, int pct);

  /// No description provided for @works.
  ///
  /// In ru, this message translates to:
  /// **'Работы'**
  String get works;

  /// No description provided for @newestFirst.
  ///
  /// In ru, this message translates to:
  /// **'новые сверху'**
  String get newestFirst;

  /// No description provided for @kindFo.
  ///
  /// In ru, this message translates to:
  /// **'ФО'**
  String get kindFo;

  /// No description provided for @kindSor.
  ///
  /// In ru, this message translates to:
  /// **'СОР'**
  String get kindSor;

  /// No description provided for @kindSoch.
  ///
  /// In ru, this message translates to:
  /// **'СОЧ'**
  String get kindSoch;

  /// No description provided for @gradeSemantic.
  ///
  /// In ru, this message translates to:
  /// **'Оценка {value}, {tone}'**
  String gradeSemantic(String value, String tone);

  /// No description provided for @toneExcellent.
  ///
  /// In ru, this message translates to:
  /// **'отлично'**
  String get toneExcellent;

  /// No description provided for @toneGood.
  ///
  /// In ru, this message translates to:
  /// **'хорошо'**
  String get toneGood;

  /// No description provided for @toneFair.
  ///
  /// In ru, this message translates to:
  /// **'удовлетворительно'**
  String get toneFair;

  /// No description provided for @tonePoor.
  ///
  /// In ru, this message translates to:
  /// **'неудовлетворительно'**
  String get tonePoor;

  /// No description provided for @newWord.
  ///
  /// In ru, this message translates to:
  /// **'новая'**
  String get newWord;

  /// No description provided for @tasksEyebrow.
  ///
  /// In ru, this message translates to:
  /// **'На неделе: {count, plural, one{{count} задание} few{{count} задания} other{{count} заданий}}'**
  String tasksEyebrow(int count);

  /// No description provided for @sectionOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочено'**
  String get sectionOverdue;

  /// No description provided for @sectionToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get sectionToday;

  /// No description provided for @sectionTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get sectionTomorrow;

  /// No description provided for @sectionWeek.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе'**
  String get sectionWeek;

  /// No description provided for @sectionLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get sectionLater;

  /// No description provided for @sectionDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено: {count}'**
  String sectionDone(int count);

  /// No description provided for @allSubjects.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allSubjects;

  /// No description provided for @markDone.
  ///
  /// In ru, this message translates to:
  /// **'Отметить готовым'**
  String get markDone;

  /// No description provided for @markUndone.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть в невыполненные'**
  String get markUndone;

  /// No description provided for @doneToast.
  ///
  /// In ru, this message translates to:
  /// **'Задание отмечено готовым'**
  String get doneToast;

  /// No description provided for @undoneToast.
  ///
  /// In ru, this message translates to:
  /// **'Задание вернулось в список'**
  String get undoneToast;

  /// No description provided for @hwDone.
  ///
  /// In ru, this message translates to:
  /// **'сделано'**
  String get hwDone;

  /// No description provided for @hwNotDone.
  ///
  /// In ru, this message translates to:
  /// **'не сделано'**
  String get hwNotDone;

  /// No description provided for @dueBy.
  ///
  /// In ru, this message translates to:
  /// **'к {date}'**
  String dueBy(String date);

  /// No description provided for @attachmentsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} вложение} few{{count} вложения} other{{count} вложений}}'**
  String attachmentsCount(int count);

  /// No description provided for @tasksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Заданий нет'**
  String get tasksEmpty;

  /// No description provided for @tasksEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Новые задания от учителей появятся здесь'**
  String get tasksEmptyHint;

  /// No description provided for @taskToggleDone.
  ///
  /// In ru, this message translates to:
  /// **'Отметить «{title}» готовым'**
  String taskToggleDone(String title);

  /// No description provided for @taskToggleUndone.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть «{title}»'**
  String taskToggleUndone(String title);

  /// No description provided for @openFile.
  ///
  /// In ru, this message translates to:
  /// **'Открыть файл'**
  String get openFile;

  /// No description provided for @loadToday.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка {used} из {norm} мин'**
  String loadToday(int used, int norm);

  /// No description provided for @verdictOk.
  ///
  /// In ru, this message translates to:
  /// **'Всё в порядке'**
  String get verdictOk;

  /// No description provided for @verdictQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Есть вопрос'**
  String get verdictQuestion;

  /// No description provided for @verdictAction.
  ///
  /// In ru, this message translates to:
  /// **'Нужно действие'**
  String get verdictAction;

  /// No description provided for @verdictAlarm.
  ///
  /// In ru, this message translates to:
  /// **'Не отметился в школе'**
  String get verdictAlarm;

  /// No description provided for @verdictNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков нет'**
  String get verdictNoLessons;

  /// No description provided for @verdictUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Данные на {time}'**
  String verdictUpdated(String time);

  /// No description provided for @factArrived.
  ///
  /// In ru, this message translates to:
  /// **'В школе с {time}.'**
  String factArrived(String time);

  /// No description provided for @factLessons.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total} уроков.'**
  String factLessons(int done, int total);

  /// No description provided for @factBeforeLessons.
  ///
  /// In ru, this message translates to:
  /// **'Первый урок в {time}.'**
  String factBeforeLessons(String time);

  /// No description provided for @factAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Пропущен урок: {subject}'**
  String factAbsent(String subject);

  /// No description provided for @factNoReason.
  ///
  /// In ru, this message translates to:
  /// **'причина не указана.'**
  String get factNoReason;

  /// No description provided for @factLate.
  ///
  /// In ru, this message translates to:
  /// **'Опоздание: отметка в {time}.'**
  String factLate(String time);

  /// No description provided for @factLowGrade.
  ///
  /// In ru, this message translates to:
  /// **'Низкая оценка: {subject} {value}.'**
  String factLowGrade(String subject, String value);

  /// No description provided for @factExcused.
  ///
  /// In ru, this message translates to:
  /// **'Отпрошен(а) на сегодня.'**
  String get factExcused;

  /// No description provided for @factAlarm.
  ///
  /// In ru, this message translates to:
  /// **'Первый урок начался в {time}. Отметки и заявки нет.'**
  String factAlarm(String time);

  /// No description provided for @factNoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Отметка по селфи ждёт вашего разрешения.'**
  String get factNoConsent;

  /// No description provided for @factTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра {lessons} с {time}.'**
  String factTomorrow(String lessons, String time);

  /// No description provided for @factNewGrade.
  ///
  /// In ru, this message translates to:
  /// **'новая оценка · {subject}'**
  String factNewGrade(String subject);

  /// No description provided for @actExcuse.
  ///
  /// In ru, this message translates to:
  /// **'Отпросить'**
  String get actExcuse;

  /// No description provided for @actExplain.
  ///
  /// In ru, this message translates to:
  /// **'Объяснить'**
  String get actExplain;

  /// No description provided for @actAllow.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get actAllow;

  /// No description provided for @attentionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Требует внимания'**
  String get attentionTitle;

  /// No description provided for @attAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Пропуск · {time}'**
  String attAbsent(String time);

  /// No description provided for @attNoConsent.
  ///
  /// In ru, this message translates to:
  /// **'Отметка по селфи'**
  String get attNoConsent;

  /// No description provided for @attNoConsentSub.
  ///
  /// In ru, this message translates to:
  /// **'Нужно ваше разрешение'**
  String get attNoConsentSub;

  /// No description provided for @attRejected.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отклонена'**
  String get attRejected;

  /// No description provided for @attPending.
  ///
  /// In ru, this message translates to:
  /// **'Заявка на рассмотрении у классрука'**
  String get attPending;

  /// No description provided for @feedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Лента дня'**
  String get feedTitle;

  /// No description provided for @feedNewest.
  ///
  /// In ru, this message translates to:
  /// **'новое сверху'**
  String get feedNewest;

  /// No description provided for @feedArrived.
  ///
  /// In ru, this message translates to:
  /// **'Пришёл(ла) в школу'**
  String get feedArrived;

  /// No description provided for @feedArrivedSub.
  ///
  /// In ru, this message translates to:
  /// **'отметка по селфи · {state}'**
  String feedArrivedSub(String state);

  /// No description provided for @feedOnTime.
  ///
  /// In ru, this message translates to:
  /// **'вовремя'**
  String get feedOnTime;

  /// No description provided for @feedLate.
  ///
  /// In ru, this message translates to:
  /// **'опоздание'**
  String get feedLate;

  /// No description provided for @feedNow.
  ///
  /// In ru, this message translates to:
  /// **'идёт сейчас'**
  String get feedNow;

  /// No description provided for @feedMarkedAbsent.
  ///
  /// In ru, this message translates to:
  /// **'отмечен пропуск'**
  String get feedMarkedAbsent;

  /// No description provided for @feedEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока ничего не произошло'**
  String get feedEmpty;

  /// No description provided for @forTomorrowLine.
  ///
  /// In ru, this message translates to:
  /// **'{tasks} · ≈ {m} мин · готово {done}'**
  String forTomorrowLine(String tasks, int m, int done);

  /// No description provided for @familyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Семья'**
  String get familyTitle;

  /// No description provided for @familyNotChecked.
  ///
  /// In ru, this message translates to:
  /// **'не отмечен'**
  String get familyNotChecked;

  /// No description provided for @familyAllGood.
  ///
  /// In ru, this message translates to:
  /// **'всё в порядке'**
  String get familyAllGood;

  /// No description provided for @familyQuestion.
  ///
  /// In ru, this message translates to:
  /// **'есть вопрос'**
  String get familyQuestion;

  /// No description provided for @familyNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'нет уроков'**
  String get familyNoLessons;

  /// No description provided for @familyExcuseCard.
  ///
  /// In ru, this message translates to:
  /// **'Отпросить ребёнка'**
  String get familyExcuseCard;

  /// No description provided for @familyExcuseHint.
  ///
  /// In ru, this message translates to:
  /// **'Болезнь, семейные дела, врач — заявка уйдёт классруку'**
  String get familyExcuseHint;

  /// No description provided for @requests.
  ///
  /// In ru, this message translates to:
  /// **'Заявки'**
  String get requests;

  /// No description provided for @reqPending.
  ///
  /// In ru, this message translates to:
  /// **'на рассмотрении'**
  String get reqPending;

  /// No description provided for @reqApproved.
  ///
  /// In ru, this message translates to:
  /// **'одобрена'**
  String get reqApproved;

  /// No description provided for @reqRejected.
  ///
  /// In ru, this message translates to:
  /// **'отклонена'**
  String get reqRejected;

  /// No description provided for @reqCancelled.
  ///
  /// In ru, this message translates to:
  /// **'отозвана'**
  String get reqCancelled;

  /// No description provided for @reqWithdraw.
  ///
  /// In ru, this message translates to:
  /// **'Отозвать заявку'**
  String get reqWithdraw;

  /// No description provided for @reqWithdrawConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Отозвать заявку?'**
  String get reqWithdrawConfirm;

  /// No description provided for @reqEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Заявок пока нет'**
  String get reqEmpty;

  /// No description provided for @reqEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Когда отпросите ребёнка, заявка появится здесь'**
  String get reqEmptyHint;

  /// No description provided for @catIllness.
  ///
  /// In ru, this message translates to:
  /// **'Болезнь'**
  String get catIllness;

  /// No description provided for @catFamily.
  ///
  /// In ru, this message translates to:
  /// **'Семейные'**
  String get catFamily;

  /// No description provided for @catAppointment.
  ///
  /// In ru, this message translates to:
  /// **'Врач или дела'**
  String get catAppointment;

  /// No description provided for @catOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get catOther;

  /// No description provided for @excuseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отпросить: {name}'**
  String excuseTitle(String name);

  /// No description provided for @excuseWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда'**
  String get excuseWhen;

  /// No description provided for @excuseDates.
  ///
  /// In ru, this message translates to:
  /// **'Даты'**
  String get excuseDates;

  /// No description provided for @excuseLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get excuseLessons;

  /// No description provided for @excuseFrom.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get excuseFrom;

  /// No description provided for @excuseTo.
  ///
  /// In ru, this message translates to:
  /// **'По'**
  String get excuseTo;

  /// No description provided for @excuseReason.
  ///
  /// In ru, this message translates to:
  /// **'Причина'**
  String get excuseReason;

  /// No description provided for @excuseComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get excuseComment;

  /// No description provided for @excuseCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно'**
  String get excuseCommentHint;

  /// No description provided for @excuseProof.
  ///
  /// In ru, this message translates to:
  /// **'Справка'**
  String get excuseProof;

  /// No description provided for @excuseCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get excuseCamera;

  /// No description provided for @excuseGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get excuseGallery;

  /// No description provided for @excuseRemoveProof.
  ///
  /// In ru, this message translates to:
  /// **'Убрать справку'**
  String get excuseRemoveProof;

  /// No description provided for @excuseSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить классруку'**
  String get excuseSend;

  /// No description provided for @excuseSent.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отправлена'**
  String get excuseSent;

  /// No description provided for @excusePickLessons.
  ///
  /// In ru, this message translates to:
  /// **'Выберите хотя бы один урок'**
  String get excusePickLessons;

  /// No description provided for @excuseOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Отправьте, когда появится связь'**
  String get excuseOffline;

  /// No description provided for @excuseFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось отправить заявку'**
  String get excuseFailed;

  /// No description provided for @consentSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить отметку по селфи?'**
  String get consentSheetTitle;

  /// No description provided for @consentWho.
  ///
  /// In ru, this message translates to:
  /// **'Фото видит только персонал школы'**
  String get consentWho;

  /// No description provided for @consentKeep.
  ///
  /// In ru, this message translates to:
  /// **'Удаляется через 30 дней'**
  String get consentKeep;

  /// No description provided for @consentWhere.
  ///
  /// In ru, this message translates to:
  /// **'Можно отозвать в профиле ребёнка'**
  String get consentWhere;

  /// No description provided for @consentAllowed.
  ///
  /// In ru, this message translates to:
  /// **'{name} может отмечаться'**
  String consentAllowed(String name);

  /// No description provided for @consentFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось сохранить разрешение'**
  String get consentFailed;

  /// No description provided for @tUntilBell.
  ///
  /// In ru, this message translates to:
  /// **'до звонка {m} мин'**
  String tUntilBell(int m);

  /// No description provided for @tStartsIn.
  ///
  /// In ru, this message translates to:
  /// **'через {m} мин'**
  String tStartsIn(int m);

  /// No description provided for @tFree.
  ///
  /// In ru, this message translates to:
  /// **'окно {m} мин'**
  String tFree(int m);

  /// No description provided for @tStudents.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} ученик} few{{count} ученика} other{{count} учеников}}'**
  String tStudents(int count);

  /// No description provided for @tRollNotDone.
  ///
  /// In ru, this message translates to:
  /// **'Перекличка не сделана'**
  String get tRollNotDone;

  /// No description provided for @tRollDone.
  ///
  /// In ru, this message translates to:
  /// **'Перекличка сделана'**
  String get tRollDone;

  /// No description provided for @tTopicDone.
  ///
  /// In ru, this message translates to:
  /// **'тема ✓'**
  String get tTopicDone;

  /// No description provided for @tCloseDay.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть день'**
  String get tCloseDay;

  /// No description provided for @tActions.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} действие} few{{count} действия} other{{count} действий}}'**
  String tActions(int count);

  /// No description provided for @tDayClosed.
  ///
  /// In ru, this message translates to:
  /// **'День закрыт'**
  String get tDayClosed;

  /// No description provided for @tDayClosedHint.
  ///
  /// In ru, this message translates to:
  /// **'Все уроки заполнены'**
  String get tDayClosedHint;

  /// No description provided for @tNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков нет'**
  String get tNoLessons;

  /// No description provided for @tUnmarked.
  ///
  /// In ru, this message translates to:
  /// **'не отмечено'**
  String get tUnmarked;

  /// No description provided for @tNoTopic.
  ///
  /// In ru, this message translates to:
  /// **'без темы'**
  String get tNoTopic;

  /// No description provided for @tLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроки'**
  String get tLessons;

  /// No description provided for @tTodayCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} сегодня'**
  String tTodayCount(int count);

  /// No description provided for @missingAttendance.
  ///
  /// In ru, this message translates to:
  /// **'посещаемость'**
  String get missingAttendance;

  /// No description provided for @missingTopic.
  ///
  /// In ru, this message translates to:
  /// **'тема'**
  String get missingTopic;

  /// No description provided for @missingHomework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ'**
  String get missingHomework;

  /// No description provided for @missingGrades.
  ///
  /// In ru, this message translates to:
  /// **'оценки'**
  String get missingGrades;

  /// No description provided for @tMissingWhat.
  ///
  /// In ru, this message translates to:
  /// **'{what}: {lesson}'**
  String tMissingWhat(String what, String lesson);

  /// No description provided for @tDebts.
  ///
  /// In ru, this message translates to:
  /// **'Долги за 14 дней'**
  String get tDebts;

  /// No description provided for @tDebtsUnmarked.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} урок без отметки} few{{count} урока без отметки} other{{count} уроков без отметки}}'**
  String tDebtsUnmarked(int count);

  /// No description provided for @tCloseAll.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть все без отсутствующих'**
  String get tCloseAll;

  /// No description provided for @tCloseAllConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Отметить всех присутствующими?'**
  String get tCloseAllConfirm;

  /// No description provided for @tCloseAllBody.
  ///
  /// In ru, this message translates to:
  /// **'Только уроки, где отметок ещё нет. Исправить можно потом в уроке'**
  String get tCloseAllBody;

  /// No description provided for @tAllPresentToast.
  ///
  /// In ru, this message translates to:
  /// **'{cls}: все на месте'**
  String tAllPresentToast(String cls);

  /// No description provided for @tAllPresent.
  ///
  /// In ru, this message translates to:
  /// **'Все на месте'**
  String get tAllPresent;

  /// No description provided for @tLessonRowSemantic.
  ///
  /// In ru, this message translates to:
  /// **'{time}, {cls}, {subject}. {state}'**
  String tLessonRowSemantic(String time, String cls, String subject, String state);

  /// No description provided for @tAllFilled.
  ///
  /// In ru, this message translates to:
  /// **'всё заполнено'**
  String get tAllFilled;

  /// No description provided for @tJointClasses.
  ///
  /// In ru, this message translates to:
  /// **'{a} + {b}'**
  String tJointClasses(String a, String b);

  /// No description provided for @lessonOver.
  ///
  /// In ru, this message translates to:
  /// **'урок закончился'**
  String get lessonOver;

  /// No description provided for @topicCard.
  ///
  /// In ru, this message translates to:
  /// **'Тема урока'**
  String get topicCard;

  /// No description provided for @ktpChip.
  ///
  /// In ru, this message translates to:
  /// **'КТП: {topic}'**
  String ktpChip(String topic);

  /// No description provided for @sameAsLast.
  ///
  /// In ru, this message translates to:
  /// **'Как в прошлый раз'**
  String get sameAsLast;

  /// No description provided for @topicHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Подобие треугольников'**
  String get topicHint;

  /// No description provided for @topicSaved.
  ///
  /// In ru, this message translates to:
  /// **'Тема сохранена'**
  String get topicSaved;

  /// No description provided for @presentLabel.
  ///
  /// In ru, this message translates to:
  /// **'Присутствуют'**
  String get presentLabel;

  /// No description provided for @searchStudent.
  ///
  /// In ru, this message translates to:
  /// **'Найти ученика'**
  String get searchStudent;

  /// No description provided for @viewList.
  ///
  /// In ru, this message translates to:
  /// **'Список'**
  String get viewList;

  /// No description provided for @viewFaces.
  ///
  /// In ru, this message translates to:
  /// **'Лица'**
  String get viewFaces;

  /// No description provided for @sourceCheckIn.
  ///
  /// In ru, this message translates to:
  /// **'отметился сам · {time}'**
  String sourceCheckIn(String time);

  /// No description provided for @sourceCheckInShort.
  ///
  /// In ru, this message translates to:
  /// **'отметился сам'**
  String get sourceCheckInShort;

  /// No description provided for @sourceHomeroom.
  ///
  /// In ru, this message translates to:
  /// **'отметка классрука'**
  String get sourceHomeroom;

  /// No description provided for @lateBy.
  ///
  /// In ru, this message translates to:
  /// **'опоздал на {m} мин'**
  String lateBy(int m);

  /// No description provided for @notSaved.
  ///
  /// In ru, this message translates to:
  /// **'не сохранено: {reason}'**
  String notSaved(String reason);

  /// No description provided for @reasonSochShort.
  ///
  /// In ru, this message translates to:
  /// **'день СОЧ'**
  String get reasonSochShort;

  /// No description provided for @reasonSoch.
  ///
  /// In ru, this message translates to:
  /// **'День СОЧ — отметки не принимаются'**
  String get reasonSoch;

  /// No description provided for @reasonForbiddenShort.
  ///
  /// In ru, this message translates to:
  /// **'нет прав на урок'**
  String get reasonForbiddenShort;

  /// No description provided for @reasonForbidden.
  ///
  /// In ru, this message translates to:
  /// **'Нет прав на этот урок'**
  String get reasonForbidden;

  /// No description provided for @reasonNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Урок или ученик удалён'**
  String get reasonNotFound;

  /// No description provided for @reasonInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Сервер не принял запись'**
  String get reasonInvalid;

  /// No description provided for @sochBanner.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня СОЧ по предмету «{subject}».'**
  String sochBanner(String subject);

  /// No description provided for @sochBannerBody.
  ///
  /// In ru, this message translates to:
  /// **'Текущие оценки и посещаемость не выставляются'**
  String get sochBannerBody;

  /// No description provided for @pendingBanner.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} отметка ждёт сети.} few{{count} отметки ждут сети.} other{{count} отметок ждут сети.}}'**
  String pendingBanner(int count);

  /// No description provided for @pendingBannerBody.
  ///
  /// In ru, this message translates to:
  /// **'Отправим сами'**
  String get pendingBannerBody;

  /// No description provided for @rejectedBanner.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} запись не сохранена.} few{{count} записи не сохранены.} other{{count} записей не сохранено.}}'**
  String rejectedBanner(int count);

  /// No description provided for @openQueue.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get openQueue;

  /// No description provided for @dockHomework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ'**
  String get dockHomework;

  /// No description provided for @dockSummary.
  ///
  /// In ru, this message translates to:
  /// **'Итог'**
  String get dockSummary;

  /// No description provided for @dockAllPresent.
  ///
  /// In ru, this message translates to:
  /// **'Все на месте · {count}'**
  String dockAllPresent(int count);

  /// No description provided for @dockDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово · {n} из {m}'**
  String dockDone(int n, int m);

  /// No description provided for @dockFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить урок'**
  String get dockFinish;

  /// No description provided for @dockSochDay.
  ///
  /// In ru, this message translates to:
  /// **'День СОЧ'**
  String get dockSochDay;

  /// No description provided for @rollSaved.
  ///
  /// In ru, this message translates to:
  /// **'Перекличка сохранена'**
  String get rollSaved;

  /// No description provided for @markedToast.
  ///
  /// In ru, this message translates to:
  /// **'{name} — {state}'**
  String markedToast(String name, String state);

  /// No description provided for @stateAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Н'**
  String get stateAbsent;

  /// No description provided for @statePresent.
  ///
  /// In ru, this message translates to:
  /// **'есть'**
  String get statePresent;

  /// No description provided for @rowPresentHint.
  ///
  /// In ru, this message translates to:
  /// **'Двойное касание — отметить отсутствие'**
  String get rowPresentHint;

  /// No description provided for @rowAbsentHint.
  ///
  /// In ru, this message translates to:
  /// **'Двойное касание — отметить присутствие'**
  String get rowAbsentHint;

  /// No description provided for @actionCodes.
  ///
  /// In ru, this message translates to:
  /// **'Коды посещаемости'**
  String get actionCodes;

  /// No description provided for @codesTitle.
  ///
  /// In ru, this message translates to:
  /// **'{name}'**
  String codesTitle(String name);

  /// No description provided for @codeLate.
  ///
  /// In ru, this message translates to:
  /// **'Опоздал'**
  String get codeLate;

  /// No description provided for @codeLateMinutes.
  ///
  /// In ru, this message translates to:
  /// **'На сколько минут'**
  String get codeLateMinutes;

  /// No description provided for @codeCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своё'**
  String get codeCustom;

  /// No description provided for @codeSick.
  ///
  /// In ru, this message translates to:
  /// **'Болеет'**
  String get codeSick;

  /// No description provided for @codeExcused.
  ///
  /// In ru, this message translates to:
  /// **'Уважительная'**
  String get codeExcused;

  /// No description provided for @codePresent.
  ///
  /// In ru, this message translates to:
  /// **'Есть'**
  String get codePresent;

  /// No description provided for @codeAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Отсутствует'**
  String get codeAbsent;

  /// No description provided for @lessonStartedToast.
  ///
  /// In ru, this message translates to:
  /// **'Урок начат'**
  String get lessonStartedToast;

  /// No description provided for @padOf.
  ///
  /// In ru, this message translates to:
  /// **'{n} из {total}'**
  String padOf(int n, int total);

  /// No description provided for @padComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий'**
  String get padComment;

  /// No description provided for @padCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'Привяжется к следующей оценке'**
  String get padCommentHint;

  /// No description provided for @padAbsentWarn.
  ///
  /// In ru, this message translates to:
  /// **'{name} отмечен «Н». Поставить оценку?'**
  String padAbsentWarn(String name);

  /// No description provided for @padPut.
  ///
  /// In ru, this message translates to:
  /// **'Поставить'**
  String get padPut;

  /// No description provided for @padRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Оценка снята'**
  String get padRemoved;

  /// No description provided for @padKey.
  ///
  /// In ru, this message translates to:
  /// **'Поставить {v}, {tone}'**
  String padKey(String v, String tone);

  /// No description provided for @padSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String padSelected(int count);

  /// No description provided for @padPrev.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий ученик'**
  String get padPrev;

  /// No description provided for @padNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующий ученик'**
  String get padNext;

  /// No description provided for @gradeSlot.
  ///
  /// In ru, this message translates to:
  /// **'Оценка: {name}'**
  String gradeSlot(String name);

  /// No description provided for @gradeLocked.
  ///
  /// In ru, this message translates to:
  /// **'Оценки закрыты'**
  String get gradeLocked;

  /// No description provided for @scaleViewOnly.
  ///
  /// In ru, this message translates to:
  /// **'Эту шкалу выставляют в веб-журнале'**
  String get scaleViewOnly;

  /// No description provided for @selectMode.
  ///
  /// In ru, this message translates to:
  /// **'Выбор учеников'**
  String get selectMode;

  /// No description provided for @workType.
  ///
  /// In ru, this message translates to:
  /// **'Вид работы'**
  String get workType;

  /// No description provided for @menuMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get menuMore;

  /// No description provided for @menuGradeAll.
  ///
  /// In ru, this message translates to:
  /// **'Оценить всех'**
  String get menuGradeAll;

  /// No description provided for @menuOpenWeb.
  ///
  /// In ru, this message translates to:
  /// **'Открыть журнал в вебе'**
  String get menuOpenWeb;

  /// No description provided for @menuStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать урок'**
  String get menuStart;

  /// No description provided for @jointPill.
  ///
  /// In ru, this message translates to:
  /// **'совмещённый · {count}'**
  String jointPill(int count);

  /// No description provided for @classHeader.
  ///
  /// In ru, this message translates to:
  /// **'{cls} · {count}'**
  String classHeader(String cls, int count);

  /// No description provided for @rosterEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В классе нет учеников'**
  String get rosterEmpty;

  /// No description provided for @hwSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Задание для {cls}'**
  String hwSheetTitle(String cls);

  /// No description provided for @hwTextHint.
  ///
  /// In ru, this message translates to:
  /// **'Параграф 12, номера 3–7'**
  String get hwTextHint;

  /// No description provided for @hwDue.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get hwDue;

  /// No description provided for @hwDueNextLesson.
  ///
  /// In ru, this message translates to:
  /// **'Следующий урок · {date}'**
  String hwDueNextLesson(String date);

  /// No description provided for @hwTime.
  ///
  /// In ru, this message translates to:
  /// **'Время на выполнение'**
  String get hwTime;

  /// No description provided for @hwLoad.
  ///
  /// In ru, this message translates to:
  /// **'{day}: уже {used} из {norm} мин'**
  String hwLoad(String day, int used, int norm);

  /// No description provided for @hwOverNorm.
  ///
  /// In ru, this message translates to:
  /// **'больше нормы на {m} мин'**
  String hwOverNorm(int m);

  /// No description provided for @hwAssign.
  ///
  /// In ru, this message translates to:
  /// **'Задать'**
  String get hwAssign;

  /// No description provided for @hwAssigned.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ задано · {cls}'**
  String hwAssigned(String cls);

  /// No description provided for @hwExisting.
  ///
  /// In ru, this message translates to:
  /// **'Уже задано'**
  String get hwExisting;

  /// No description provided for @hwFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось задать ДЗ'**
  String get hwFailed;

  /// No description provided for @hwOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети — задание уйдёт, когда появится связь'**
  String get hwOffline;

  /// No description provided for @hwOtherDate.
  ///
  /// In ru, this message translates to:
  /// **'Другая дата'**
  String get hwOtherDate;

  /// No description provided for @sumTitle.
  ///
  /// In ru, this message translates to:
  /// **'Итог урока'**
  String get sumTitle;

  /// No description provided for @sumAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость · {n} из {m}'**
  String sumAttendance(int n, int m);

  /// No description provided for @sumTopic.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get sumTopic;

  /// No description provided for @sumHomework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ'**
  String get sumHomework;

  /// No description provided for @sumGrades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки · {count}'**
  String sumGrades(int count);

  /// No description provided for @sumField.
  ///
  /// In ru, this message translates to:
  /// **'Итог урока, необязательно'**
  String get sumField;

  /// No description provided for @lessonFinishedToast.
  ///
  /// In ru, this message translates to:
  /// **'Урок завершён'**
  String get lessonFinishedToast;

  /// No description provided for @syncTitle.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get syncTitle;

  /// No description provided for @syncLast.
  ///
  /// In ru, this message translates to:
  /// **'Последняя отправка в {time}'**
  String syncLast(String time);

  /// No description provided for @syncRejected.
  ///
  /// In ru, this message translates to:
  /// **'Отклонено · {count}'**
  String syncRejected(int count);

  /// No description provided for @syncWaiting.
  ///
  /// In ru, this message translates to:
  /// **'Ждут сети · {count}'**
  String syncWaiting(int count);

  /// No description provided for @syncAllSent.
  ///
  /// In ru, this message translates to:
  /// **'Всё отправлено'**
  String get syncAllSent;

  /// No description provided for @syncAllSentHint.
  ///
  /// In ru, this message translates to:
  /// **'Отметки, оценки и темы уже на сервере'**
  String get syncAllSentHint;

  /// No description provided for @syncDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить запись?'**
  String get syncDeleteConfirm;

  /// No description provided for @syncDeleteBody.
  ///
  /// In ru, this message translates to:
  /// **'Она пропадёт без отправки'**
  String get syncDeleteBody;

  /// No description provided for @syncSending.
  ///
  /// In ru, this message translates to:
  /// **'Отправляем'**
  String get syncSending;

  /// No description provided for @syncPendingN.
  ///
  /// In ru, this message translates to:
  /// **'Ждут отправки: {count}'**
  String syncPendingN(int count);

  /// No description provided for @syncRejectedN.
  ///
  /// In ru, this message translates to:
  /// **'Не сохранено: {count}'**
  String syncRejectedN(int count);

  /// No description provided for @whatAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость «{state}»'**
  String whatAttendance(String state);

  /// No description provided for @whatGrade.
  ///
  /// In ru, this message translates to:
  /// **'Оценка {v}'**
  String whatGrade(String v);

  /// No description provided for @whatGradeRemoved.
  ///
  /// In ru, this message translates to:
  /// **'Оценка снята'**
  String get whatGradeRemoved;

  /// No description provided for @whatTopic.
  ///
  /// In ru, this message translates to:
  /// **'Тема урока'**
  String get whatTopic;

  /// No description provided for @whatStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало урока'**
  String get whatStart;

  /// No description provided for @whatFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершение урока'**
  String get whatFinish;

  /// No description provided for @whatHomework.
  ///
  /// In ru, this message translates to:
  /// **'Домашнее задание'**
  String get whatHomework;

  /// No description provided for @whatAllPresent.
  ///
  /// In ru, this message translates to:
  /// **'Все на месте · {count}'**
  String whatAllPresent(int count);

  /// No description provided for @whatSummary.
  ///
  /// In ru, this message translates to:
  /// **'Итог урока'**
  String get whatSummary;

  /// No description provided for @createdAt.
  ///
  /// In ru, this message translates to:
  /// **'создано в {time}'**
  String createdAt(String time);

  /// No description provided for @inboxAction.
  ///
  /// In ru, this message translates to:
  /// **'Требует действия'**
  String get inboxAction;

  /// No description provided for @inboxSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get inboxSchedule;

  /// No description provided for @inboxOther.
  ///
  /// In ru, this message translates to:
  /// **'Остальное'**
  String get inboxOther;

  /// No description provided for @inboxEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Входящих нет'**
  String get inboxEmpty;

  /// No description provided for @inboxEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь будут уроки без отметки, отклонённые записи, замены и объявления'**
  String get inboxEmptyHint;

  /// No description provided for @inboxRejected.
  ///
  /// In ru, this message translates to:
  /// **'Записи не сохранены'**
  String get inboxRejected;

  /// No description provided for @inboxRejectedSub.
  ///
  /// In ru, this message translates to:
  /// **'Откройте очередь, чтобы повторить или удалить'**
  String get inboxRejectedSub;

  /// No description provided for @inboxExcuses.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} заявка на отсутствие} few{{count} заявки на отсутствие} other{{count} заявок на отсутствие}}'**
  String inboxExcuses(int count);

  /// No description provided for @inboxExcusesSub.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить или отклонить можно в веб-версии'**
  String get inboxExcusesSub;

  /// No description provided for @markRead.
  ///
  /// In ru, this message translates to:
  /// **'Прочитано'**
  String get markRead;

  /// No description provided for @markAllRead.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать всё'**
  String get markAllRead;

  /// No description provided for @notifEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Уведомлений нет'**
  String get notifEmpty;

  /// No description provided for @notifEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь будут оценки, задания, замены и решения по заявкам'**
  String get notifEmptyHint;

  /// No description provided for @notifUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Запись удалена или недоступна'**
  String get notifUnavailable;

  /// No description provided for @notifUnavailableHint.
  ///
  /// In ru, this message translates to:
  /// **'Возможно, её изменили в школе. Остальное в приложении работает как обычно'**
  String get notifUnavailableHint;

  /// No description provided for @ntGradeCreated.
  ///
  /// In ru, this message translates to:
  /// **'Новая оценка'**
  String get ntGradeCreated;

  /// No description provided for @ntGradeUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Оценка изменена'**
  String get ntGradeUpdated;

  /// No description provided for @ntHomework.
  ///
  /// In ru, this message translates to:
  /// **'Домашнее задание'**
  String get ntHomework;

  /// No description provided for @ntHomeworkReminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание о задании'**
  String get ntHomeworkReminder;

  /// No description provided for @ntLessonCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Урок отменён'**
  String get ntLessonCancelled;

  /// No description provided for @ntLessonRescheduled.
  ///
  /// In ru, this message translates to:
  /// **'Урок перенесён'**
  String get ntLessonRescheduled;

  /// No description provided for @ntSubstitution.
  ///
  /// In ru, this message translates to:
  /// **'Замена'**
  String get ntSubstitution;

  /// No description provided for @ntLessonStarted.
  ///
  /// In ru, this message translates to:
  /// **'Урок начался'**
  String get ntLessonStarted;

  /// No description provided for @ntCheckIn.
  ///
  /// In ru, this message translates to:
  /// **'Ребёнок пришёл в школу'**
  String get ntCheckIn;

  /// No description provided for @ntAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость'**
  String get ntAttendance;

  /// No description provided for @ntUnmarked.
  ///
  /// In ru, this message translates to:
  /// **'Отметьте посещаемость'**
  String get ntUnmarked;

  /// No description provided for @ntGradesReminder.
  ///
  /// In ru, this message translates to:
  /// **'Поставьте оценки'**
  String get ntGradesReminder;

  /// No description provided for @ntExcusePending.
  ///
  /// In ru, this message translates to:
  /// **'Новая заявка'**
  String get ntExcusePending;

  /// No description provided for @ntExcuseApproved.
  ///
  /// In ru, this message translates to:
  /// **'Заявка одобрена'**
  String get ntExcuseApproved;

  /// No description provided for @ntExcuseRejected.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отклонена'**
  String get ntExcuseRejected;

  /// No description provided for @ntExcuseCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отозвана'**
  String get ntExcuseCancelled;

  /// No description provided for @ntInvoice.
  ///
  /// In ru, this message translates to:
  /// **'Счёт на оплату'**
  String get ntInvoice;

  /// No description provided for @ntEvent.
  ///
  /// In ru, this message translates to:
  /// **'Событие школы'**
  String get ntEvent;

  /// No description provided for @ntChat.
  ///
  /// In ru, this message translates to:
  /// **'Новое сообщение'**
  String get ntChat;

  /// No description provided for @ntOther.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get ntOther;
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
