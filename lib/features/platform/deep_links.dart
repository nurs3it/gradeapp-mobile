import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Web path of `https://grade-app.kz/...` → app route, or null when the path
/// is not one the app claims (C7). Everything under a claimed prefix lands on
/// the closest screen; an unknown sub-path ends on «Сегодня» of that role.
///
/// The claimed set must match the backend's apple-app-site-association and
/// assetlinks.json (docs/product/contracts-stage2.md «Deep links») and the Android
/// intent-filters in AndroidManifest.xml.
String? routeForWebLink(Uri uri) {
  final path = uri.path.length > 1 && uri.path.endsWith('/') ? uri.path.substring(0, uri.path.length - 1) : uri.path;
  final seg = path.split('/').where((s) => s.isNotEmpty).toList();
  if (seg.isEmpty) return null;
  switch (seg.first) {
    case 'student':
      return switch (seg.length > 1 ? seg[1] : '') {
        'grades' => '/s/grades',
        'homework' => '/s/tasks',
        'schedule' => '/s/week',
        _ => '/s/today',
      };
    case 'parent':
      return switch (seg.length > 1 ? seg[1] : '') {
        'grades' => '/p/grades',
        'homework' || 'schedule' => '/p/week',
        'excuse' || 'invoices' || 'certificates' => '/p/family',
        _ => '/p/today',
      };
    case 'teacher':
      final sub = seg.length > 1 ? seg[1] : '';
      if (sub == 'lesson' && seg.length > 2) return '/lesson/${seg[2]}';
      return switch (sub) {
        'schedule' => '/t/week',
        'my-day' => '/t/today',
        'my-class' => '/t/class',
        _ => null,
      };
    case 'check-in':
      return '/checkin';
    case 'notifications':
      return '/notifications';
    case 'chat':
      return seg.length > 1 ? '/chat/${seg[1]}' : '/chat';
  }
  return null;
}

/// A link that arrived while the user was signed out (or the session was
/// still loading): kept until sign-in finishes, then opened (C7).
class PendingLink extends Notifier<String?> {
  @override
  String? build() => null;

  void hold(String route) => state = route;

  /// Hands the route over once.
  String? take() {
    final r = state;
    state = null;
    return r;
  }
}

final pendingLinkProvider = NotifierProvider<PendingLink, String?>(PendingLink.new);

/// A full-screen route a shortcut asked for (chat, check-in). The router
/// first opens the role's home, then the shell pushes this on top, so the
/// screen has a page to go back to (a redirect would leave it alone).
class DeferredPush extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String route) => state = route;

  String? take() {
    final r = state;
    state = null;
    return r;
  }
}

final deferredPushProvider = NotifierProvider<DeferredPush, String?>(DeferredPush.new);
