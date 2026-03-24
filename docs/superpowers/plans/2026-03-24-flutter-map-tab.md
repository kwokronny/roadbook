# Flutter TravelDetail 地图 Tab 实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现 TravelDetailScreen 的地图 Tab，包含按天展示行程 Marker + 虚线路径、Day Chip 切换、POI 搜索并快速加入待规划，替换现有占位符。

**Architecture:** 全屏 AMapWidget + 浮层 UI（MapDaySelectorBar / MapSearchBar 二选一 + MapInfoBar 底部信息条），由新建 MapStateNotifier 驱动。行程数据来源 scheduleProvider(travelId)；天数选择共用 selectedDayProvider(travelId)（与行程 Tab 同步）。日期分组逻辑提取为 scheduleDayHelper 避免重复。

**Tech Stack:** Flutter 3, Riverpod 2.5.1, amap_flutter_map ^3.0.0, amap_flutter_base ^3.0.0, Dio（已有），flutter_test + mocktail（已有 dev deps）

---

## 文件清单

| 操作 | 路径 |
|------|------|
| 新建 | `lib/shared/models/amap_poi.dart` |
| 新建 | `lib/shared/utils/schedule_day_helper.dart` |
| 新建 | `lib/features/travel/presentation/map/map_state_notifier.dart` |
| 新建 | `lib/features/travel/presentation/map/map_day_selector.dart` |
| 新建 | `lib/features/travel/presentation/map/map_info_bar.dart` |
| 新建 | `lib/features/travel/presentation/map/map_search_bar.dart` |
| 新建 | `lib/features/travel/presentation/map/map_tab_view.dart` |
| 修改 | `lib/features/schedule/presentation/schedule_list_panel.dart` |
| 修改 | `lib/features/travel/presentation/travel_detail_screen.dart` |
| 修改 | `lib/main.dart` |
| 修改 | `pubspec.yaml` |
| 修改 | `android/app/src/main/AndroidManifest.xml` |
| 修改 | `ios/Runner/AppDelegate.swift` |
| 新建 | `test/unit/models/amap_poi_test.dart` |
| 新建 | `test/unit/utils/schedule_day_helper_test.dart` |
| 新建 | `test/unit/features/map/map_state_notifier_test.dart` |
| 新建 | `test/widget/features/map/map_day_selector_test.dart` |
| 新建 | `test/widget/features/map/map_info_bar_test.dart` |
| 新建 | `test/widget/features/map/map_search_bar_test.dart` |

---

## Task 0: 原生平台配置（前置，无代码测试）

**说明：** 高德 SDK 需在两个平台配置 API Key 及隐私合规初始化。Key 值需从高德开放平台 → 我的应用 → 移动端 Key 获取（Android 和 iOS 各一个）。

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/AppDelegate.swift`

- [ ] **Step 1: Android — 添加 API Key**

在 `android/app/src/main/AndroidManifest.xml` 的 `<application>` 标签内，`<activity>` 之前添加：

```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="YOUR_ANDROID_AMAP_KEY" />
```

- [ ] **Step 2: iOS — 添加 API Key**

修改 `ios/Runner/AppDelegate.swift`：

```swift
import Flutter
import UIKit
import AMapFoundationKit   // 新增

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    AMapServices.sharedServices().apiKey = "YOUR_IOS_AMAP_KEY"  // 新增
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

- [ ] **Step 3: iOS — Info.plist 隐私描述**

在 `ios/Runner/Info.plist` 的 `<dict>` 内添加定位权限描述（高德 SDK 需要，即使不使用定位功能）：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要定位权限以在地图上显示当前位置</string>
```

---

## Task 1: 依赖 + 隐私初始化

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/main.dart`

- [ ] **Step 1: 添加依赖**

在 `pubspec.yaml` 的 `dependencies:` 下添加：

```yaml
  # 高德地图
  amap_flutter_map: ^3.0.0
  amap_flutter_base: ^3.0.0
```

- [ ] **Step 2: 安装依赖**

```bash
cd packages/roadbook-flutter
flutter pub get
```

预期：依赖安装成功，无版本冲突。

- [ ] **Step 3: 隐私合规初始化**

高德 SDK 要求在创建任何地图 Widget 前调用隐私同意 API（审核要求）。修改 `lib/main.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 高德地图隐私合规（需在展示隐私弹窗后调用，此处假设已在启动协议中展示）
  await AMapInitializer.updatePrivacyShow(
    AMapPrivacyInfoState.didShow,
    AMapPrivacyInfoContainStatus.didContain,
  );
  await AMapInitializer.updatePrivacyAgree(AMapPrivacyAgreeStatus.didAgree);
  runApp(const ProviderScope(child: RoadbookApp()));
}
```

- [ ] **Step 4: 确认编译**

```bash
flutter build apk --debug 2>&1 | tail -5
```

预期：`BUILD SUCCESSFUL`（或 Flutter build 成功输出）。

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/main.dart \
  android/app/src/main/AndroidManifest.xml \
  ios/Runner/AppDelegate.swift ios/Runner/Info.plist
