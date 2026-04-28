import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 高德地图隐私合规：amap_flutter_base ^3.0.0 不提供 AMapInitializer 静态方法，
  // 隐私合规通过 AMapWidget(privacyStatement: AMapPrivacyStatement(...)) 在 Widget 层声明。
  // 参见 packages/roadbook-flutter/lib/features/map/ 中地图 Widget 的实现。
  runApp(const ProviderScope(child: RoadbookApp()));
}
