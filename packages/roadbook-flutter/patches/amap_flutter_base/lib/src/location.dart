part of amap_flutter_base;

///定位信息类
///
///可提供内容包括：
///
///[provider]定位信息提供者，注意，如果是iOS平台只会返回‘iOS’
///
///[latLng]经纬度信息
///
///[accuracy] 水平精确度
///
///[altitude] 海拔
///
///[bearing] 角度
///
///[speed] 速度
///
///[time] 定位时间
///
class AMapLocation {
  ///定位提供者
  ///
  ///Android平台根据系统信息透出
  ///
  ///iOS平台只会返回'iOS'
  final String provider;

  ///经纬度
  final LatLng latLng;

  ///水平精确度
  final double accuracy;

  ///海拔
  final double altitude;

  ///角度
  final double bearing;

  ///速度
  final double speed;

  ///定位时间
  final num time;

  const AMapLocation({
    this.provider = '',
    required this.latLng,
    this.accuracy = 0,
    this.altitude = 0,
    this.bearing = 0,
    this.speed = 0,
    this.time = 0,
  });

  static AMapLocation? fromMap(dynamic json) {
    if (null == json) {
      return null;
    }

    return AMapLocation(
      provider: json['provider'],
      latLng: LatLng.fromJson(json['latLng'])!,
      accuracy: (json['accuracy']).toDouble(),
      altitude: (json['altitude']).toDouble(),
      bearing: (json['bearing']).toDouble(),
      speed: (json['speed']).toDouble(),
      time: json['time'],
    );
  }

  /// Converts this object to something serializable in JSON.
  dynamic toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    json['latlng'] = latLng.toJson();
    addIfPresent('provider', provider);
    addIfPresent('accuracy', accuracy);
    addIfPresent('altitude', altitude);
    addIfPresent('bearing', bearing);
    addIfPresent('speed', speed);
    addIfPresent('time', time);
    return json;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (other is! AMapLocation) {
      return false;
    }
    final AMapLocation typedOther = other;
    return provider == typedOther.provider &&
        latLng == typedOther.latLng &&
        accuracy == typedOther.accuracy &&
        altitude == typedOther.altitude &&
        bearing == typedOther.bearing &&
        speed == typedOther.speed &&
        time == typedOther.time;
  }

  @override
  int get hashCode =>
      Object.hash(provider, latLng, accuracy, altitude, bearing, speed, time);
}

/// 经纬度坐标对象， 单位为度.
class LatLng {
  ///根据纬度[latitude]和经度[longitude]创建经纬度对象
  ///
  ///[latitude]取值范围 [-90.0,90.0].
  ///
  /// [latitude]取值范围 [-180.0,179.0]
  const LatLng(double latitude, double longitude)
      : latitude =
            (latitude < -90.0 ? -90.0 : (90.0 < latitude ? 90.0 : latitude)),
        longitude = (longitude + 180.0) % 360.0 - 180.0;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  dynamic toJson() {
    return <double>[latitude, longitude];
  }

  /// 根据传入的经纬度数组 \[lat, lng\] 序列化一个LatLng对象.
  static LatLng? fromJson(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLng(json[0], json[1]);
  }

  @override
  String toString() => '$runtimeType($latitude, $longitude)';

  @override
  bool operator ==(Object o) {
    return o is LatLng && o.latitude == latitude && o.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// 经纬度对齐的矩形.
class LatLngBounds {
  /// 使用传入的西南角坐标[southwest]和东北角坐标[northeast]创建一个矩形区域.
  LatLngBounds({required this.southwest, required this.northeast}) {
    try {
      assert(southwest.latitude <= northeast.latitude,
          '西南角纬度超过了东北角纬度(${southwest.latitude} > ${northeast.latitude})');
    } catch (e) {
      print(e);
    }
  }

  /// 西南角坐标.
  final LatLng southwest;

  /// 东北角坐标.
  final LatLng northeast;

  dynamic toJson() {
    if (southwest.latitude > northeast.latitude) {
      return null;
    }
    return <dynamic>[southwest.toJson(), northeast.toJson()];
  }

  /// 判断矩形区域是否包含传入的经纬度[point].
  bool contains(LatLng point) {
    try {
      return _containsLatitude(point.latitude) &&
          _containsLongitude(point.longitude);
    } catch (e) {
      print(e);
    }
    return false;
  }

  bool _containsLatitude(double lat) {
    return (southwest.latitude <= lat) && (lat <= northeast.latitude);
  }

  bool _containsLongitude(double lng) {
    if (southwest.longitude <= northeast.longitude) {
      return southwest.longitude <= lng && lng <= northeast.longitude;
    } else {
      return southwest.longitude <= lng || lng <= northeast.longitude;
    }
  }

  @visibleForTesting
  static LatLngBounds? fromList(dynamic json) {
    if (json == null) {
      return null;
    }
    return LatLngBounds(
      southwest: LatLng.fromJson(json[0])!,
      northeast: LatLng.fromJson(json[1])!,
    );
  }

  @override
  String toString() {
    return '$runtimeType($southwest, $northeast)';
  }

  @override
  bool operator ==(Object o) {
    return o is LatLngBounds &&
        o.southwest == southwest &&
        o.northeast == northeast;
  }

  @override
  int get hashCode => Object.hash(southwest, northeast);
}
