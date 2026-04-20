import 'package:uuid/uuid.dart';
import '../models/luggage.dart';

enum LuggageSeason { spring, summer, autumn, winter }

const _uuid = Uuid();

/// Returns a fresh list of LuggageCategory for [season].z
/// Each call generates new UUIDs so templates can be merged without id collision.
List<LuggageCategory> seasonTemplate(LuggageSeason season) {
  LuggageItem item(String text) =>
      LuggageItem(id: _uuid.v4(), text: text);
  LuggageCategory cat(String emoji, String name, List<String> texts) =>
      LuggageCategory(
        id: _uuid.v4(),
        name: name,
        emoji: emoji,
        items: texts.map(item).toList(),
      );

  switch (season) {
    case LuggageSeason.spring:
      return [
        cat('📋', '证件', ['护照', '身份证', '签证', '机票打印件', '酒店预订单']),
        cat('👕', '衣物', ['薄外套', '长袖T恤', '牛仔裤', '内衣内裤', '袜子']),
        cat('📱', '电子', ['充电宝', '手机充电线', '转换插头', '相机', '耳机']),
        cat('🪥', '洗漱', ['牙刷', '牙膏', '洗发水', '沐浴露', '护手霜']),
      ];
    case LuggageSeason.summer:
      return [
        cat('📋', '证件', ['护照', '身份证', '签证', '机票打印件', '酒店预订单']),
        cat('👕', '衣物', ['T恤', '短裤', '凉鞋', '内衣内裤', '袜子', '帽子']),
        cat('🧴', '防晒护肤', ['防晒霜', '晒后修复乳', '保湿喷雾', '护唇膏']),
        cat('📱', '电子', ['充电宝', '手机充电线', '转换插头', '相机', '耳机']),
        cat('💊', '药品', ['感冒药', '肠胃药', '防蚊液', '止痒膏', '创可贴']),
      ];
    case LuggageSeason.autumn:
      return [
        cat('📋', '证件', ['护照', '身份证', '签证', '机票打印件', '酒店预订单']),
        cat('👕', '衣物', ['外套', '针织衫', '长裤', '内衣内裤', '袜子']),
        cat('📱', '电子', ['充电宝', '手机充电线', '转换插头', '相机', '耳机']),
        cat('🪥', '洗漱', ['牙刷', '牙膏', '洗发水', '沐浴露', '护手霜']),
        cat('💊', '药品', ['感冒药', '肠胃药', '止痛药', '创可贴']),
      ];
    case LuggageSeason.winter:
      return [
        cat('📋', '证件', ['护照', '身份证', '签证', '机票打印件', '酒店预订单']),
        cat('🧥', '御寒衣物', ['羽绒服', '围巾', '手套', '毛帽', '厚袜子', '保暖内衣']),
        cat('📱', '电子', ['充电宝', '手机充电线', '转换插头', '相机', '耳机']),
        cat('💊', '药品', ['感冒药', '暖宝宝', '止痛药', '润喉糖', '创可贴']),
        cat('🪥', '洗漱', ['牙刷', '牙膏', '保湿面霜', '护唇膏', '洗发水']),
      ];
  }
}

/// Returns suggested item names for [categoryName].
/// Falls back to [universalPresets] when no keyword matches.
List<String> presetItemsFor(String categoryName) {
  if (categoryName.contains('证件')) {
    return ['护照', '身份证', '签证', '机票打印件', '酒店预订单', '旅行保险单', '驾照'];
  }
  if (categoryName.contains('衣') || categoryName.contains('服')) {
    return ['T恤', '内衣内裤', '外套', '袜子', '运动鞋', '正装', '睡衣', '帽子'];
  }
  if (categoryName.contains('电') || categoryName.contains('数码')) {
    return ['充电宝', '手机充电线', '转换插头', '相机', '耳机', '移动硬盘'];
  }
  if (categoryName.contains('药')) {
    return ['感冒药', '肠胃药', '止痛药', '防蚊液', '创可贴', '防晒霜'];
  }
  if (categoryName.contains('洗')) {
    return ['牙刷', '牙膏', '洗发水', '沐浴露', '护手霜', '剃须刀'];
  }
  if (categoryName.contains('防晒') || categoryName.contains('护肤')) {
    return ['防晒霜', '晒后修复乳', '保湿喷雾', '护唇膏', '面膜'];
  }
  return universalPresets;
}

const List<String> universalPresets = [
  '充电宝', '雨伞', '耳机', '眼罩颈枕', '保温杯', '零食',
];
