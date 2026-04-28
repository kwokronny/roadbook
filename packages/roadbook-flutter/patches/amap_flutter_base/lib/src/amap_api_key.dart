part of amap_flutter_base;

///高德开放平台api key配置
///
///申请key请到高德开放平台官网:https://lbs.amap.com/
///
///Android平台的key的获取请参考：https://lbs.amap.com/api/poi-sdk-android/develop/create-project/get-key/?sug_index=2
///
///iOS平台key的获取请参考：https://lbs.amap.com/api/poi-sdk-ios/develop/create-project/get-key/?sug_index=1
class AMapApiKey {
  //iOS平台的key
  final String? iosKey;

  //Android平台的key
  final String? androidKey;

  ///构造AMapKeyConfig
  ///
  ///[iosKey] iOS平台的key
  ///
  ///[androidKey] Android平台的key
  const AMapApiKey({this.iosKey, this.androidKey});

  dynamic toMap() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('androidKey', androidKey);
    addIfPresent('iosKey', iosKey);
    return json;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final AMapApiKey typedOther = other;
    return androidKey == typedOther.androidKey && iosKey == typedOther.iosKey;
  }

  @override
  int get hashCode => Object.hash(androidKey, iosKey);

  @override
  String toString() {
    return 'AMapApiKey(androidKey: $androidKey, iosKey: $iosKey)';
  }
}
