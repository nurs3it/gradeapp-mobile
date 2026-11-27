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
  /// **'Объяснить пропуск'**
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

  /// No description provided for @ngGrades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки'**
  String get ngGrades;

  /// No description provided for @ngHomework.
  ///
  /// In ru, this message translates to:
  /// **'Задания'**
  String get ngHomework;

  /// No description provided for @ngSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание и замены'**
  String get ngSchedule;

  /// No description provided for @ngAttendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость и приход в школу'**
  String get ngAttendance;

  /// No description provided for @ngChat.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get ngChat;

  /// No description provided for @ngBilling.
  ///
  /// In ru, this message translates to:
  /// **'Оплата'**
  String get ngBilling;

  /// No description provided for @ngGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Важное'**
  String get ngGeneral;

  /// No description provided for @pushAskTitle.
  ///
  /// In ru, this message translates to:
  /// **'Включить уведомления?'**
  String get pushAskTitle;

  /// No description provided for @pushAskAllow.
  ///
  /// In ru, this message translates to:
  /// **'Включить'**
  String get pushAskAllow;

  /// No description provided for @pushWhyStudent.
  ///
  /// In ru, this message translates to:
  /// **'Сразу узнаешь о новой оценке, задании или замене урока.'**
  String get pushWhyStudent;

  /// No description provided for @pushWhyParent.
  ///
  /// In ru, this message translates to:
  /// **'Узнавайте сразу, когда ребёнок пришёл в школу, получил оценку или пропустил урок. Сами оценки на заблокированном экране не показываются.'**
  String get pushWhyParent;

  /// No description provided for @pushWhyTeacher.
  ///
  /// In ru, this message translates to:
  /// **'Напомним о неотмеченной посещаемости и сообщим о заменах и новых заявках.'**
  String get pushWhyTeacher;

  /// No description provided for @notifSettings.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifSettings;

  /// No description provided for @notifSettingsHint.
  ///
  /// In ru, this message translates to:
  /// **'В колокольчике приложения видно всё. Здесь — что приходит пушем на телефон.'**
  String get notifSettingsHint;

  /// No description provided for @pushOffTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления выключены в настройках телефона'**
  String get pushOffTitle;

  /// No description provided for @pushOffOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get pushOffOpen;

  /// No description provided for @pushTurnOn.
  ///
  /// In ru, this message translates to:
  /// **'Включить уведомления'**
  String get pushTurnOn;

  /// No description provided for @pushUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'В этой сборке пуши недоступны'**
  String get pushUnavailable;

  /// No description provided for @notifOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get notifOpen;

  /// No description provided for @presenceOnline.
  ///
  /// In ru, this message translates to:
  /// **'В сети'**
  String get presenceOnline;

  /// No description provided for @lockSetting.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка приложения'**
  String get lockSetting;

  /// No description provided for @lockSettingHint.
  ///
  /// In ru, this message translates to:
  /// **'Face ID, отпечаток или код телефона при запуске и после 5 минут в фоне'**
  String get lockSettingHint;

  /// No description provided for @lockReason.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите, что это вы'**
  String get lockReason;

  /// No description provided for @lockTitle.
  ///
  /// In ru, this message translates to:
  /// **'GradeApp заблокирован'**
  String get lockTitle;

  /// No description provided for @lockUnlock.
  ///
  /// In ru, this message translates to:
  /// **'Разблокировать'**
  String get lockUnlock;

  /// No description provided for @lockUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Включите Face ID, отпечаток или код-пароль в настройках телефона'**
  String get lockUnavailable;

  /// No description provided for @reportCardRow.
  ///
  /// In ru, this message translates to:
  /// **'Табель за {term}'**
  String reportCardRow(String term);

  /// No description provided for @reportCardHint.
  ///
  /// In ru, this message translates to:
  /// **'PDF · отправить или сохранить'**
  String get reportCardHint;

  /// No description provided for @reportCardPreparing.
  ///
  /// In ru, this message translates to:
  /// **'Готовим табель…'**
  String get reportCardPreparing;

  /// No description provided for @reportCardOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети — табель не скачать. Попробуйте, когда появится интернет.'**
  String get reportCardOffline;

  /// No description provided for @reportCardDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к табелю'**
  String get reportCardDenied;

  /// No description provided for @reportCardFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить табель. Попробуйте ещё раз.'**
  String get reportCardFailed;

  /// No description provided for @feedbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отзывы учителей'**
  String get feedbackTitle;

  /// No description provided for @feedbackPraise.
  ///
  /// In ru, this message translates to:
  /// **'Похвала'**
  String get feedbackPraise;

  /// No description provided for @feedbackRemark.
  ///
  /// In ru, this message translates to:
  /// **'Замечание'**
  String get feedbackRemark;

  /// No description provided for @feedbackAction.
  ///
  /// In ru, this message translates to:
  /// **'Отзыв ученику'**
  String get feedbackAction;

  /// No description provided for @feedbackSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отзыв: {name}'**
  String feedbackSheetTitle(String name);

  /// No description provided for @feedbackHint.
  ///
  /// In ru, this message translates to:
  /// **'Что получилось или над чем стоит поработать'**
  String get feedbackHint;

  /// No description provided for @feedbackSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить отзыв'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In ru, this message translates to:
  /// **'Отзыв для {name} отправляется'**
  String feedbackSent(String name);

  /// No description provided for @whatFeedback.
  ///
  /// In ru, this message translates to:
  /// **'Отзыв ученику'**
  String get whatFeedback;

  /// No description provided for @hwAttachCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get hwAttachCamera;

  /// No description provided for @hwAttachPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get hwAttachPhoto;

  /// No description provided for @hwAttachFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл'**
  String get hwAttachFile;

  /// No description provided for @hwRemoveFile.
  ///
  /// In ru, this message translates to:
  /// **'Убрать {name}'**
  String hwRemoveFile(String name);

  /// No description provided for @hwFileTooBig.
  ///
  /// In ru, this message translates to:
  /// **'{name} больше 10 МБ — не прикреплён'**
  String hwFileTooBig(String name);

  /// No description provided for @hwUploading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаем файлы ({done} из {total})…'**
  String hwUploading(int done, int total);

  /// No description provided for @hwFilesFailed.
  ///
  /// In ru, this message translates to:
  /// **'Задание выдано, но не загрузились файлы: {n}. Прикрепите их позже на сайте.'**
  String hwFilesFailed(int n);

  /// No description provided for @hwFilesOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети: задание сохранено без файлов и уйдёт позже. Файлы прикрепите, когда появится интернет.'**
  String get hwFilesOffline;

  /// No description provided for @hwFilesError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выдать задание. Попробуйте ещё раз.'**
  String get hwFilesError;

  /// No description provided for @attachmentOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть файл'**
  String get attachmentOpenFailed;

  /// No description provided for @actApprove.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить'**
  String get actApprove;

  /// No description provided for @excuseApprovedToast.
  ///
  /// In ru, this message translates to:
  /// **'Заявка одобрена'**
  String get excuseApprovedToast;

  /// No description provided for @excuseApproveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось одобрить заявку'**
  String get excuseApproveFailed;

  /// No description provided for @liveNow.
  ///
  /// In ru, this message translates to:
  /// **'Идёт урок'**
  String get liveNow;

  /// No description provided for @liveMarked.
  ///
  /// In ru, this message translates to:
  /// **'Отмечено {done}/{total}'**
  String liveMarked(int done, int total);

  /// No description provided for @liveEnded.
  ///
  /// In ru, this message translates to:
  /// **'Урок закончен'**
  String get liveEnded;

  /// No description provided for @liveEndedTopic.
  ///
  /// In ru, this message translates to:
  /// **'Урок закончен: не заполнена тема'**
  String get liveEndedTopic;

  /// No description provided for @liveUntilBell.
  ///
  /// In ru, this message translates to:
  /// **'До звонка'**
  String get liveUntilBell;

  /// No description provided for @notifPublicTitle.
  ///
  /// In ru, this message translates to:
  /// **'GradeApp'**
  String get notifPublicTitle;

  /// No description provided for @notifPublicBody.
  ///
  /// In ru, this message translates to:
  /// **'Новое уведомление'**
  String get notifPublicBody;

  /// Status-bar chip of the Android 16 Live Update: minutes to the bell
  ///
  /// In ru, this message translates to:
  /// **'{n} мин'**
  String liveShortMinutes(int n);

  /// No description provided for @liveChannel.
  ///
  /// In ru, this message translates to:
  /// **'Идёт урок'**
  String get liveChannel;

  /// No description provided for @remChannel.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get remChannel;

  /// No description provided for @remTitle.
  ///
  /// In ru, this message translates to:
  /// **'{cls}: посещаемость не отмечена'**
  String remTitle(String cls);

  /// No description provided for @remBody.
  ///
  /// In ru, this message translates to:
  /// **'{subject}, {start}–{end}'**
  String remBody(String subject, String start, String end);

  /// No description provided for @wgNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующий урок'**
  String get wgNext;

  /// No description provided for @wgNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get wgNow;

  /// No description provided for @wgDay.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get wgDay;

  /// No description provided for @wgUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено {time}'**
  String wgUpdated(String time);

  /// No description provided for @wgStale.
  ///
  /// In ru, this message translates to:
  /// **'Откройте приложение, чтобы обновить'**
  String get wgStale;

  /// No description provided for @wgNoMore.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков больше нет'**
  String get wgNoMore;

  /// No description provided for @wgNoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уроков нет'**
  String get wgNoLessons;

  /// No description provided for @wgHomeworkTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ на завтра'**
  String get wgHomeworkTomorrow;

  /// No description provided for @wgNoHomework.
  ///
  /// In ru, this message translates to:
  /// **'На завтра ничего не задано'**
  String get wgNoHomework;

  /// No description provided for @wgSignedOut.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в GradeApp'**
  String get wgSignedOut;

  /// No description provided for @wgTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get wgTomorrow;

  /// No description provided for @wgStartsIn.
  ///
  /// In ru, this message translates to:
  /// **'Начнётся через'**
  String get wgStartsIn;

  /// No description provided for @wgEndsIn.
  ///
  /// In ru, this message translates to:
  /// **'До конца'**
  String get wgEndsIn;

  /// No description provided for @setLocalTitle.
  ///
  /// In ru, this message translates to:
  /// **'На этом телефоне'**
  String get setLocalTitle;

  /// No description provided for @setReminders.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания об отметке посещаемости'**
  String get setReminders;

  /// No description provided for @setLive.
  ///
  /// In ru, this message translates to:
  /// **'«Идёт урок» на экране блокировки'**
  String get setLive;

  /// No description provided for @ntCheckInMissing.
  ///
  /// In ru, this message translates to:
  /// **'Не отметился в школе'**
  String get ntCheckInMissing;

  /// No description provided for @wgNextShort.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get wgNextShort;

  /// No description provided for @s7Title.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз'**
  String get s7Title;

  /// No description provided for @s7Now.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get s7Now;

  /// No description provided for @s7NowLine.
  ///
  /// In ru, this message translates to:
  /// **'{pct} % · отметка {mark}'**
  String s7NowLine(String pct, String mark);

  /// No description provided for @s7NextWork.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшая работа: {title}, {date}'**
  String s7NextWork(String title, String date);

  /// No description provided for @s7MaxScore.
  ///
  /// In ru, this message translates to:
  /// **'Максимум баллов за работу'**
  String get s7MaxScore;

  /// No description provided for @s7Less.
  ///
  /// In ru, this message translates to:
  /// **'Меньше баллов'**
  String get s7Less;

  /// No description provided for @s7More.
  ///
  /// In ru, this message translates to:
  /// **'Больше баллов'**
  String get s7More;

  /// No description provided for @s7Need.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы выйти на {mark}, нужно на {kind} набрать не меньше {need} из {max}'**
  String s7Need(String mark, String kind, int need, int max);

  /// No description provided for @s7NoStep.
  ///
  /// In ru, this message translates to:
  /// **'Эта работа оценку уже не поднимет, но она всё равно важна: пусть получится как можно лучше.'**
  String get s7NoStep;

  /// No description provided for @s7Top.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас у вас самая высокая отметка. Так держать!'**
  String get s7Top;

  /// No description provided for @s7IfIGet.
  ///
  /// In ru, this message translates to:
  /// **'Если получу на {kind} {score} из {max}'**
  String s7IfIGet(String kind, int score, int max);

  /// No description provided for @s7Result.
  ///
  /// In ru, this message translates to:
  /// **'Четвертная: {mark} ({pct} %)'**
  String s7Result(String mark, String pct);

  /// No description provided for @s7Disclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Это примерный расчёт по формуле школы. Итог поставит учитель.'**
  String get s7Disclaimer;

  /// No description provided for @s7Hidden.
  ///
  /// In ru, this message translates to:
  /// **'Прогноз пока недоступен'**
  String get s7Hidden;

  /// No description provided for @s7HiddenFormula.
  ///
  /// In ru, this message translates to:
  /// **'Формула школы ещё не загрузилась. Попробуйте позже.'**
  String get s7HiddenFormula;

  /// No description provided for @s7HiddenFew.
  ///
  /// In ru, this message translates to:
  /// **'Нужно хотя бы {count} оценённые работы, чтобы прогноз был честным.'**
  String s7HiddenFew(int count);

  /// No description provided for @s10Title.
  ///
  /// In ru, this message translates to:
  /// **'Серии и достижения'**
  String get s10Title;

  /// No description provided for @s10Unavailable.
  ///
  /// In ru, this message translates to:
  /// **'Серии в вашей школе не включены.'**
  String get s10Unavailable;

  /// No description provided for @s10ParentOff.
  ///
  /// In ru, this message translates to:
  /// **'Серии отключили родители. Это нормально, на учёбу это не влияет.'**
  String get s10ParentOff;

  /// No description provided for @s10CardStart.
  ///
  /// In ru, this message translates to:
  /// **'Серия вовремя: начните с сегодняшнего дня'**
  String get s10CardStart;

  /// No description provided for @s10CardCheckin.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день вовремя} few{{count} дня вовремя} other{{count} дней вовремя}}'**
  String s10CardCheckin(int count);

  /// No description provided for @s10CardHomework.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{ДЗ в срок: {count} день} few{ДЗ в срок: {count} дня} other{ДЗ в срок: {count} дней}}'**
  String s10CardHomework(int count);

  /// No description provided for @s10Days.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день} few{{count} дня} other{{count} дней}}'**
  String s10Days(int count);

  /// No description provided for @s10DaysShort.
  ///
  /// In ru, this message translates to:
  /// **'дн.'**
  String get s10DaysShort;

  /// No description provided for @s10Best.
  ///
  /// In ru, this message translates to:
  /// **'Лучшая: {count}'**
  String s10Best(int count);

  /// No description provided for @s10FreezesLeft.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{осталась {count} заморозка} few{осталось {count} заморозки} other{осталось {count} заморозок}}'**
  String s10FreezesLeft(int count);

  /// No description provided for @s10KindCheckin.
  ///
  /// In ru, this message translates to:
  /// **'Вовремя в школе'**
  String get s10KindCheckin;

  /// No description provided for @s10KindHomework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ в срок'**
  String get s10KindHomework;

  /// No description provided for @s10TodayDoneCheckin.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня отмечено'**
  String get s10TodayDoneCheckin;

  /// No description provided for @s10TodayDoneHomework.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня всё сдано в срок'**
  String get s10TodayDoneHomework;

  /// No description provided for @s10TodayPending.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня ещё можно успеть'**
  String get s10TodayPending;

  /// No description provided for @s10TodayFrozen.
  ///
  /// In ru, this message translates to:
  /// **'День заморожен: серия сохранена'**
  String get s10TodayFrozen;

  /// No description provided for @s10TodayExcused.
  ///
  /// In ru, this message translates to:
  /// **'Есть заявка: серия на паузе'**
  String get s10TodayExcused;

  /// No description provided for @s10TodayOff.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня не учебный день'**
  String get s10TodayOff;

  /// No description provided for @s10TodayMissed.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня не засчитано — день можно заморозить'**
  String get s10TodayMissed;

  /// No description provided for @s10ExcusedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Заявка принята.'**
  String get s10ExcusedTitle;

  /// No description provided for @s10ExcusedBody.
  ///
  /// In ru, this message translates to:
  /// **'Серия не прерывается и не растёт: просто ждёт вас.'**
  String get s10ExcusedBody;

  /// No description provided for @s10Milestones.
  ///
  /// In ru, this message translates to:
  /// **'Страницы знака'**
  String get s10Milestones;

  /// No description provided for @s10MilestoneReached.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, other{Достигнуто: {days} дней}}'**
  String s10MilestoneReached(int days);

  /// No description provided for @s10MilestoneAhead.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, other{Впереди: {days} дней}}'**
  String s10MilestoneAhead(int days);

  /// No description provided for @s10MilestoneToday.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, other{{days} дней вовремя: раскрылась ещё одна страница}}'**
  String s10MilestoneToday(int days);

  /// No description provided for @s10Missed.
  ///
  /// In ru, this message translates to:
  /// **'Пропущенные дни'**
  String get s10Missed;

  /// No description provided for @s10MissedHint.
  ///
  /// In ru, this message translates to:
  /// **'Заморозка возвращает день в серию. Её можно использовать в течение суток.'**
  String get s10MissedHint;

  /// No description provided for @s10Freeze.
  ///
  /// In ru, this message translates to:
  /// **'Заморозить'**
  String get s10Freeze;

  /// No description provided for @s10Frozen.
  ///
  /// In ru, this message translates to:
  /// **'День заморожен'**
  String get s10Frozen;

  /// No description provided for @s10FreezeExpired.
  ///
  /// In ru, this message translates to:
  /// **'Время для заморозки вышло'**
  String get s10FreezeExpired;

  /// No description provided for @s10NoFreezes.
  ///
  /// In ru, this message translates to:
  /// **'Заморозки на эту четверть закончились'**
  String get s10NoFreezes;

  /// No description provided for @s10SickNote.
  ///
  /// In ru, this message translates to:
  /// **'Болеешь — оставайся дома: заявка серию не прерывает.'**
  String get s10SickNote;

  /// No description provided for @s10ParentSwitch.
  ///
  /// In ru, this message translates to:
  /// **'Серии и достижения'**
  String get s10ParentSwitch;

  /// No description provided for @s10ParentExplain.
  ///
  /// In ru, this message translates to:
  /// **'Приложение отмечает, пришёл ли ученик вовремя и сдал ли ДЗ. Это видно ученику и родителям, не видно другим ученикам и сотрудникам. Заявка по болезни серию не прерывает.'**
  String get s10ParentExplain;

  /// No description provided for @s11Title.
  ///
  /// In ru, this message translates to:
  /// **'Твоя неделя'**
  String get s11Title;

  /// No description provided for @s11DaysOnTime.
  ///
  /// In ru, this message translates to:
  /// **'дней вовремя'**
  String get s11DaysOnTime;

  /// No description provided for @s11Homework.
  ///
  /// In ru, this message translates to:
  /// **'ДЗ сдано'**
  String get s11Homework;

  /// No description provided for @s11Milestone.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, other{{days} дней вовремя: новая страница}}'**
  String s11Milestone(int days);

  /// No description provided for @s11WithMarks.
  ///
  /// In ru, this message translates to:
  /// **'Показать оценки в картинке'**
  String get s11WithMarks;

  /// No description provided for @s11MarksWarning.
  ///
  /// In ru, this message translates to:
  /// **'В карточке будут оценки. Поделившись ей, вы сделаете их видимыми другим людям.'**
  String get s11MarksWarning;

  /// No description provided for @s11Save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить картинкой'**
  String get s11Save;

  /// No description provided for @p5Title.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость'**
  String get p5Title;

  /// No description provided for @p5RowHint.
  ///
  /// In ru, this message translates to:
  /// **'Календарь, пропуски и причины'**
  String get p5RowHint;

  /// No description provided for @p5Quarter.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость · {name}'**
  String p5Quarter(String name);

  /// No description provided for @p5CountAbsent.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} пропуск} few{{count} пропуска} other{{count} пропусков}}'**
  String p5CountAbsent(int count);

  /// No description provided for @p5CountTardy.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} опоздание} few{{count} опоздания} other{{count} опозданий}}'**
  String p5CountTardy(int count);

  /// No description provided for @p5CountExcused.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} по заявке} few{{count} по заявке} other{{count} по заявкам}}'**
  String p5CountExcused(int count);

  /// No description provided for @p5NoMisses.
  ///
  /// In ru, this message translates to:
  /// **'Без пропусков'**
  String get p5NoMisses;

  /// No description provided for @p5PrevMonth.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий месяц'**
  String get p5PrevMonth;

  /// No description provided for @p5NextMonth.
  ///
  /// In ru, this message translates to:
  /// **'Следующий месяц'**
  String get p5NextMonth;

  /// No description provided for @p5Present.
  ///
  /// In ru, this message translates to:
  /// **'Был'**
  String get p5Present;

  /// No description provided for @p5Tardy.
  ///
  /// In ru, this message translates to:
  /// **'Опоздание'**
  String get p5Tardy;

  /// No description provided for @p5Absent.
  ///
  /// In ru, this message translates to:
  /// **'Пропуск'**
  String get p5Absent;

  /// No description provided for @p5Excused.
  ///
  /// In ru, this message translates to:
  /// **'По заявке'**
  String get p5Excused;

  /// No description provided for @p5NoLessons.
  ///
  /// In ru, this message translates to:
  /// **'Уроков нет'**
  String get p5NoLessons;

  /// No description provided for @p5Absences.
  ///
  /// In ru, this message translates to:
  /// **'Пропуски месяца'**
  String get p5Absences;

  /// No description provided for @p5NoReason.
  ///
  /// In ru, this message translates to:
  /// **'причина не указана'**
  String get p5NoReason;

  /// No description provided for @p6Title.
  ///
  /// In ru, this message translates to:
  /// **'Итоги недели'**
  String get p6Title;

  /// No description provided for @p6OpenSummary.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get p6OpenSummary;

  /// No description provided for @p6PrevWeek.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущая неделя'**
  String get p6PrevWeek;

  /// No description provided for @p6NextWeek.
  ///
  /// In ru, this message translates to:
  /// **'Следующая неделя'**
  String get p6NextWeek;

  /// No description provided for @p6WeekOf.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {range}'**
  String p6WeekOf(String range);

  /// No description provided for @p6EmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Учебных дней не было'**
  String get p6EmptyTitle;

  /// No description provided for @p6EmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе сводки нет: каникулы или выходные.'**
  String get p6EmptyBody;

  /// No description provided for @p6VerdictEmpty.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе уроков не было.'**
  String get p6VerdictEmpty;

  /// No description provided for @p6VerdictGreat.
  ///
  /// In ru, this message translates to:
  /// **'Отличная неделя: все дни вовремя, задания сданы.'**
  String get p6VerdictGreat;

  /// No description provided for @p6VerdictSteady.
  ///
  /// In ru, this message translates to:
  /// **'Неделя прошла ровно.'**
  String get p6VerdictSteady;

  /// No description provided for @p6VerdictAbsences.
  ///
  /// In ru, this message translates to:
  /// **'Есть пропуск без причины: его можно объяснить.'**
  String get p6VerdictAbsences;

  /// No description provided for @p6VerdictOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Есть задания, которые пока не сданы.'**
  String get p6VerdictOverdue;

  /// No description provided for @p6VerdictDip.
  ///
  /// In ru, this message translates to:
  /// **'Неделя ровная, просела отметка по предмету «{course}».'**
  String p6VerdictDip(String course);

  /// No description provided for @p6VerdictDipPlain.
  ///
  /// In ru, this message translates to:
  /// **'Неделя ровная, по одному предмету отметка просела.'**
  String get p6VerdictDipPlain;

  /// No description provided for @p6Attendance.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость'**
  String get p6Attendance;

  /// No description provided for @p6DaysOnTime.
  ///
  /// In ru, this message translates to:
  /// **'Дней вовремя'**
  String get p6DaysOnTime;

  /// No description provided for @p6OfDays.
  ///
  /// In ru, this message translates to:
  /// **'{ontime} из {days}'**
  String p6OfDays(int ontime, int days);

  /// No description provided for @p6Tardy.
  ///
  /// In ru, this message translates to:
  /// **'Опоздания'**
  String get p6Tardy;

  /// No description provided for @p6Absent.
  ///
  /// In ru, this message translates to:
  /// **'Пропуски без причины'**
  String get p6Absent;

  /// No description provided for @p6Excused.
  ///
  /// In ru, this message translates to:
  /// **'По заявке'**
  String get p6Excused;

  /// No description provided for @p6Grades.
  ///
  /// In ru, this message translates to:
  /// **'Оценки по предметам'**
  String get p6Grades;

  /// No description provided for @p6GradesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} оценка} few{{count} оценки} other{{count} оценок}}'**
  String p6GradesCount(int count);

  /// No description provided for @p6Avg.
  ///
  /// In ru, this message translates to:
  /// **'средняя {value}'**
  String p6Avg(String value);

  /// No description provided for @p6Up.
  ///
  /// In ru, this message translates to:
  /// **'выше на {delta}'**
  String p6Up(String delta);

  /// No description provided for @p6Down.
  ///
  /// In ru, this message translates to:
  /// **'ниже на {delta}'**
  String p6Down(String delta);

  /// No description provided for @p6Same.
  ///
  /// In ru, this message translates to:
  /// **'без изменений'**
  String get p6Same;

  /// No description provided for @p6Homework.
  ///
  /// In ru, this message translates to:
  /// **'Домашние задания'**
  String get p6Homework;

  /// No description provided for @p6HwDone.
  ///
  /// In ru, this message translates to:
  /// **'Сдано'**
  String get p6HwDone;

  /// No description provided for @p6OfTotal.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total}'**
  String p6OfTotal(int done, int total);

  /// No description provided for @p6HwOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Не сдано в срок'**
  String get p6HwOverdue;

  /// No description provided for @p6Feedback.
  ///
  /// In ru, this message translates to:
  /// **'Отзывы учителей'**
  String get p6Feedback;

  /// No description provided for @p6Praise.
  ///
  /// In ru, this message translates to:
  /// **'Похвала'**
  String get p6Praise;

  /// No description provided for @p6Remark.
  ///
  /// In ru, this message translates to:
  /// **'Замечание'**
  String get p6Remark;

  /// No description provided for @p6Upcoming.
  ///
  /// In ru, this message translates to:
  /// **'На следующей неделе'**
  String get p6Upcoming;

  /// No description provided for @p6TodayCard.
  ///
  /// In ru, this message translates to:
  /// **'Итоги недели'**
  String get p6TodayCard;

  /// No description provided for @p6TodayCardHint.
  ///
  /// In ru, this message translates to:
  /// **'Как прошла неделя и о чём поговорить'**
  String get p6TodayCardHint;

  /// No description provided for @p6DigestWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда присылать итоги недели'**
  String get p6DigestWhen;

  /// No description provided for @p6DayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пятница'**
  String get p6DayFri;

  /// No description provided for @p6DaySun.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get p6DaySun;

  /// No description provided for @p6DigestHour.
  ///
  /// In ru, this message translates to:
  /// **'Время отправки'**
  String get p6DigestHour;

  /// No description provided for @ngDigest.
  ///
  /// In ru, this message translates to:
  /// **'Итоги недели'**
  String get ngDigest;

  /// No description provided for @ntDigest.
  ///
  /// In ru, this message translates to:
  /// **'Итоги недели'**
  String get ntDigest;

  /// No description provided for @ntConsentRequested.
  ///
  /// In ru, this message translates to:
  /// **'Запрос от ребёнка'**
  String get ntConsentRequested;

  /// No description provided for @p7Ask.
  ///
  /// In ru, this message translates to:
  /// **'Попросить родителя'**
  String get p7Ask;

  /// No description provided for @p7Sent.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправили запрос родителю.'**
  String get p7Sent;

  /// No description provided for @p7TooSoon.
  ///
  /// In ru, this message translates to:
  /// **'Вы уже просили. Попробуйте завтра.'**
  String get p7TooSoon;

  /// No description provided for @p7AlreadyGranted.
  ///
  /// In ru, this message translates to:
  /// **'Родитель уже разрешил. Обновите экран.'**
  String get p7AlreadyGranted;

  /// No description provided for @p8Title.
  ///
  /// In ru, this message translates to:
  /// **'Счета и оплата'**
  String get p8Title;

  /// No description provided for @p8ToPay.
  ///
  /// In ru, this message translates to:
  /// **'К оплате'**
  String get p8ToPay;

  /// No description provided for @p8History.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get p8History;

  /// No description provided for @p8Empty.
  ///
  /// In ru, this message translates to:
  /// **'Счетов пока нет'**
  String get p8Empty;

  /// No description provided for @p8EmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся счета за обучение.'**
  String get p8EmptyHint;

  /// No description provided for @p8InvoiceNo.
  ///
  /// In ru, this message translates to:
  /// **'Счёт № {number}'**
  String p8InvoiceNo(String number);

  /// No description provided for @p8DueDate.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String p8DueDate(String date);

  /// No description provided for @p8PaidSoFar.
  ///
  /// In ru, this message translates to:
  /// **'оплачено {amount} ₸'**
  String p8PaidSoFar(String amount);

  /// No description provided for @p8PayableSemantic.
  ///
  /// In ru, this message translates to:
  /// **'К оплате {amount} тенге, {due}'**
  String p8PayableSemantic(String amount, String due);

  /// No description provided for @p8StatusSent.
  ///
  /// In ru, this message translates to:
  /// **'К оплате'**
  String get p8StatusSent;

  /// No description provided for @p8StatusPartial.
  ///
  /// In ru, this message translates to:
  /// **'Оплачен частично'**
  String get p8StatusPartial;

  /// No description provided for @p8StatusPaid.
  ///
  /// In ru, this message translates to:
  /// **'Оплачен'**
  String get p8StatusPaid;

  /// No description provided for @p8StatusOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочен'**
  String get p8StatusOverdue;

  /// No description provided for @p8StatusCancelled.
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get p8StatusCancelled;

  /// No description provided for @p8Pay.
  ///
  /// In ru, this message translates to:
  /// **'Оплатить'**
  String get p8Pay;

  /// No description provided for @p8PayFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть оплату. Попробуйте ещё раз.'**
  String get p8PayFailed;

  /// No description provided for @p8PayUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-оплата у школы сейчас недоступна.'**
  String get p8PayUnavailable;

  /// No description provided for @p8ConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Перед оплатой'**
  String get p8ConfirmTitle;

  /// No description provided for @p8Confirm.
  ///
  /// In ru, this message translates to:
  /// **'Вы оплачиваете обучение напрямую школе «{name}», БИН {bin}. Сумма: {amount} ₸. GradeApp не получает и не передаёт деньги. Фискальный чек формирует школа или платёжный сервис.'**
  String p8Confirm(String name, String bin, String amount);

  /// No description provided for @p8ConfirmNoBin.
  ///
  /// In ru, this message translates to:
  /// **'Вы оплачиваете обучение напрямую школе «{name}». Сумма: {amount} ₸. GradeApp не получает и не передаёт деньги. Фискальный чек формирует школа или платёжный сервис.'**
  String p8ConfirmNoBin(String name, String amount);

  /// No description provided for @p8ConfirmGo.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к оплате'**
  String get p8ConfirmGo;

  /// No description provided for @p8Checking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяем оплату'**
  String get p8Checking;

  /// No description provided for @p8CheckingHint.
  ///
  /// In ru, this message translates to:
  /// **'Обычно это занимает меньше минуты.'**
  String get p8CheckingHint;

  /// No description provided for @p8Arrived.
  ///
  /// In ru, this message translates to:
  /// **'Оплата получена. Спасибо!'**
  String get p8Arrived;

  /// No description provided for @p8Delayed.
  ///
  /// In ru, this message translates to:
  /// **'Платёж пока не виден.'**
  String get p8Delayed;

  /// No description provided for @p8DelayedHint.
  ///
  /// In ru, this message translates to:
  /// **'Банк иногда подтверждает оплату дольше. Если деньги уже списаны, платить повторно не нужно: статус обновится сам.'**
  String get p8DelayedHint;

  /// No description provided for @p8CheckNow.
  ///
  /// In ru, this message translates to:
  /// **'Проверить'**
  String get p8CheckNow;

  /// No description provided for @p8OnlineOff.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн-оплаты нет.'**
  String get p8OnlineOff;

  /// No description provided for @p8OnlineOffHint.
  ///
  /// In ru, this message translates to:
  /// **'Оплатите переводом по реквизитам ниже.'**
  String get p8OnlineOffHint;

  /// No description provided for @p8Payments.
  ///
  /// In ru, this message translates to:
  /// **'Платежи'**
  String get p8Payments;

  /// No description provided for @p8MethodCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get p8MethodCash;

  /// No description provided for @p8MethodTransfer.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get p8MethodTransfer;

  /// No description provided for @p8HowToPay.
  ///
  /// In ru, this message translates to:
  /// **'Как оплатить переводом'**
  String get p8HowToPay;

  /// No description provided for @p8ReqRecipient.
  ///
  /// In ru, this message translates to:
  /// **'Получатель'**
  String get p8ReqRecipient;

  /// No description provided for @p8ReqBin.
  ///
  /// In ru, this message translates to:
  /// **'БИН'**
  String get p8ReqBin;

  /// No description provided for @p8ReqBank.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get p8ReqBank;

  /// No description provided for @p8ReqBik.
  ///
  /// In ru, this message translates to:
  /// **'БИК'**
  String get p8ReqBik;

  /// No description provided for @p8ReqKbe.
  ///
  /// In ru, this message translates to:
  /// **'КБе'**
  String get p8ReqKbe;

  /// No description provided for @p8ReqKnp.
  ///
  /// In ru, this message translates to:
  /// **'КНП'**
  String get p8ReqKnp;

  /// No description provided for @p8ReqPurpose.
  ///
  /// In ru, this message translates to:
  /// **'Назначение платежа'**
  String get p8ReqPurpose;

  /// No description provided for @p8PurposeValue.
  ///
  /// In ru, this message translates to:
  /// **'Оплата за обучение, счёт № {number}'**
  String p8PurposeValue(String number);

  /// No description provided for @p8Copy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get p8Copy;

  /// No description provided for @p8Copied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get p8Copied;

  /// No description provided for @p8Document.
  ///
  /// In ru, this message translates to:
  /// **'Документ'**
  String get p8Document;

  /// No description provided for @p8PdfTitle.
  ///
  /// In ru, this message translates to:
  /// **'Счёт на оплату'**
  String get p8PdfTitle;

  /// No description provided for @p8PdfCaption.
  ///
  /// In ru, this message translates to:
  /// **'Информационный документ, не является фискальным чеком'**
  String get p8PdfCaption;

  /// No description provided for @p8PdfFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить документ.'**
  String get p8PdfFailed;

  /// No description provided for @p9Title.
  ///
  /// In ru, this message translates to:
  /// **'Учителя'**
  String get p9Title;

  /// No description provided for @p9Homeroom.
  ///
  /// In ru, this message translates to:
  /// **'Классный руководитель'**
  String get p9Homeroom;

  /// No description provided for @p9Write.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get p9Write;

  /// No description provided for @p9WriteTo.
  ///
  /// In ru, this message translates to:
  /// **'Написать: {name}'**
  String p9WriteTo(String name);

  /// No description provided for @p9AllTeachers.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Все учителя ({count})} few{Все учителя ({count})} other{Все учителя ({count})}}'**
  String p9AllTeachers(int count);

  /// No description provided for @p9Empty.
  ///
  /// In ru, this message translates to:
  /// **'Список учителей пока пуст'**
  String get p9Empty;

  /// No description provided for @p10Pinned.
  ///
  /// In ru, this message translates to:
  /// **'Объявление'**
  String get p10Pinned;

  /// No description provided for @p10PinnedMany.
  ///
  /// In ru, this message translates to:
  /// **'{title} и ещё {more}'**
  String p10PinnedMany(String title, int more);

  /// No description provided for @p10Expand.
  ///
  /// In ru, this message translates to:
  /// **'Развернуть'**
  String get p10Expand;

  /// No description provided for @p10Collapse.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть'**
  String get p10Collapse;

  /// No description provided for @p10AllEvents.
  ///
  /// In ru, this message translates to:
  /// **'Все события'**
  String get p10AllEvents;

  /// No description provided for @p10Events.
  ///
  /// In ru, this message translates to:
  /// **'События школы'**
  String get p10Events;

  /// No description provided for @p10EventsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Ближайших событий нет'**
  String get p10EventsEmpty;

  /// No description provided for @p10EventsEmptyHint.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся события на ближайшие недели.'**
  String get p10EventsEmptyHint;

  /// No description provided for @t6Praise.
  ///
  /// In ru, this message translates to:
  /// **'Похвалить'**
  String get t6Praise;

  /// No description provided for @t6Remark.
  ///
  /// In ru, this message translates to:
  /// **'Замечание'**
  String get t6Remark;

  /// No description provided for @t6PraiseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Похвала: {name}'**
  String t6PraiseTitle(String name);

  /// No description provided for @t6RemarkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Замечание: {name}'**
  String t6RemarkTitle(String name);

  /// No description provided for @t6TextHint.
  ///
  /// In ru, this message translates to:
  /// **'Пара слов, если нужно (необязательно)'**
  String get t6TextHint;

  /// No description provided for @t6TagActive.
  ///
  /// In ru, this message translates to:
  /// **'Был активен'**
  String get t6TagActive;

  /// No description provided for @t6TagHelped.
  ///
  /// In ru, this message translates to:
  /// **'Помогал другим'**
  String get t6TagHelped;

  /// No description provided for @t6TagProgress.
  ///
  /// In ru, this message translates to:
  /// **'Заметный прогресс'**
  String get t6TagProgress;

  /// No description provided for @t6TagGreatAnswer.
  ///
  /// In ru, this message translates to:
  /// **'Отличный ответ'**
  String get t6TagGreatAnswer;

  /// No description provided for @t6TagLate.
  ///
  /// In ru, this message translates to:
  /// **'Опоздал'**
  String get t6TagLate;

  /// No description provided for @t6TagNoHomework.
  ///
  /// In ru, this message translates to:
  /// **'Нет домашнего задания'**
  String get t6TagNoHomework;

  /// No description provided for @t6TagDistracted.
  ///
  /// In ru, this message translates to:
  /// **'Отвлекался'**
  String get t6TagDistracted;

  /// No description provided for @t6TagNoMaterials.
  ///
  /// In ru, this message translates to:
  /// **'Нет принадлежностей'**
  String get t6TagNoMaterials;

  /// No description provided for @t9Substitution.
  ///
  /// In ru, this message translates to:
  /// **'Замена'**
  String get t9Substitution;

  /// No description provided for @t9ForTeacher.
  ///
  /// In ru, this message translates to:
  /// **'за {name}'**
  String t9ForTeacher(String name);

  /// No description provided for @t9TaughtBy.
  ///
  /// In ru, this message translates to:
  /// **'ведёт {name}'**
  String t9TaughtBy(String name);

  /// No description provided for @t12Title.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение ДЗ'**
  String get t12Title;

  /// No description provided for @t12Done.
  ///
  /// In ru, this message translates to:
  /// **'Выполнили {done} из {total}'**
  String t12Done(int done, int total);

  /// No description provided for @t12AllDone.
  ///
  /// In ru, this message translates to:
  /// **'Все выполнили'**
  String get t12AllDone;

  /// No description provided for @t12NotDone.
  ///
  /// In ru, this message translates to:
  /// **'Не выполнили: {count}'**
  String t12NotDone(int count);

  /// No description provided for @t12Remind.
  ///
  /// In ru, this message translates to:
  /// **'Напомнить'**
  String get t12Remind;

  /// No description provided for @t12Reminded.
  ///
  /// In ru, this message translates to:
  /// **'Напоминание получили {count}'**
  String t12Reminded(int count);

  /// No description provided for @t12TooSoon.
  ///
  /// In ru, this message translates to:
  /// **'Можно раз в час'**
  String get t12TooSoon;

  /// No description provided for @t12RemindFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить напоминание'**
  String get t12RemindFailed;

  /// No description provided for @t12Loading.
  ///
  /// In ru, this message translates to:
  /// **'Считаем, кто сделал…'**
  String get t12Loading;

  /// No description provided for @t12Open.
  ///
  /// In ru, this message translates to:
  /// **'Кто сделал'**
  String get t12Open;

  /// No description provided for @t8Tab.
  ///
  /// In ru, this message translates to:
  /// **'Мой класс'**
  String get t8Tab;

  /// No description provided for @t8Came.
  ///
  /// In ru, this message translates to:
  /// **'Пришли {came} из {total}'**
  String t8Came(int came, int total);

  /// No description provided for @t8Unmarked.
  ///
  /// In ru, this message translates to:
  /// **'Без отметки: {count}'**
  String t8Unmarked(int count);

  /// No description provided for @t8AllMarked.
  ///
  /// In ru, this message translates to:
  /// **'Все отмечены'**
  String get t8AllMarked;

  /// No description provided for @t8NextLesson.
  ///
  /// In ru, this message translates to:
  /// **'Дальше: {subject} в {time}'**
  String t8NextLesson(String subject, String time);

  /// No description provided for @t8RollCall.
  ///
  /// In ru, this message translates to:
  /// **'Утренняя отметка'**
  String get t8RollCall;

  /// No description provided for @t8MarkClass.
  ///
  /// In ru, this message translates to:
  /// **'Отметить класс за день'**
  String get t8MarkClass;

  /// No description provided for @t8AllCame.
  ///
  /// In ru, this message translates to:
  /// **'Все пришли'**
  String get t8AllCame;

  /// No description provided for @t8MarkSent.
  ///
  /// In ru, this message translates to:
  /// **'Отметка класса отправляется'**
  String get t8MarkSent;

  /// No description provided for @t8SourceExcuse.
  ///
  /// In ru, this message translates to:
  /// **'По заявке'**
  String get t8SourceExcuse;

  /// No description provided for @t8SourcePending.
  ///
  /// In ru, this message translates to:
  /// **'Есть заявка'**
  String get t8SourcePending;

  /// No description provided for @t8Requests.
  ///
  /// In ru, this message translates to:
  /// **'Заявки на отсутствие'**
  String get t8Requests;

  /// No description provided for @t8Approve.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить'**
  String get t8Approve;

  /// No description provided for @t8Reject.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get t8Reject;

  /// No description provided for @t8RejectTitle.
  ///
  /// In ru, this message translates to:
  /// **'Почему отклоняете?'**
  String get t8RejectTitle;

  /// No description provided for @t8RejectHint.
  ///
  /// In ru, this message translates to:
  /// **'Родитель увидит это сообщение'**
  String get t8RejectHint;

  /// No description provided for @t8RejectSend.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить заявку'**
  String get t8RejectSend;

  /// No description provided for @t8Approved.
  ///
  /// In ru, this message translates to:
  /// **'Заявка одобрена'**
  String get t8Approved;

  /// No description provided for @t8Rejected.
  ///
  /// In ru, this message translates to:
  /// **'Заявка отклонена'**
  String get t8Rejected;

  /// No description provided for @t8ReviewFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить решение'**
  String get t8ReviewFailed;

  /// No description provided for @t8Photo.
  ///
  /// In ru, this message translates to:
  /// **'Фото к заявке'**
  String get t8Photo;

  /// No description provided for @t8From.
  ///
  /// In ru, this message translates to:
  /// **'Подала: {name}'**
  String t8From(String name);

  /// No description provided for @t8Week.
  ///
  /// In ru, this message translates to:
  /// **'Неделя класса'**
  String get t8Week;

  /// No description provided for @t8WeekRate.
  ///
  /// In ru, this message translates to:
  /// **'Посещаемость {rate}%'**
  String t8WeekRate(String rate);

  /// No description provided for @t8WeekAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Пропусков: {count}'**
  String t8WeekAbsent(int count);

  /// No description provided for @t8WeekTardy.
  ///
  /// In ru, this message translates to:
  /// **'Опозданий: {count}'**
  String t8WeekTardy(int count);

  /// No description provided for @t8AtRisk.
  ///
  /// In ru, this message translates to:
  /// **'В зоне риска'**
  String get t8AtRisk;

  /// No description provided for @t8AtRiskNone.
  ///
  /// In ru, this message translates to:
  /// **'Никого в зоне риска'**
  String get t8AtRiskNone;

  /// No description provided for @t8OpenWeb.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в вебе'**
  String get t8OpenWeb;

  /// No description provided for @t8Empty.
  ///
  /// In ru, this message translates to:
  /// **'В классе нет учеников'**
  String get t8Empty;

  /// No description provided for @t8NotHomeroom.
  ///
  /// In ru, this message translates to:
  /// **'Раздел для классных руководителей'**
  String get t8NotHomeroom;

  /// No description provided for @t8InboxSub.
  ///
  /// In ru, this message translates to:
  /// **'Одобрить можно в разделе «Мой класс»'**
  String get t8InboxSub;

  /// No description provided for @t8WhatDay.
  ///
  /// In ru, this message translates to:
  /// **'Отметка класса за день: {count}'**
  String t8WhatDay(int count);

  /// No description provided for @t8ClassPick.
  ///
  /// In ru, this message translates to:
  /// **'Класс {name}'**
  String t8ClassPick(String name);

  /// No description provided for @wgChildIn.
  ///
  /// In ru, this message translates to:
  /// **'В школе с {time}'**
  String wgChildIn(String time);

  /// No description provided for @wgChildInNoTime.
  ///
  /// In ru, this message translates to:
  /// **'В школе'**
  String get wgChildInNoTime;

  /// No description provided for @wgChildNotYet.
  ///
  /// In ru, this message translates to:
  /// **'Ещё нет отметки'**
  String get wgChildNotYet;

  /// No description provided for @wgChildNewGrades.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} новая оценка} few{{count} новые оценки} other{{count} новых оценок}}'**
  String wgChildNewGrades(int count);

  /// No description provided for @wgChildNoNew.
  ///
  /// In ru, this message translates to:
  /// **'Новых оценок нет'**
  String get wgChildNoNew;

  /// No description provided for @wgChildAbsent.
  ///
  /// In ru, this message translates to:
  /// **'Не в школе'**
  String get wgChildAbsent;
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