git commit -m "feat(map): add amap_flutter_map deps and native key setup"
```

---

## Task 2: AmapPoi 模型

**Files:**
- Create: `lib/shared/models/amap_poi.dart`
- Create: `test/unit/models/amap_poi_test.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/unit/models/amap_poi_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/amap_poi.dart';

void main() {
  group('AmapPoi.fromJson', () {
    test('解析完整 POI 响应', () {
      final json = {
        'id': 'B000A806R5',
        'name': '故宫博物院',
        'address': '景山前街4号',
        'location': '116.397026,39.917839',
        'type': '风景名胜;景点;景点',
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.id, 'B000A806R5');
      expect(poi.name, '故宫博物院');
      expect(poi.address, '景山前街4号');
      expect(poi.longitude, closeTo(116.397026, 0.000001));
      expect(poi.latitude, closeTo(39.917839, 0.000001));
      expect(poi.type, '风景名胜;景点;景点');
    });

    test('address 为空字符串时保留空字符串', () {
      final json = {
        'id': 'B001',
        'name': '某地',
        'address': '',
        'location': '116.0,39.0',
        'type': null,
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.address, '');
      expect(poi.type, isNull);
    });

    test('location 格式为 lng,lat', () {
      final json = {
        'id': 'X',
        'name': 'X',
        'address': 'X',
        'location': '120.5,30.2',
        'type': null,
      };
      final poi = AmapPoi.fromJson(json);
      expect(poi.longitude, closeTo(120.5, 0.001));
      expect(poi.latitude, closeTo(30.2, 0.001));
    });
  });
}
```

- [ ] **Step 2: 运行测试，确认失败**

```bash
cd packages/roadbook-flutter
flutter test test/unit/models/amap_poi_test.dart
```

预期：FAIL，`AmapPoi` 未定义。

- [ ] **Step 3: 实现 AmapPoi**

创建 `lib/shared/models/amap_poi.dart`：

```dart
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
```

- [ ] **Step 4: 运行测试，确认通过**

```bash
flutter test test/unit/models/amap_poi_test.dart
```

预期：All tests passed。

- [ ] **Step 5: Commit**

```bash
git add lib/shared/models/amap_poi.dart test/unit/models/amap_poi_test.dart
git commit -m "feat(map): add AmapPoi model with fromJson parsing"
```

---

## Task 3: 日期分组 Helper + 重构 ScheduleListPanel

`ScheduleListPanel` 中的 `_schedulesForDay` 逻辑地图 Tab 也需要，提取为共享 helper。

**Files:**
- Create: `lib/shared/utils/schedule_day_helper.dart`
- Create: `test/unit/utils/schedule_day_helper_test.dart`
- Modify: `lib/features/schedule/presentation/schedule_list_panel.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/unit/utils/schedule_day_helper_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';
import 'package:roadbook_flutter/shared/utils/schedule_day_helper.dart';

Schedule _s({int id = 1, DateTime? start, DateTime? end, bool hotel = false}) =>
    Schedule(
      id: id,
      tId: 1,
      name: 'Test',
      coordinate: '116.0,39.0',
      address: 'Addr',
      isHotel: hotel,
      startTime: start,
      endTime: end,
    );

