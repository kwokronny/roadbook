part of amap_flutter_base;

///poi
class AMapPoi {
  /// 唯一标识符
  final String? id;

  /// POI的名称
  final String? name;

  /// 经纬度
  final LatLng? latLng;

  AMapPoi({
     this.id,
     this.name,
     this.latLng,
  });

  dynamic toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('id', id);
    addIfPresent('name', name);
    addIfPresent('latLng', latLng?.toJson());
    return json;
  }

  static AMapPoi? fromJson(dynamic json) {
    if (null == json) {
      return null;
    }
    return AMapPoi(
        id: json['id'],
        name: json['name'],
        latLng: LatLng.fromJson(json['latLng'])!,
    );
  }

  @override
  String toString() {
    return 'TouchPOI(id: $id, name: $name, latlng: $latLng)';
  }
}
