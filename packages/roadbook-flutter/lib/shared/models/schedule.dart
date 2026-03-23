// lib/shared/models/schedule.dart
class Schedule {
  const Schedule({
    this.id,
    required this.tId,
    required this.name,
    required this.coordinate,
    required this.address,
    this.cover,
    this.dianpingUUID,
    required this.isHotel,
    this.startTime,
    this.endTime,
    this.screenshots,
    this.notes,
  });

  final int? id;
  final int tId;
  final String name;
  final String coordinate;
  final String address;
  final String? cover;
  final String? dianpingUUID;
  final bool isHotel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? screenshots;
  final String? notes;

  List<String> get screenshotList {
    if (screenshots == null || screenshots!.isEmpty) return [];
    return screenshots!.split(',').where((s) => s.isNotEmpty).toList();
  }

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] as int?,
        tId: json['tId'] as int,
        name: json['name'] as String,
        coordinate: json['coordinate'] as String,
        address: json['address'] as String,
        cover: json['cover'] as String?,
        dianpingUUID: json['dianpingUUID'] as String?,
        isHotel: json['isHotel'] as bool? ?? false,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        screenshots: json['screenshots'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tId': tId,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'cover': cover,
        'dianpingUUID': dianpingUUID,
        'isHotel': isHotel,
        'startTime': startTime?.toString(),
        'endTime': endTime?.toString(),
        'screenshots': screenshots,
        'notes': notes,
      };
}
