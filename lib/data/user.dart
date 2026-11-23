class UserProfile {
  const UserProfile({
    required this.name,
    required this.roles,
    required this.email,
    required this.initials,
  });

  final String name;
  /// The user's roles as the backend names them in `GET /auth/me`,
  /// lowercase: `radiologist` or `admin` until real roles are decided. The
  /// app compares these names, and shows its own label for each
  /// ([roleLabel]).
  final List<String> roles;
  final String email;
  final String initials;
}

/// How the app shows a role the backend names: its own words for the roles
/// it knows, and the backend's name for any other.
String roleLabel(String role) => switch (role) {
      'radiologist' => 'Radiologist',
      'admin' => 'Administrator',
      _ => role,
    };
