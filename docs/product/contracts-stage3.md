# Контракты этапа 3

Общий договор бэкенда (`gradeapp`, ветка `feat/mobile-stage3`) и мобилки. Все пути с префиксом `/api/`. Даты — `YYYY-MM-DD`, время — ISO 8601 с зоной.

## B9. Флаги мобильных механик школы

- Новые поля `School`: `streaks_enabled`, `weekly_digest_enabled` (BooleanField, default `False`). `checkin_missing_alert` уже есть.
- `GET /schools/{id}/` добавляет `mobile: {streaks_enabled, weekly_digest_enabled, checkin_missing_alert}`.
- Мобилка: выключенный флаг прячет фичу целиком (экран, карточку, настройку), без пустых состояний.

## B2. Серии ученика

`GET /students/{id}/streaks/` — ученик (свой), родитель (свои дети). Персонал и остальные — 403. Флаг школы выключен — `{"enabled": false}` (200).

```json
{
  "enabled": true,
  "checkin":  {"current": 12, "best": 20, "today": "done", "freezes_left": 2},
  "homework": {"current": 4,  "best": 9,  "today": "pending", "freezes_left": 1},
  "milestones": [{"kind": "checkin", "days": 10, "reached_at": "2026-11-20"}],
  "missed": [{"kind": "checkin", "date": "2026-11-26", "freeze_until": "2026-11-27T23:59:59+05:00"}]
}
```

- `today`: `done` | `pending` (учебный день, ещё не выполнено — серию не рвёт) | `frozen` | `excused` | `off` (не учебный день).
- Учебный день — дата, на которую у класса ученика есть неотменённые уроки. Каникулы — даты вне `AcademicTerm`. Праздники — `SchoolEvent(event_type="holiday")` для этого класса.
- **Вовремя:** `DailyCheckIn` на дату и не опоздание (`is_checkin_late`). Одобренная заявка на дату — `excused`, серию не рвёт и не продлевает.
- **ДЗ в срок:** все ДЗ класса с `due_date = d` отмечены `HomeworkCompletion.done_at` раньше даты `d`. День без ДЗ — нейтральный.
- **Заморозки:** две на текущую четверть на каждый вид. `missed` — пропущенные дни, которые ещё можно закрыть (не позже 24 часов после конца дня).
- `POST /students/{id}/streaks/freeze/ {kind, date}` — только ученик. 400 `freeze_expired` | `no_freezes_left` | `not_missed`. 200 — объект как в GET.
- Вехи: 5, 10, 20, 50 дней.
- Модель `StreakFreeze` (`db_table = "student_streak_freezes"`): `student`, `kind`, `date`, `created_at`, unique (`student`, `kind`, `date`).

## B3. Недельная сводка

`GET /students/{id}/weekly-summary/?week=2026-W48` — ученик (свой), родитель (свои дети). Без `week` — текущая ISO-неделя. Персонал — 403.

```json
{
  "week": "2026-W48", "date_from": "2026-11-23", "date_to": "2026-11-29",
  "empty": false,
  "verdict": {"code": "dip", "course_id": "…", "course_name": "Физика"},
  "attendance": {"days": 5, "days_on_time": 4, "absent": 1, "tardy": 1, "excused": 0},
  "grades": {"count": 6, "by_subject": [
    {"course_id": "…", "name": "Алгебра", "avg": 8.5, "prev_avg": 7.9, "items": [{"id": "…", "date": "…", "value": "9", "kind": "fo"}]}
  ]},
  "homework": {"assigned": 9, "done": 7, "overdue": 1},
  "feedback": [{"id": "…", "date": "…", "text": "…", "tags": ["positive"], "from_name": "…"}],
  "upcoming": {
    "assessments": [{"course_name": "Алгебра", "kind": "sor", "date": "2026-12-02", "title": "СОР 2"}],
    "events": [{"id": "…", "title": "…", "start_date": "…"}]
  },
  "streaks": {"checkin": 12, "homework": 4}
}
```

- `verdict.code`: `empty` (нет учебных дней) | `great` (все дни вовремя, нет просрочек и просадок) | `dip` (средний по предмету упал на 0,5+ к прошлой неделе; предмет — с наибольшим падением) | `absences` (есть неуважительный пропуск) | `overdue` (есть просроченные ДЗ) | `steady`. Приоритет: `empty` > `absences` > `dip` > `overdue` > `great` > `steady`.
- `streaks` — только если включены серии, иначе `null`.

### Пуш `digest.weekly`

- Новая группа уведомлений `digest`. В `notification_prefs.digest`: `{push: bool, day: "fri" | "sun", hour: 18}`, по умолчанию `{push: true, day: "fri", hour: 18}`.
- Команда `send_weekly_digest` идёт по крону каждый час. Шлёт родителям, у кого наступил выбранный день и час (время школы), если включён `weekly_digest_enabled` и неделя не `empty`. Журнал `WeeklyDigestSent` (`db_table = "weekly_digest_sent"`, unique `parent`, `student`, `week`).
- Payload: `{student_id, week, verdict_code}`. Target `{kind: "student", id}`. Текст — «Неделя {имя}: …» с выводом.

## B5. Запрос согласия на фото

`POST /students/{id}/photo-consent/request/` — только сам ученик, не чаще раза в 24 часа (429 `{error: "too_soon", retry_after}`). Уже есть согласие — 409 `already_granted`. 200 `{notified: N}`. Уведомление `consent.requested` всем родителям, target `{kind: "student", id}`.

## T6. Отзыв без текста

- `Feedback.text` становится необязательным (`blank=True`).
- Теги: первый — `positive` | `negative`, дальше шаблоны. Позитивные: `active`, `helped`, `progress`, `great_answer`. Замечания: `late`, `no_homework`, `distracted`, `no_materials`. Подписи берёт клиент (ru/kk/en).

## T9. Замены

`LessonSerializer` добавляет `is_substitution` (урок ведёт не учитель курса) и `course_teacher_name`.

## Уже есть, используется без изменений

- **P5:** `GET /attendance/?student_id=&date_from=&date_to=`, `GET /attendance/statistics/?student_id=&date_from=&date_to=`.
- **P8:** `GET /billing/my-invoices/`, `GET /billing/my-invoices/{id}/`, `POST /billing/invoices/{id}/pay-online/` → `{pay_url}` (409 Kaspi выключен), `GET /billing/invoices/{id}/pdf/`.
- **P9:** `GET /students/{id}/teachers/` (классрук первым — сортирует клиент).
- **P10:** `GET /engagement/events/?pinned=1`, `?date_from=&date_to=`, `POST /engagement/events/{id}/read/`.
- **T8:** `GET /classes/mine/` (таб только при `is_homeroom`), `GET /attendance/check-ins/?class_group=&date=`, `GET /attendance/day_marks/?class_group_id=&date=`, `POST /attendance/mark_day/`, `GET /excuses/pending/`, `POST /excuses/{id}/approve/`, `POST /excuses/{id}/reject/ {review_note}`, `GET /classes/{id}/overview/`, `GET /attendance/statistics/?class_group_id=&date_from=&date_to=` (`per_student`).
- **T12:** `GET /homework/{id}/completions/`, `POST /homework/{id}/remind/` (429 `reminder_too_soon`).