void main() {
  final travelStart = DateTime(2026, 3, 24);  // Day 1

  group('schedulesForDay', () {
    test('day=0 返回无时间的行程（待规划）', () {
      final all = [
        _s(id: 1, start: null),                          // 待规划
        _s(id: 2, start: DateTime(2026, 3, 24, 9, 0)),   // Day 1
      ];
      final result = schedulesForDay(0, all, travelStart);
      expect(result.map((s) => s.id), [1]);
    });

    test('day=1 返回第一天的行程，按时间排序', () {
      final all = [
        _s(id: 1, start: DateTime(2026, 3, 24, 14, 0)), // Day 1 下午
        _s(id: 2, start: DateTime(2026, 3, 24, 9, 0)),  // Day 1 上午
        _s(id: 3, start: DateTime(2026, 3, 25, 9, 0)),  // Day 2
      ];
      final result = schedulesForDay(1, all, travelStart);
      expect(result.map((s) => s.id), [2, 1]);
    });

    test('酒店横跨多天，在每天都出现', () {
      final all = [
        _s(
          id: 1,
          start: DateTime(2026, 3, 24, 14, 0),
          end: DateTime(2026, 3, 26, 12, 0),
          hotel: true,
        ),
      ];
      expect(schedulesForDay(1, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(2, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(3, all, travelStart).map((s) => s.id), [1]);
      expect(schedulesForDay(4, all, travelStart), isEmpty);
    });

    test('空列表返回空', () {
      expect(schedulesForDay(1, [], travelStart), isEmpty);
    });
  });
}
```

- [ ] **Step 2: 运行，确认失败**

```bash
flutter test test/unit/utils/schedule_day_helper_test.dart
```

预期：FAIL，`schedule_day_helper` 未定义。

- [ ] **Step 3: 实现 Helper**

创建 `lib/shared/utils/schedule_day_helper.dart`：

```dart
// lib/shared/utils/schedule_day_helper.dart
import '../models/schedule.dart';

/// 返回指定天的行程列表（与 ScheduleListPanel 逻辑一致）。
/// [day] 0 = 待规划，1-N = 第 N 天
/// [travelStart] 旅程开始日期（本地时间）
List<Schedule> schedulesForDay(
  int day,
  List<Schedule> all,
  DateTime travelStart,
) {
  if (day == 0) {
    return all.where((s) => s.startTime == null).toList();
  }
  return all.where((s) {
    if (s.startTime == null) return false;
    final startDay =
        s.startTime!.toLocal().difference(travelStart).inDays + 1;
    if (s.isHotel && s.endTime != null) {
      final endDay =
          s.endTime!.toLocal().difference(travelStart).inDays + 1;
      return day >= startDay && day <= endDay;
    }
    return startDay == day;
  }).toList()
    ..sort((a, b) =>
        (a.startTime ?? DateTime(0)).compareTo(b.startTime ?? DateTime(0)));
}
```

- [ ] **Step 4: 测试通过**

```bash
flutter test test/unit/utils/schedule_day_helper_test.dart
```

- [ ] **Step 5: 重构 ScheduleListPanel 使用 Helper**

修改 `lib/features/schedule/presentation/schedule_list_panel.dart`：

在文件顶部 import 列表中添加：
```dart
import '../../../shared/utils/schedule_day_helper.dart';
```

将 `_schedulesForDay` 方法替换为对 helper 的代理调用：
```dart
List<Schedule> _schedulesForDay(int day, List<Schedule> all) =>
    schedulesForDay(day, all, travel.startDate);
```

（删除原来的方法体，保留方法签名但委托给 helper。）

- [ ] **Step 6: 运行全部测试，确认无回归**

```bash
flutter test
```

预期：所有测试通过。

- [ ] **Step 7: Commit**

```bash
git add lib/shared/utils/schedule_day_helper.dart \
  test/unit/utils/schedule_day_helper_test.dart \
  lib/features/schedule/presentation/schedule_list_panel.dart
git commit -m "refactor: extract schedulesForDay helper for map+list reuse"
```

---

## Task 4: MapState + MapStateNotifier

**Files:**
- Create: `lib/features/travel/presentation/map/map_state_notifier.dart`
- Create: `test/unit/features/map/map_state_notifier_test.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/unit/features/map/map_state_notifier_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_state_notifier.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';
import 'package:roadbook_flutter/shared/providers/dio_provider.dart';
import 'package:dio/dio.dart';

class MockDio extends Mock implements Dio {}
class MockScheduleNotifier extends AutoDisposeFamilyAsyncNotifier<List<dynamic>, int>
    with Mock
    implements ScheduleNotifier {
  @override
  Future<List<dynamic>> build(int arg) async => [];
}

ProviderContainer _makeContainer({Dio? dio}) {
  final mockDio = dio ?? MockDio();
  return ProviderContainer(overrides: [
    dioProvider.overrideWithValue(mockDio),
  ]);
}

void main() {
  const travelId = 42;

  group('MapStateNotifier 初始状态', () {
    test('默认 day 模式，selectedScheduleId null，搜索城市全国', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.day);
      expect(state.selectedScheduleId, isNull);
      expect(state.searchCity, '全国');
      expect(state.poiResults, isEmpty);
      expect(state.isSearching, isFalse);
    });
  });

  group('mode 切换', () {
    test('enterSearchMode → mode=search，清空 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..selectMarker(99)
        ..enterSearchMode();
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.search);
      expect(state.selectedScheduleId, isNull);
    });

    test('exitSearchMode → mode=day，清空 poiResults 和 selectedPoiId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..enterSearchMode()
        ..selectPoi('poi_1')
        ..exitSearchMode();
      final state = container.read(mapStateProvider(travelId));
      expect(state.mode, MapMode.day);
      expect(state.selectedPoiId, isNull);
      expect(state.poiResults, isEmpty);
    });
  });

  group('Marker 选择', () {
    test('selectMarker 更新 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).selectMarker(5);
      expect(container.read(mapStateProvider(travelId)).selectedScheduleId, 5);
    });

    test('clearMarker 置空 selectedScheduleId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier)
        ..selectMarker(5)
        ..clearMarker();
      expect(container.read(mapStateProvider(travelId)).selectedScheduleId, isNull);
    });
  });

  group('POI 选择', () {
    test('selectPoi 更新 selectedPoiId', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).selectPoi('abc');
      expect(container.read(mapStateProvider(travelId)).selectedPoiId, 'abc');
    });
  });

  group('城市切换', () {
    test('setSearchCity 更新 searchCity', () {
      final container = _makeContainer();
      addTearDown(container.dispose);
      container.read(mapStateProvider(travelId).notifier).setSearchCity('北京');
      expect(container.read(mapStateProvider(travelId)).searchCity, '北京');
    });
  });
}
```

- [ ] **Step 2: 运行，确认失败**

```bash
flutter test test/unit/features/map/map_state_notifier_test.dart
```

预期：FAIL，`map_state_notifier` 未定义。

- [ ] **Step 3: 实现 MapState + MapStateNotifier**

创建 `lib/features/travel/presentation/map/map_state_notifier.dart`：

```dart
// lib/features/travel/presentation/map/map_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/providers/dio_provider.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import '../../../../features/schedule/data/schedule_repository.dart';

