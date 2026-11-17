/// Build-time config: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`.
/// The base URL must include `/api` — endpoints are written as `/users/me/`.
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://grade-app.kz/api');

/// Shown in «О приложении» and sent with analytics.
const appVersion = '1.0.0';
