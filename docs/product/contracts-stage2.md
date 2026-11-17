# Contracts between workstreams (stage 2, 2026-11-17)

## Presence (backend + web + mobile)
- Any authenticated API request marks the user online: cache key `presence:<user_id>`, TTL 150 s, write throttled to once per 30 s per user. Web and mobile already poll `/api/me/pulse/` while visible, so an open tab/app keeps the user online; closed → offline within 150 s.
- `GET /api/presence/?users=<uuid,...>&students=<uuid,...>&staff=<uuid,...>` (each list ≤ 200 ids, all optional) →
  `{"users": [online user ids], "students": [online student ids], "staff": [online staff ids]}`.
  Scoping: staff-side viewers (teacher, director, schooladmin, registrar, scheduler) see anyone in their schools. Students and parents see only themselves, their own children and the staff of their schools (by user id or staff id); other students and other parents are never reported. Global superadmin sees all. Others are silently omitted, as are ids not online. IsAuthenticated.
- Clients: batch all avatars on screen into one request, poll every 30 s while visible, stop in background. Green dot bottom-right of the avatar with a ring of the surface colour; a11y label "В сети" / "Желіде" / "Online". The signed-in user's own avatar shows it too.

## Push payloads (backend → mobile)
- iOS: `aps.category = "ATTENDANCE_FLAGGED"` for `attendance.flagged` (action EXPLAIN «Объяснить пропуск» → open excuse form for that lesson/date), `aps.category = "EXCUSE_PENDING"` for `excuse.pending` (actions APPROVE «Одобрить» → POST /api/excuses/<excuse_id>/approve/, OPEN «Открыть»).
- Android: for those two types the FCM message is data-only, high priority, with data keys `title`, `body`, `channel` in addition to the usual `type`, `notification_id`, `target_kind`, `target_id`, `student_id`. The app renders it (with action buttons). Every other type stays a notification message as today.
- Silent sync: data-only, `data.type = "sync.today" | "sync.schedule"` (+ optional `student_id`, `date`), APNs `content-available: 1`, `apns-priority: 5`, `apns-push-type: background`; Android priority normal. Sent when lessons change (cancel / reschedule / substitution / time or room change) to affected students, their parents and teachers. Throttled per user and type: at most one per 5 minutes.
- New type `checkin.missing` (to parents; pref group `attendance`): payload `student_id`, `student_name`, `date`. Titles ru «Не отметился в школе», kz «Мектепке белгі қойылмады», en «Has not checked in». App routes it to the parent's Today for that child.

## Deep links (Universal Links / App Links)
- Domain `grade-app.kz`. iOS appID `6Y5RQZ368G.kz.gradeapp.gradeapp`, Android package `kz.gradeapp.gradeapp`.
- Paths the app claims: `/student/*`, `/parent/*`, `/teacher/lesson/*`, `/teacher/my-day`, `/teacher/schedule`, `/check-in`, `/notifications`. Everything else stays in the browser.
- Files: `https://grade-app.kz/.well-known/apple-app-site-association` and `/.well-known/assetlinks.json`, `Content-Type: application/json`, no redirect.

## First-party analytics (no third-party analytics for minors)
- `POST /api/analytics/events/` (IsAuthenticated, throttled) body `{"events": [{"name": str, "at": iso8601, "props": {..}}], "platform": "ios"|"android"|"web", "app_version": str}` → 204. ≤ 50 events per call.
- Stored WITHOUT user id: name, at, role (active role), school_id, platform, app_version, props (whitelisted keys only, scalars only).
- Names: `app_open`, `login`, `checkin_start`, `checkin_success`, `checkin_fail` (props.reason), `roll_call_done` (props.seconds, props.absent), `homework_created`, `push_open` (props.type), `excuse_sent`, `report_card_download`, `feedback_sent`. Unknown names are dropped.
- Crash reports: our own backend, `POST /api/analytics/crashes/` `{platform, app_version, os_version, crashes:[{error_type,message,stack,fatal}]}` → 204, no auth, throttled 30/hour per IP, stored without user. No third-party crash service.