enum MapMode { day, search }

class MapState {
  const MapState({
    this.mode = MapMode.day,
    this.selectedScheduleId,
    this.searchCity = '全国',
    this.poiResults = const [],
    this.selectedPoiId,
    this.isSearching = false,
  });

  final MapMode mode;
  final int? selectedScheduleId;
  final String searchCity;
  final List<AmapPoi> poiResults;
  final String? selectedPoiId;
  final bool isSearching;

  MapState copyWith({
    MapMode? mode,
    Object? selectedScheduleId = _sentinel,
    String? searchCity,
    List<AmapPoi>? poiResults,
    Object? selectedPoiId = _sentinel,
    bool? isSearching,
  }) =>
      MapState(
        mode: mode ?? this.mode,
        selectedScheduleId: selectedScheduleId == _sentinel
            ? this.selectedScheduleId
            : selectedScheduleId as int?,
        searchCity: searchCity ?? this.searchCity,
        poiResults: poiResults ?? this.poiResults,
        selectedPoiId: selectedPoiId == _sentinel
            ? this.selectedPoiId
            : selectedPoiId as String?,
        isSearching: isSearching ?? this.isSearching,
      );
}

const _sentinel = Object();

// ─── Provider ─────────────────────────────────────────────────────────────────

final mapStateProvider = NotifierProvider.autoDispose
    .family<MapStateNotifier, MapState, int>(MapStateNotifier.new);

class MapStateNotifier extends AutoDisposeFamilyNotifier<MapState, int> {
  @override
  MapState build(int arg) => const MapState();

  void enterSearchMode() {
    state = state.copyWith(
      mode: MapMode.search,
      selectedScheduleId: null,
      poiResults: [],
    );
  }

  void exitSearchMode() {
    state = state.copyWith(
      mode: MapMode.day,
      poiResults: [],
      selectedPoiId: null,
      isSearching: false,
    );
  }

  void selectMarker(int scheduleId) {
    state = state.copyWith(selectedScheduleId: scheduleId);
  }

  void clearMarker() {
    state = state.copyWith(selectedScheduleId: null);
  }

  void selectPoi(String poiId) {
    state = state.copyWith(selectedPoiId: poiId);
  }

  void setSearchCity(String city) {
    state = state.copyWith(searchCity: city);
  }

