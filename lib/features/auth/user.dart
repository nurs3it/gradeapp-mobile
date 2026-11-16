import '../../core/json.dart';

/// App mode the signed-in person works in. A user can hold several roles
/// (a teacher who is also a parent) and switches in the profile.
enum AppRole { teacher, parent, student }

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.linkedSchool,
    required this.avatarUrl,
    required this.language,
    required this.staffId,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String? linkedSchool;
  final String? avatarUrl;
  final String language;
  final String? staffId;

  String get fullName => [lastName, firstName].where((s) => s.isNotEmpty).join(' ');

  /// Roles this app supports, in priority order.
  List<AppRole> get appRoles => [
    if (roles.contains('teacher')) AppRole.teacher,
    if (roles.contains('parent')) AppRole.parent,
    if (roles.contains('student')) AppRole.student,
  ];

  factory AppUser.fromJson(Json j) => AppUser(
    id: j.str('id'),
    email: j.str('email'),
    firstName: j.str('first_name'),
    lastName: j.str('last_name'),
    roles: j.strings('roles').map((r) => r.toLowerCase()).toList(),
    linkedSchool: j.strOrNull('linked_school'),
    avatarUrl: j.strOrNull('avatar_url'),
    language: j.strOrNull('language_pref') ?? 'ru',
    staffId: j.strOrNull('staff_id'),
  );
}
