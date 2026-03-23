// lib/shared/models/user_travel.dart
import 'user.dart';

enum RoleType { manage, edit, view }

RoleType roleTypeFromString(String s) =>
    RoleType.values.firstWhere((e) => e.name == s,
        orElse: () => RoleType.view);

class UserWithRole {
  const UserWithRole({required this.user, required this.role});

  final User user;
  final RoleType role;

  /// Sequelize join format: user fields at top level, role in UserTravel.role
  factory UserWithRole.fromJson(Map<String, dynamic> json) => UserWithRole(
        user: User.fromJson(json),
        role: roleTypeFromString(
          ((json['UserTravel'] as Map<String, dynamic>?) ?? {})['role'] as String? ?? 'view',
        ),
      );
}
