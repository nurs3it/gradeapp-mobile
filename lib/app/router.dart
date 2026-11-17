import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screens.dart';
import '../features/auth/user.dart';
import '../features/learner/grades_screen.dart';
import '../features/learner/tasks_screen.dart';
import '../features/learner/week_screen.dart';
import '../features/notifications/notification_settings_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/parent/family_screen.dart';
import '../features/parent/parent_today_screen.dart';
import '../features/platform/deep_links.dart';
import '../features/shell/shell.dart';
import '../features/student/check_in_flow.dart';
import '../features/student/student_today_screen.dart';
import '../features/teacher/inbox_screen.dart';
import '../features/teacher/lesson_screen.dart';
import '../features/teacher/teacher_today_screen.dart';
import '../features/teacher/teacher_week_screen.dart';

/// Root path of each role's shell.
String homeOf(AppRole role) => switch (role) {
  AppRole.student => '/s/today',
  AppRole.parent => '/p/today',
  AppRole.teacher => '/t/today',
};

String _prefixOf(AppRole role) => switch (role) {
  AppRole.student => '/s/',
  AppRole.parent => '/p/',
  AppRole.teacher => '/t/',
};

/// Three shells (C1): each role has its own tab set. Auth and role changes
/// re-run [redirect]; full-screen flows (lesson, camera, notifications) sit
/// above the shells on the root navigator.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authProvider.select((a) => (a.isLoading && !a.hasValue, a.value?.id)), (_, _) => refresh.value++)
    ..listen(activeRoleProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  String? redirect(BuildContext _, GoRouterState s) {
    final auth = ref.read(authProvider);
    final loc = s.matchedLocation;
    // A web link (C7) that cannot open yet waits for sign-in, then continues.
    final link = routeForWebLink(s.uri);
    final pending = ref.read(pendingLinkProvider.notifier);
    if (auth.isLoading && !auth.hasValue) {
      if (link != null) pending.hold(link);
      return loc == '/splash' ? null : '/splash';
    }
    final user = auth.value;
    final role = ref.read(activeRoleProvider);
    final inLogin = loc.startsWith('/login');
    if (user == null || role == null) {
      if (link != null) pending.hold(link);
      return inLogin ? null : '/login';
    }
    if (inLogin || loc == '/splash') return pending.take() ?? homeOf(role);
    if (link != null && link != loc) return link;
    final other = AppRole.values.where((r) => r != role).any((r) => loc.startsWith(_prefixOf(r)));
    return other ? homeOf(role) : null;
  }

  NoTransitionPage<void> tab(Widget child) => NoTransitionPage(child: child);

  StatefulShellBranch branch(String path, Widget screen, [List<RouteBase> routes = const []]) => StatefulShellBranch(
    routes: [GoRoute(path: path, pageBuilder: (_, _) => tab(screen), routes: routes)],
  );

  List<RouteBase> gradeDetail() => [
    GoRoute(
      path: ':course',
      builder: (_, s) => SubjectScreen(courseId: s.pathParameters['course']!),
    ),
  ];

  StatefulShellRoute shell(AppRole role, List<StatefulShellBranch> branches) => StatefulShellRoute(
    builder: (_, _, nav) => AppShell(shell: nav, role: role),
    navigatorContainerBuilder: (_, nav, children) => ShellBranches(shell: nav, children: children),
    branches: branches,
  );

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginChooseScreen(),
        routes: [
          GoRoute(path: 'password', builder: (_, _) => const PasswordLoginScreen()),
          GoRoute(path: 'code', builder: (_, _) => const CodeLoginScreen()),
          GoRoute(
            path: 'reset',
            builder: (_, s) => ResetPasswordScreen(email: s.uri.queryParameters['email']),
          ),
        ],
      ),
      shell(AppRole.student, [
        branch('/s/today', const StudentTodayScreen()),
        branch('/s/week', const WeekScreen()),
        branch('/s/grades', const GradesScreen(), gradeDetail()),
        branch('/s/tasks', const TasksScreen()),
      ]),
      shell(AppRole.parent, [
        branch('/p/today', const ParentTodayScreen()),
        branch('/p/grades', const GradesScreen(), gradeDetail()),
        branch('/p/week', const WeekScreen()),
        branch('/p/family', const FamilyScreen()),
      ]),
      shell(AppRole.teacher, [
        branch('/t/today', const TeacherTodayScreen()),
        branch('/t/week', const TeacherWeekScreen()),
        branch('/t/inbox', const InboxScreen()),
      ]),
      GoRoute(
        path: '/lesson/:id',
        builder: (_, s) => LessonScreen(lessonId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/settings/notifications', builder: (_, _) => const NotificationSettingsScreen()),
      GoRoute(
        path: '/checkin',
        pageBuilder: (_, _) => const MaterialPage(fullscreenDialog: true, child: CheckInFlow()),
      ),
    ],
  );
});
