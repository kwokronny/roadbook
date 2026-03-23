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
    final citiesRaw = json['cities'] as String? ?? '';
    final cities = citiesRaw.isEmpty
        ? <String>[]
        : citiesRaw.split(',').where((s) => s.isNotEmpty).toList();

    return Travel(
      id: json['id'] as int?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      cities: cities,
      collaborators: (json['collaborators'] as List<dynamic>? ?? [])
          .map((e) => UserWithRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      equip: json['equip'] as String?,
    );
  }
}
