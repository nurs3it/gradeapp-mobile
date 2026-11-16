import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/user.dart';
import '../features/learner/grades_screen.dart';
import '../features/learner/homework_screen.dart';
import '../features/learner/schedule_screen.dart';
import '../features/learner/today_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/teacher/lesson_screen.dart';
import '../features/teacher/teacher_day_screen.dart';
import 'shell.dart';

/// Two shells: learner (student & parent share every screen; parent adds a
/// child switcher) and teacher. Auth and role changes re-run [redirect].
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref
    ..listen(authProvider, (_, _) => refresh.value++)
    ..listen(activeRoleProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  String? redirect(BuildContext _, GoRouterState s) {
    final auth = ref.read(authProvider);
    if (auth.isLoading && !auth.hasValue) return s.matchedLocation == '/splash' ? null : '/splash';
    final user = auth.value;
    final loc = s.matchedLocation;
    if (user == null) return loc == '/login' ? null : '/login';
    final role = ref.read(activeRoleProvider);
    if (role == null) return loc == '/login' ? null : '/login';
    final home = role == AppRole.teacher ? '/t' : '/l';
    if (!loc.startsWith(home)) return role == AppRole.teacher ? '/t/lessons' : '/l/today';
    return null;
  }

  NoTransitionPage<void> tab(Widget child) => NoTransitionPage(child: child);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: redirect,
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell, teacher: false),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/l/today', pageBuilder: (_, _) => tab(const TodayScreen()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/l/schedule', pageBuilder: (_, _) => tab(const ScheduleScreen()))],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/l/grades',
                pageBuilder: (_, _) => tab(const GradesScreen()),
                routes: [
                  GoRoute(
                    path: ':course',
                    builder: (_, s) => SubjectGradesScreen(courseId: s.pathParameters['course']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/l/homework', pageBuilder: (_, _) => tab(const HomeworkScreen()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/l/profile', pageBuilder: (_, _) => tab(const ProfileScreen()))],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell, teacher: true),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/t/lessons', pageBuilder: (_, _) => tab(const TeacherDayScreen()))],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/t/profile', pageBuilder: (_, _) => tab(const ProfileScreen()))],
          ),
        ],
      ),
      GoRoute(
        path: '/t/lesson/:id',
        builder: (_, s) => LessonScreen(lessonId: s.pathParameters['id']!),
      ),
    ],
  );
});
