// lib/shared/models/public_travel.dart

class PublicTravelOwner {
  const PublicTravelOwner({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
  });

  final int id;
  final String username;
  final String name;
  final String? avatar;

  factory PublicTravelOwner.fromJson(Map<String, dynamic> json) =>
      PublicTravelOwner(
        id: json['id'] as int,
        username: json['username'] as String,
        name: (json['name'] as String?) ?? (json['username'] as String),
        avatar: json['avatar'] as String?,
      );
}

class PublicTravel {
  const PublicTravel({
    required this.id,
    required this.name,
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.viewCount,
    required this.owner,
  });

  final int id;
  final String name;
  final List<String> cities;
  final DateTime startDate;
  final DateTime endDate;
  final int viewCount;
  final PublicTravelOwner owner;

  int get days => endDate.difference(startDate).inDays + 1;

  String get cityLabel => cities.join(' · ');

  int get gradientIndex => id % 4;

  factory PublicTravel.fromJson(Map<String, dynamic> json) {
    final cityStr = (json['city'] as String?) ?? '';
    final cities = cityStr.isEmpty
        ? <String>[]
        : cityStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return PublicTravel(
      id: json['id'] as int,
      name: json['name'] as String,
      cities: cities,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      viewCount: (json['viewCount'] as int?) ?? 0,
      owner: PublicTravelOwner.fromJson(json['owner'] as Map<String, dynamic>),
    );
  }
}
