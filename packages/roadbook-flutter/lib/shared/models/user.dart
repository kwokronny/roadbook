// lib/shared/models/user.dart
class User {
  const User({required this.id, required this.username, this.avatar, this.name});

  final int id;
  final String username;
  final String? avatar;
  final String? name;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        avatar: json['avatar'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'name': name,
      };
}
