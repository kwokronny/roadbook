// lib/shared/models/api_key.dart

class ApiKey {
  const ApiKey({
    required this.id,
    required this.name,
    required this.key,
    this.lastUsedAt,
    this.createdAt,
  });

  final int id;
  final String name;
  final String key;
  final DateTime? lastUsedAt;
  final DateTime? createdAt;

  factory ApiKey.fromJson(Map<String, dynamic> json) => ApiKey(
        id: json['id'] as int,
        name: json['name'] as String,
        key: json['key'] as String,
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.parse(json['lastUsedAt'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
}
