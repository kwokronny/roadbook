// lib/shared/models/user_travel.dart
import 'user.dart';

enum RoleType { manage, edit, view }

// 顶层函数，extension 不支持静态方法调用
RoleType roleTypeFromString(String s) =>
    RoleType.values.firstWhere((e) => e.name == s,
        orElse: () => RoleType.view);

class UserWithRole {
  const UserWithRole({required this.user, required this.role});

  final User user;
  final RoleType role;

  factory UserWithRole.fromJson(Map<String, dynamic> json) => UserWithRole(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        role: roleTypeFromString(json['role'] as String),
      );
}
