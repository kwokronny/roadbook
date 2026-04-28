part of amap_flutter_base;

///高德开放平台用户隐私声明配置
///
///高德SDK合规使用方案请参考：https://lbs.amap.com/news/sdkhgsy
class AMapPrivacyStatement {
  /// 隐私权政策是否包含高德开平隐私权政策
  final bool ?hasContains;
  /// 隐私权政策是否弹窗展示告知用户
  final bool ?hasShow;
  /// 隐私权政策是否已经取得用户同意
  final bool ?hasAgree;

  ///构造AMapPrivacyStatement
  ///
  ///[hasContains] 隐私权政策是否包含高德开平隐私权政策
  ///
  ///[hasShow] 隐私权政策是否弹窗展示告知用户
  ///
  ///[hasAgree] 隐私权政策是否已经取得用户同意
  const AMapPrivacyStatement({@required this.hasContains = false, @required this.hasShow=false, @required this
      .hasAgree=false});

  dynamic toMap() {
    final Map<String, dynamic> json = <String, dynamic>{};

    void addIfPresent(String fieldName, dynamic value) {
      if (value != null) {
        json[fieldName] = value;
      }
    }

    addIfPresent('hasContains', hasContains);
    addIfPresent('hasShow', hasShow);
    addIfPresent('hasAgree', hasAgree);
    return json;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final AMapPrivacyStatement typedOther = other;
    return hasContains == typedOther.hasContains
        && hasShow == typedOther.hasShow
        && hasAgree == typedOther.hasAgree;
  }

  @override
  int get hashCode => Object.hash(hasContains, hasShow, hasAgree);

  @override
  String toString() {
    return 'AMapPrivacyStatement(hasContains: $hasContains, hasShow: $hasShow, hasAgree: $hasAgree)';
  }
}