// lib/shared/models/travel.dart
import 'schedule.dart';
import 'user_travel.dart';

class Travel {
  const Travel({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isPublic,
    required this.cities,
    required this.collaborators,
    required this.schedules,
    this.equip,
  });

  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  final List<String> cities;
  final List<UserWithRole> collaborators;
  final List<Schedule> schedules;
  final String? equip;

  factory Travel.fromJson(Map<String, dynamic> json) {
    // Backend field 'city' (comma-separated string)
    final cityRaw = json['city'] as String? ?? '';
    final cities = cityRaw.isEmpty
        ? <String>[]
        : cityRaw.split(',').where((s) => s.isNotEmpty).toList();

    return Travel(
      id: json['id'] as int?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isPublic: json['public'] as bool? ?? false,          // backend field: public
      cities: cities,
      collaborators: (json['Users'] as List<dynamic>? ?? [])    // backend field: Users
          .map((e) => UserWithRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['Schedules'] as List<dynamic>? ?? [])    // backend field: Schedules
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      equip: json['equip'] as String?,
    );
  }
}
