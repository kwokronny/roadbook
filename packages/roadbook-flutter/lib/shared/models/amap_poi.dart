// lib/shared/models/amap_poi.dart
class AmapPoi {
  const AmapPoi({
    required this.id,
    required this.name,
    required this.address,
    required this.longitude,
    required this.latitude,
    this.type,
  });

  final String id;
  final String name;
  final String address;
  final double longitude;
  final double latitude;
  final String? type;

  factory AmapPoi.fromJson(Map<String, dynamic> json) {
    final parts = (json['location'] as String).split(',');
    return AmapPoi(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      longitude: double.parse(parts[0]),
      latitude: double.parse(parts[1]),
      type: json['type'] as String?,
    );
  }
}