  Future<void> searchPoi(String keyword) async {
    state = state.copyWith(isSearching: true, poiResults: []);
    try {
      final dio = ref.read(dioProvider);
      final resp = await dio.get<Map<String, dynamic>>(
        '/_AMapService/v3/place/text',
        queryParameters: {
          'keywords': keyword,
          'city': state.searchCity,
          'output': 'json',
          'pageSize': '20',
        },
      );
      final data = resp.data ?? {};
      final pois = ((data['pois'] as List?) ?? [])
          .map((e) => AmapPoi.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(isSearching: false, poiResults: pois);
    } catch (_) {
      state = state.copyWith(isSearching: false);
      rethrow;
    }
  }

  Future<void> quickAddSchedule(AmapPoi poi) async {
    final form = ScheduleFormData(
      tId: arg,
      name: poi.name,
      coordinate: '${poi.longitude},${poi.latitude}',
      address: poi.address,
      isHotel: false,
    );
    await ref.read(scheduleProvider(arg).notifier).add(form);
    exitSearchMode();
  }
}
```

- [ ] **Step 4: 测试通过**

```bash
flutter test test/unit/features/map/map_state_notifier_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/travel/presentation/map/map_state_notifier.dart \
  test/unit/features/map/map_state_notifier_test.dart
git commit -m "feat(map): add MapState and MapStateNotifier with Riverpod"
```

---

## Task 5: MapDaySelectorBar

顶部悬浮的 Day Chip 横向列表，右侧有搜索图标。

**Files:**
- Create: `lib/features/travel/presentation/map/map_day_selector.dart`
- Create: `test/widget/features/map/map_day_selector_test.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/widget/features/map/map_day_selector_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_day_selector.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_state_notifier.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';

void main() {
  Widget buildWidget({
    required int totalDays,
    required int travelId,
    int selectedDay = 1,
    MapMode mode = MapMode.day,
    VoidCallback? onSearchTap,
  }) {
    return ProviderScope(
      overrides: [
        selectedDayProvider(travelId).overrideWith((ref) => selectedDay),
        mapStateProvider(travelId).overrideWith(() {
          return MapStateNotifier()..build(travelId);
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: MapDaySelectorBar(
            travelId: travelId,
            totalDays: totalDays,
            onSearchTap: onSearchTap ?? () {},
          ),
        ),
      ),
    );
  }

  testWidgets('渲染正确数量的 Day Chip', (tester) async {
    await tester.pumpWidget(buildWidget(totalDays: 3, travelId: 1));
    expect(find.text('Day 1'), findsOneWidget);
    expect(find.text('Day 2'), findsOneWidget);
    expect(find.text('Day 3'), findsOneWidget);
  });

  testWidgets('搜索图标存在且可点击', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      buildWidget(totalDays: 2, travelId: 1, onSearchTap: () => tapped = true),
    );
    await tester.tap(find.byIcon(Icons.search));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: 运行，确认失败**

```bash
flutter test test/widget/features/map/map_day_selector_test.dart
```

- [ ] **Step 3: 实现 MapDaySelectorBar**

创建 `lib/features/travel/presentation/map/map_day_selector.dart`：

```dart
// lib/features/travel/presentation/map/map_day_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';

class MapDaySelectorBar extends ConsumerWidget {
  const MapDaySelectorBar({
    super.key,
    required this.travelId,
    required this.totalDays,
    required this.onSearchTap,
  });

  final int travelId;
  final int totalDays;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider(travelId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int day = 1; day <= totalDays; day++)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _DayChip(
                        day: day,
                        selected: selectedDay == day,
                        onTap: () => ref
                            .read(selectedDayProvider(travelId).notifier)
                            .state = day,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _SearchButton(onTap: onSearchTap),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withOpacity(0.35)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'Day $day',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
```

- [ ] **Step 4: 测试通过**

```bash
flutter test test/widget/features/map/map_day_selector_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/travel/presentation/map/map_day_selector.dart \
  test/widget/features/map/map_day_selector_test.dart
git commit -m "feat(map): add MapDaySelectorBar with day chips and search icon"
```

---

## Task 6: MapInfoBar

底部信息条：Day 模式显示 Schedule 信息（点击打开编辑），Search 模式显示 POI 信息（点击添加待规划）。

**Files:**
- Create: `lib/features/travel/presentation/map/map_info_bar.dart`
- Create: `test/widget/features/map/map_info_bar_test.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/widget/features/map/map_info_bar_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_info_bar.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';
import 'package:roadbook_flutter/shared/models/amap_poi.dart';

void main() {
  final schedule = Schedule(
    id: 1,
    tId: 1,
    name: '故宫博物院',
    coordinate: '116.397,39.917',
    address: '景山前街4号',
    isHotel: false,
    startTime: DateTime(2026, 3, 24, 9, 0),
    endTime: DateTime(2026, 3, 24, 12, 0),
  );

  final poi = AmapPoi(
    id: 'poi_1',
    name: '南锣鼓巷',
    address: '东城区南锣鼓巷',
    longitude: 116.4,
    latitude: 39.93,
  );

  testWidgets('Schedule 模式：显示名称和时间', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.schedule(
          schedule: schedule,
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('故宫博物院'), findsOneWidget);
    expect(find.text('09:00 — 12:00'), findsOneWidget);
  });

  testWidgets('POI 模式：显示名称和添加按钮', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.poi(
          poi: poi,
          onAdd: () {},
          isAdding: false,
        ),
      ),
    ));
    expect(find.text('南锣鼓巷'), findsOneWidget);
    expect(find.text('+ 加入待规划'), findsOneWidget);
  });

  testWidgets('onTap 回调触发', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: MapInfoBar.schedule(
          schedule: schedule,
          onTap: () => tapped = true,
        ),
      ),
    ));
    await tester.tap(find.byType(MapInfoBar));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: 运行，确认失败**

```bash
flutter test test/widget/features/map/map_info_bar_test.dart
```

- [ ] **Step 3: 实现 MapInfoBar**

创建 `lib/features/travel/presentation/map/map_info_bar.dart`：

```dart
// lib/features/travel/presentation/map/map_info_bar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';

final _timeFmt = DateFormat('HH:mm');

/// 底部信息条：两种工厂构造 — schedule（day 模式）和 poi（search 模式）
class MapInfoBar extends StatelessWidget {
  const MapInfoBar._({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  factory MapInfoBar.schedule({
    Key? key,
    required Schedule schedule,
    required VoidCallback onTap,
  }) {
    final start = schedule.startTime != null ? _timeFmt.format(schedule.startTime!) : null;
    final end = schedule.endTime != null ? _timeFmt.format(schedule.endTime!) : null;
    final time = (start != null && end != null)
        ? '$start — $end'
        : start ?? '待规划';
    return MapInfoBar._(
      key: key,
      title: schedule.name,
      subtitle: time,
      onTap: onTap,
    );
  }

  factory MapInfoBar.poi({
    Key? key,
    required AmapPoi poi,
    required VoidCallback onAdd,
    required bool isAdding,
  }) {
    return MapInfoBar._(
      key: key,
      title: poi.name,
      subtitle: poi.address,
      onTap: onAdd,
      actionLabel: '+ 加入待规划',
      onAction: onAdd,
      isLoading: isAdding,
    );
  }

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(width: 12),
              isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : GestureDetector(
                      onTap: onAction,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          actionLabel!,
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ] else
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 测试通过**

```bash
flutter test test/widget/features/map/map_info_bar_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/travel/presentation/map/map_info_bar.dart \
  test/widget/features/map/map_info_bar_test.dart
git commit -m "feat(map): add MapInfoBar with schedule and POI modes"
```

---

## Task 7: MapSearchBar

搜索模式顶部栏：左侧城市 Dropdown + 文本输入框 + 左箭头退出。

**Files:**
- Create: `lib/features/travel/presentation/map/map_search_bar.dart`
- Create: `test/widget/features/map/map_search_bar_test.dart`

- [ ] **Step 1: 写失败测试**

创建 `test/widget/features/map/map_search_bar_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/map/map_search_bar.dart';

void main() {
  Widget build({
    List<String> cities = const ['北京', '上海'],
    String selectedCity = '全国',
    ValueChanged<String>? onCityChanged,
    ValueChanged<String>? onSearch,
    VoidCallback? onClose,
  }) =>
      MaterialApp(
        home: Scaffold(
          body: MapSearchBar(
            cities: cities,
            selectedCity: selectedCity,
            onCityChanged: onCityChanged ?? (_) {},
            onSearch: onSearch ?? (_) {},
            onClose: onClose ?? () {},
          ),
        ),
      );

  testWidgets('城市选项包含全国和旅程城市', (tester) async {
    await tester.pumpWidget(build());
    // DropdownButton 展示当前选中值
    expect(find.text('全国'), findsOneWidget);
  });

  testWidgets('点击关闭按钮触发 onClose', (tester) async {
    bool closed = false;
    await tester.pumpWidget(build(onClose: () => closed = true));
    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(closed, isTrue);
  });

  testWidgets('提交搜索框触发 onSearch', (tester) async {
    String? searched;
    await tester.pumpWidget(build(onSearch: (v) => searched = v));
    await tester.enterText(find.byType(TextField), '故宫');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    expect(searched, '故宫');
  });
}
```

- [ ] **Step 2: 运行，确认失败**

```bash
flutter test test/widget/features/map/map_search_bar_test.dart
```

- [ ] **Step 3: 实现 MapSearchBar**

创建 `lib/features/travel/presentation/map/map_search_bar.dart`：

```dart
// lib/features/travel/presentation/map/map_search_bar.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.onSearch,
    required this.onClose,
  });

  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<String> onSearch;
  final VoidCallback onClose;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCities = ['全国', ...widget.cities];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          // 城市选择下拉
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedCity,
              items: allCities
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) widget.onCityChanged(v);
              },
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
              icon: const Icon(Icons.expand_more,
                  size: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 4),
          // 搜索输入框
          Expanded(
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '搜索地点、景区、餐厅...',
                hintStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              style: AppTextStyles.caption,
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) widget.onSearch(v.trim());
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 测试通过**

```bash
flutter test test/widget/features/map/map_search_bar_test.dart
```

- [ ] **Step 5: Commit**

```bash
git add lib/features/travel/presentation/map/map_search_bar.dart \
  test/widget/features/map/map_search_bar_test.dart
git commit -m "feat(map): add MapSearchBar with city selector and search input"
```

---

## Task 8: MapTabView（核心地图 Widget）

全屏 AMapWidget + 所有浮层的组装层。自定义 Marker 通过 Canvas API 渲染，虚线路径用 Polyline。

**Files:**
- Create: `lib/features/travel/presentation/map/map_tab_view.dart`

**注意：** AMapWidget 依赖原生渲染，无法在 unit/widget 测试中运行。本 Task 通过热重载手动验证。

- [ ] **Step 1: 实现自定义 Marker 渲染 helper**

在 `lib/features/travel/presentation/map/map_tab_view.dart` 中创建私有 helper。注意 `dart:ui` 需单独 import：

```dart
// lib/features/travel/presentation/map/map_tab_view.dart
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';
import '../../../../shared/models/amap_poi.dart';
import '../../../../shared/utils/schedule_day_helper.dart';
import '../../../../features/schedule/domain/schedule_provider.dart';
import '../../../../features/travel/domain/travel_detail_provider.dart';
import '../../../../features/schedule/presentation/schedule_edit_sheet.dart';
import 'map_state_notifier.dart';
import 'map_day_selector.dart';
import 'map_search_bar.dart';
import 'map_info_bar.dart';

/// 渲染圆角方块 Marker 图标（Canvas → BitmapDescriptor）
Future<BitmapDescriptor> _buildMarkerBitmap({
  required Color color,
  required String label,
  Color? borderColor,
  double size = 36,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = color;
  final rrect = ui.RRect.fromRectAndRadius(
    ui.Rect.fromLTWH(2, 2, size - 4, size - 4),
    const ui.Radius.circular(8),
  );
  canvas.drawRRect(rrect, paint);

  if (borderColor != null) {
    final borderPaint = ui.Paint()
      ..color = borderColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  // 白色边框
  final outerBorder = ui.Paint()
    ..color = Colors.white
    ..style = ui.PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawRRect(rrect, outerBorder);

  // 文字
  final paragraphBuilder = ui.ParagraphBuilder(
    ui.ParagraphStyle(textAlign: TextAlign.center),
  )
    ..pushStyle(ui.TextStyle(
      color: Colors.white,
      fontSize: label.length == 1 ? 14 : 11,
      fontWeight: ui.FontWeight.w800,
    ))
    ..addText(label);
  final paragraph = paragraphBuilder.build()
    ..layout(ui.ParagraphConstraints(width: size));
  canvas.drawParagraph(
    paragraph,
    ui.Offset(0, (size - paragraph.height) / 2),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
```

- [ ] **Step 2: 实现 MapTabView Widget**

继续在同文件写 `MapTabView`：

```dart
class MapTabView extends ConsumerStatefulWidget {
  const MapTabView({
    super.key,
    required this.travelId,
  });

  final int travelId;

  @override
  ConsumerState<MapTabView> createState() => _MapTabViewState();
}

class _MapTabViewState extends ConsumerState<MapTabView> {
  AMapController? _mapController;
  // 预渲染的 marker 图标缓存
  final Map<String, BitmapDescriptor> _iconCache = {};
  bool _iconsReady = false;

  @override
  void initState() {
    super.initState();
    _preloadIcons();
  }

  Future<void> _preloadIcons() async {
    // 预加载序号 1-10、酒店、POI 默认图标
    for (int i = 1; i <= 10; i++) {
      _iconCache['day_$i'] = await _buildMarkerBitmap(
        color: AppColors.primary,
        label: '$i',
      );
      _iconCache['hotel_$i'] = await _buildMarkerBitmap(
        color: AppColors.hotel,
        label: '🏨',
      );
      _iconCache['poi_$i'] = await _buildMarkerBitmap(
        color: AppColors.textSecondary,
        label: '$i',
      );
    }
    if (mounted) setState(() => _iconsReady = true);
  }

  BitmapDescriptor _icon(String key) =>
      _iconCache[key] ?? BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapStateProvider(widget.travelId));
    final schedulesAsync = ref.watch(scheduleProvider(widget.travelId));
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final selectedDay = ref.watch(selectedDayProvider(widget.travelId));

    final travel = travelAsync.valueOrNull;
    final schedules = schedulesAsync.valueOrNull ?? [];

    // 当天行程
    final daySchedules = travel != null
        ? schedulesForDay(selectedDay, schedules, travel.startDate)
        : <Schedule>[];

    // 有效坐标的行程
    final validSchedules = daySchedules
        .where((s) => s.coordinate.isNotEmpty && s.coordinate != '0,0')
        .toList();

    // Markers（行程模式）
    final Set<Marker> scheduleMarkers = {};
    for (int i = 0; i < validSchedules.length; i++) {
      final s = validSchedules[i];
      final parts = s.coordinate.split(',');
      if (parts.length != 2) continue;
      final iconKey = s.isHotel ? 'hotel_${i + 1}' : 'day_${i + 1}';
      scheduleMarkers.add(Marker(
        markerId: MarkerId('s_${s.id}'),
        position: LatLng(double.parse(parts[1]), double.parse(parts[0])),
        icon: _iconsReady ? _icon(iconKey) : BitmapDescriptor.defaultMarker,
        onTap: (id) {
          ref.read(mapStateProvider(widget.travelId).notifier).selectMarker(s.id!);
        },
      ));
    }

    // Polyline（虚线路径）
    final Set<Polyline> polylines = {};
    if (validSchedules.length > 1) {
      final points = validSchedules.map((s) {
        final p = s.coordinate.split(',');
        return LatLng(double.parse(p[1]), double.parse(p[0]));
      }).toList();
      polylines.add(Polyline(
        polylineId: PolylineId('path_$selectedDay'),
        points: points,
        color: AppColors.primary,
        width: 2,
        patterns: [PatternItem.dash(12), PatternItem.gap(8)],
      ));
    }

    // POI Markers（搜索模式）
    final Set<Marker> poiMarkers = {};
    if (mapState.mode == MapMode.search) {
      for (int i = 0; i < mapState.poiResults.length; i++) {
        final poi = mapState.poiResults[i];
        final selected = poi.id == mapState.selectedPoiId;
        final iconKey = selected ? 'day_${i + 1}' : 'poi_${i + 1}';
        poiMarkers.add(Marker(
          markerId: MarkerId('poi_${poi.id}'),
          position: LatLng(poi.latitude, poi.longitude),
          icon: _iconsReady ? _icon(iconKey) : BitmapDescriptor.defaultMarker,
          onTap: (_) {
            ref.read(mapStateProvider(widget.travelId).notifier).selectPoi(poi.id);
          },
        ));
      }
    }

    // 当前选中的 Schedule（用于 InfoBar）
    final selectedSchedule = mapState.selectedScheduleId != null
        ? schedules.where((s) => s.id == mapState.selectedScheduleId).firstOrNull
        : null;
    // 当前选中的 POI（用于 InfoBar）
    final selectedPoi = mapState.selectedPoiId != null
        ? mapState.poiResults.where((p) => p.id == mapState.selectedPoiId).firstOrNull
        : null;

    final infoBarHeight = (selectedSchedule != null || selectedPoi != null) ? 72.0 : 0.0;

    return Stack(
      children: [
        // ── 地图底层
        AMapWidget(
          onMapCreated: (ctrl) => _mapController = ctrl,
          markers: mapState.mode == MapMode.day ? scheduleMarkers : poiMarkers,
          polylines: mapState.mode == MapMode.day ? polylines : {},
          onTap: (_) {
            // 点击地图空白处清空选中
            ref.read(mapStateProvider(widget.travelId).notifier).clearMarker();
          },
        ),

        // ── 顶部浮层
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: mapState.mode == MapMode.day
              ? MapDaySelectorBar(
                  travelId: widget.travelId,
                  totalDays: travel != null
                      ? travel.endDate.difference(travel.startDate).inDays + 1
                      : 1,
                  onSearchTap: () => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .enterSearchMode(),
                )
              : MapSearchBar(
                  cities: travel?.cities ?? [],
                  selectedCity: mapState.searchCity,
                  onCityChanged: (city) => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .setSearchCity(city),
                  onSearch: (keyword) => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .searchPoi(keyword),
                  onClose: () => ref
                      .read(mapStateProvider(widget.travelId).notifier)
                      .exitSearchMode(),
                ),
        ),

        // ── 底部信息条（AnimatedSlide）
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            offset: infoBarHeight > 0
                ? Offset.zero
                : const Offset(0, 1),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: infoBarHeight > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: selectedSchedule != null
                  ? MapInfoBar.schedule(
                      schedule: selectedSchedule,
                      onTap: () {
                        if (travel != null) {
                          ScheduleEditSheet.show(
                            context,
                            travel: travel,
                            schedule: selectedSchedule,
                          );
                        }
                      },
                    )
                  : selectedPoi != null
                      ? MapInfoBar.poi(
                          poi: selectedPoi,
                          isAdding: false,
                          onAdd: () async {
                            try {
                              await ref
                                  .read(mapStateProvider(widget.travelId).notifier)
                                  .quickAddSchedule(selectedPoi);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已加入待规划')),
                                );
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('添加失败，请重试')),
                                );
                              }
                            }
                          },
                        )
                      : const SizedBox.shrink(),
            ),
          ),
        ),

        // ── 搜索中 Loading 指示
        if (mapState.isSearching)
          const Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('搜索中...', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 3: 手动验证（热重载）**

连接真机或模拟器（需 Google Play 服务）：

```bash
flutter run --debug
```

验证清单：
- 地图 Tab 显示高德地图底图（不再是占位符）
- Day Chip 可滚动，点击切换高亮
- 有坐标的行程显示橙色圆角方块 Marker + 序号
- 酒店显示紫色 Marker
- 多站点间显示橙色虚线
- 点击 Marker 底部滑出信息条，显示名称和时间
- 点击信息条打开 ScheduleEditSheet
- 点击搜索图标切换到 MapSearchBar
- 输入关键词回车，地图显示 POI Marker
- 点击 POI Marker，底部出现"+ 加入待规划"
- 点击"+ 加入待规划"，行程 Tab 可见新条目，地图恢复 Day 模式

- [ ] **Step 4: Commit**

```bash
git add lib/features/travel/presentation/map/map_tab_view.dart
git commit -m "feat(map): implement MapTabView with AMapWidget, markers, polyline, search"
```

---

## Task 9: 接入 TravelDetailScreen

替换占位符为 `MapTabView`。

**Files:**
- Modify: `lib/features/travel/presentation/travel_detail_screen.dart`

- [ ] **Step 1: 替换占位符**

在 `lib/features/travel/presentation/travel_detail_screen.dart` 顶部添加 import：

```dart
import 'map/map_tab_view.dart';
```

找到地图 Tab 占位符（搜索 `地图功能将在 Plan 5 实现` 所在的 `Center(...)` 块）并替换为：

```dart
// ── 地图 Tab
MapTabView(travelId: widget.travelId),
```

- [ ] **Step 2: 运行所有测试**

```bash
cd packages/roadbook-flutter
flutter test
```

预期：所有之前测试通过，无新失败。

- [ ] **Step 3: 手动验证完整流程**

在真机/模拟器上打开任意旅程详情页，确认：
- 地图 Tab 和行程 Tab 切换天数时同步（`selectedDayProvider` 共享）
- 行程 Tab 新建行程后，切换到地图 Tab，Marker 更新
- 从地图搜索添加的地点，在行程 Tab 的"待规划"区域可见

- [ ] **Step 4: Commit**

```bash
git add lib/features/travel/presentation/travel_detail_screen.dart
git commit -m "feat(map): wire MapTabView into TravelDetailScreen, remove placeholder"
```

---

## 完成检查清单

- [ ] `flutter test` 全部通过
- [ ] 所有 Marker 类型正确（橙色=普通，紫色=酒店，灰色=POI）
- [ ] 虚线路径连接当天站点
- [ ] Day Chip 切换同步行程 Tab 天数
- [ ] 搜索 → POI Marker → 加入待规划 完整流程
- [ ] `coordinate == "0,0"` 的行程不渲染 Marker
- [ ] 底部信息条正确滑入/出
