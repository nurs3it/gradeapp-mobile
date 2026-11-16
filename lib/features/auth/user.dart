import '../../core/json.dart';

/// App mode the signed-in person works in. A user can hold several roles
/// (a teacher who is also a parent) and switches in the avatar menu.
enum AppRole { teacher, parent, student }

class SchoolRef {
  const SchoolRef({required this.id, required this.name, required this.roles});
  final String id;
  final String name;
  final List<String> roles;

  factory SchoolRef.fromJson(Json j) =>
      SchoolRef(id: j.str('id'), name: j.str('name'), roles: j.strings('roles').map((r) => r.toLowerCase()).toList());
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    this.linkedSchool,
    this.avatarUrl,
    this.language = 'ru',
    this.staffId,
    this.studentId,
    this.permissions = const {},
    this.schools = const [],
    this.homeroomClassIds = const [],
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
  final String? studentId;

  /// `nav.*` and `resource.action` grants in the active school (C9).
  final Set<String> permissions;
  final List<SchoolRef> schools;
  final List<String> homeroomClassIds;

  String get fullName => [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

  bool can(String permission) => permissions.contains(permission);

  SchoolRef? get school => schools.where((s) => s.id == linkedSchool).firstOrNull;

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
    studentId: j.strOrNull('student_id'),
    permissions: j.strings('permissions').toSet(),
    schools: j.list('schools', SchoolRef.fromJson),
    homeroomClassIds: j.strings('homeroom_class_ids'),
  );
}
