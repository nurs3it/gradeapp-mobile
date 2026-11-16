import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

import 'env.dart';

/// `https://host/path?token=…#x` → `https://host/path`: query strings carry
/// ids and tokens, and a stack trace needs neither.
String scrubUrl(String url) {
  final cut = url.indexOf(RegExp('[?#]'));
  return cut < 0 ? url : url.substring(0, cut);
}

/// Breadcrumb data without anything URL-shaped beyond host and path.
Map<String, dynamic>? scrubCrumbData(Map<String, dynamic>? data) {
  if (data == null) return null;
  return {
    for (final e in data.entries)
      if (e.key != 'query' && e.key != 'fragment' && e.key != 'http.query' && e.key != 'http.fragment')
        e.key: e.value is String && (e.key == 'url' || e.key.endsWith('url')) ? scrubUrl(e.value as String) : e.value,
  };
}

Breadcrumb? scrubBreadcrumb(Breadcrumb? crumb, Hint hint) {
  if (crumb == null) return null;
  return crumb.copyWith(data: scrubCrumbData(crumb.data));
}

/// The app never sets a user and has no HTTP integration, so an event has
/// neither; should an SDK add a request anyway, only its URL without query
/// survives (no headers, cookies or body).
SentryEvent scrubEvent(SentryEvent event, Hint hint) {
  final req = event.request;
  return event.copyWith(
    request: req == null ? null : SentryRequest(url: req.url == null ? null : scrubUrl(req.url!), method: req.method),
    breadcrumbs: event.breadcrumbs?.map((b) => b.copyWith(data: scrubCrumbData(b.data))).toList(),
  );
}

/// Runs [app]. With a Sentry DSN in the build (`--dart-define=SENTRY_DSN=`)
/// uncaught errors are reported; without one nothing is initialised and
/// nothing leaves the phone. Privacy: `docs/product/privacy.md`.
Future<void> runWithCrashReporting(FutureOr<void> Function() app) async {
  if (sentryDsn.isEmpty) {
    await app();
    return;
  }
  await SentryFlutter.init((o) {
    o
      ..dsn = sentryDsn
      ..sendDefaultPii = false
      ..release = 'gradeapp@$appVersion'
      ..environment = apiBaseUrl.contains('grade-app.kz') ? 'production' : 'development'
      ..tracesSampleRate = 0
      ..attachScreenshot = false
      ..maxBreadcrumbs = 30
      ..beforeSend = scrubEvent
      ..beforeBreadcrumb = scrubBreadcrumb;
  }, appRunner: app);
}
