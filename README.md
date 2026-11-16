# GradeApp Mobile

Нативное Flutter-приложение GradeApp для ученика, родителя и учителя. Работает на тех же API, что и веб (`gradeapp/backend`).

## Запуск

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8001/api   # локальный бэкенд
flutter run                                                         # прод: https://grade-app.kz/api
```

Базовый URL обязательно с `/api`. Android-эмулятор ходит на хост через `http://10.0.2.2:<port>/api`.

Проверки (их же стоит гонять в CI):

```bash
flutter analyze
flutter test
```

## Архитектура

```
lib/
  app/        корень: тема, роутер (go_router), shell с таб-баром, настройки
  core/       api-клиент (Dio + refresh), кэш, офлайн-очередь, шкала оценок
  ui/         UI kit: токены 1:1 с веб-дизайн-системой, тема, виджеты (импорт: ui/ui.dart)
  l10n/       ARB ru/kk/en → gen-l10n
  features/
    auth/     вход (2FA), пользователь, активная роль
    learner/  ученик и родитель: сегодня, расписание, оценки, ДЗ, «Я в школе»
    teacher/  день учителя и ведение урока
    profile/  профиль, дети и согласие, язык, тема
```

- **State**: Riverpod 3. Серверные данные — `StreamProvider` через `cachedGet`: сразу отдаёт кэш, потом свежий ответ. Без сети остаётся кэш.
- **Авторизация**: access/refresh в Keychain/Keystore. Один общий refresh на все параллельные 401, потому что бэкенд ротирует refresh-токен. Сессию завершает только явный 401 от `/auth/refresh/`.
- **Офлайн учителя**: посещаемость, оценки, тема и старт/финиш урока идут через `core/offline/outbox.dart`. Запись сохраняется на телефоне и уходит на сервер, когда есть сеть. Экран урока накладывает неотправленные отметки поверх серверных (`LessonOverlay`).
- **Дизайн**: цвета, радиусы и анимации — из `gradeapp/frontend/src/shared/styles/index.css`. Сначала меняй там, потом здесь (`lib/ui/tokens.dart`). Hex-цвета в экранах не пишем, только токены.
- **Строки**: только через `context.l10n`. Новая строка добавляется во все три ARB.

## Демо-аккаунты (локальная сид-база)

Пароли — в `gradeapp/backend/users/management/commands/seed_halfyear.py` (`PWD`): учитель `y.popov@goso-demo.kz`, ученик `a.bekova@goso-demo.kz`, родитель `parent.a.bekova@goso-demo.kz`.
