# Flutter TravelDetail 地图 Tab 设计文档

**日期**: 2026-03-24
**状态**: 待实现
**功能**: TravelDetail 页面地图 Tab 完整实现（Plan 5）

---

## 背景

`TravelDetailScreen` 已实现"行程"Tab，地图 Tab 目前是占位符（"地图功能将在 Plan 5 实现"）。本文档描述地图 Tab 的完整设计，包含行程可视化和 POI 搜索两大功能。

---

## 视觉设计决策

### 整体布局
**全屏地图**模式：`AMapWidget` 铺满整个 Tab 区域，所有 UI 元素以浮层形式叠加。

### 地图 SDK
使用 `amap_flutter_map`（高德官方 Flutter 原生 SDK），需在 `pubspec.yaml` 新增：
```yaml
amap_flutter_map: ^3.0.0
amap_flutter_base: ^3.0.0
```

**原生配置前置条件**（实现前必须完成）：
- Android：`AndroidManifest.xml` 中添加高德 Map SDK API Key（Mobile Web Key）
- iOS：`Info.plist` 中添加 `AMapLocationPrivacyAgreeStatus`、`AppDelegate.swift` 中初始化 Key
- 高德开放平台需分别申请 Android 包名和 iOS BundleID 对应的 Key

### 两种模式
| 模式 | 触发 | 顶部 UI |
|------|------|---------|
| **Day 模式**（默认） | 启动 / 退出搜索 | Day Chip 横向滚动 + 右侧搜索图标 |
| **Search 模式** | 点击搜索图标 | 城市下拉 + 文本输入框 + 左箭头退出 |

两种模式互斥，切换时清空对方状态。

### Marker 视觉规范
| 类型 | 颜色 | 内容 |
|------|------|------|
| 普通行程站点 | 橙色 `#F97316` | 圆角方块 + 当天序号 |
| 酒店站点 | 紫色 `#8B5CF6` | 圆角方块 + 🏨 |
| POI 搜索结果 | 灰色 `#A8A29E` | 圆角方块 + 序号 |
| 选中 POI | 橙色边框 `#F97316` | 圆角方块 + 序号（高亮） |

当天站点之间用**橙色虚线**连接，表示行进路径。

### 底部信息条（MapInfoBar）
- 点击任意 Marker 后 `AnimatedSlide` 从底部滑入
- **Day 模式**：显示 Schedule 名称、时间段；点击整条信息条打开 `ScheduleEditSheet`
- **Search 模式**：显示 POI 名称、地址；右侧"＋加入待规划"按钮

---

## 架构设计

### 文件结构

```
packages/roadbook-flutter/lib/features/travel/presentation/map/
├── map_tab_view.dart            ← Stack 根 widget，组装所有浮层
├── map_day_selector.dart        ← Day Chip Row（day 模式顶部）
├── map_search_bar.dart          ← 搜索栏（search 模式顶部）
├── map_info_bar.dart            ← 底部信息条（两种模式共用，内容不同）
└── map_state_notifier.dart      ← Notifier + MapState 数据类

packages/roadbook-flutter/lib/shared/models/
└── amap_poi.dart                ← POI 搜索结果模型（自定义，非 SDK 类型）
```

### 依赖关系
```
MapTabView
├── consumes: mapStateProvider (新建)
├── consumes: scheduleProvider(travelId) (已有，权威数据源)
├── consumes: selectedDayProvider(travelId) (已有，共享天数选择)
├── renders: AMapWidget (amap_flutter_map)
├── renders: MapDaySelectorBar | MapSearchBar (按 mode 切换)
└── renders: MapInfoBar
```

---

## 状态管理

### 复用已有 Provider

| Provider | 说明 |
|----------|------|
| `scheduleProvider(travelId)` | **唯一数据源**，提供 `List<Schedule>`，含 CRUD 方法 |
| `selectedDayProvider(travelId)` | 共享天数选择（0=待规划，1-N=第N天），与行程 Tab 共用 |

### 新建 `MapState` 数据类

```dart
enum MapMode { day, search }

class MapState {
  final MapMode mode;
  final int? selectedScheduleId;     // day 模式：选中的 Schedule ID
  final String searchCity;           // search 模式：搜索城市，默认 "全国"
  final List<AmapPoi> poiResults;    // search 模式：POI 搜索结果
  final String? selectedPoiId;       // search 模式：选中的 POI ID
  final bool isSearching;            // 搜索请求进行中
}
```

> `selectedDayIndex` 不在 `MapState` 中，统一读写 `selectedDayProvider(travelId)`。

### 新建 `MapStateNotifier`

使用 `Notifier.autoDispose.family<MapState, int>`（与项目现有 `AsyncNotifierProvider.autoDispose.family` 风格一致，map 状态为同步状态故用 `Notifier` 而非 `AsyncNotifier`）。

```dart
final mapStateProvider = NotifierProvider.autoDispose
    .family<MapStateNotifier, MapState, int>(MapStateNotifier.new);
```

| 方法 | 行为 |
|------|------|
| `enterSearchMode()` | mode → search，清空 poiResults、selectedScheduleId |
| `exitSearchMode()` | mode → day，清空 poiResults、selectedPoiId |
| `selectMarker(int scheduleId)` | 更新 selectedScheduleId |
| `clearMarker()` | selectedScheduleId → null |
| `searchPoi(String keyword)` | isSearching → true → 调用高德 POI REST API → 更新 poiResults → isSearching → false |
| `selectPoi(String poiId)` | 更新 selectedPoiId |
| `quickAddSchedule(AmapPoi poi, int travelId)` | 构建 ScheduleFormData → `ref.read(scheduleProvider(travelId).notifier).add(form)` → exitSearchMode() → toast |

`selectDay(int day)` 直接写 `ref.read(selectedDayProvider(travelId).notifier).state = day`，不在 MapStateNotifier 中封装。

---

## 数据流

### Day 模式

```
scheduleProvider(travelId) → List<Schedule>
  → 按 startTime 日期分组：Map<int dayIndex, List<Schedule>>
    （startTime==null → dayIndex=0，即"待规划"）
  → selectedDayProvider(travelId) 值为当前天 (1-N)
  → 过滤出当天 Schedule 列表 → 渲染圆角方形 Marker + 虚线路径
  → coordinate=="0,0" 或空 → 跳过不渲染 Marker
  → selectedScheduleId 变化 → MapInfoBar AnimatedSlide 滑入
  → 点击 InfoBar → ScheduleEditSheet（复用已有组件）

fitBounds 时底部 padding 需加上 MapInfoBar 高度（约 72dp），避免 Marker 被遮挡
```

### Search 模式

```
MapSearchBar 城市选择器：travel.cities（显示名如"北京"）+ ["全国"]
  （高德 POI 搜索 city 参数直接接受城市名，无需转换为城市码）

MapSearchBar 输入 keyword + searchCity
  → mapStateNotifier.searchPoi(keyword)
  → HTTP GET /_AMapService/v3/place/text
      ?keywords={keyword}&city={searchCity}&output=json&pageSize=20
      （经后端代理自动注入 key）
  → 解析响应 → List<AmapPoi> 更新 poiResults
  → 渲染灰色 POI Marker（不显示虚线路径）
  → 点击 POI Marker → MapInfoBar 滑入（POI 信息 + "＋加入待规划"）
  → 点击"＋加入待规划" → quickAddSchedule(poi, travelId)：
      ScheduleFormData {
        tId: travelId,
        name: poi.name,
        coordinate: "${poi.longitude},${poi.latitude}",
        address: poi.address,
        isHotel: false,
        startTime: null,   // 待规划，无时间
        endTime: null,
      }
      → ref.read(scheduleProvider(travelId).notifier).add(form)
         （自动更新 scheduleProvider 缓存，行程 Tab 立即可见）
      → exitSearchMode()
      → Toast "已加入待规划"
```

### `AmapPoi` 自定义模型

```dart
class AmapPoi {
  final String id;
  final String name;
  final String address;
  final double longitude;
  final double latitude;
  final String? type;      // POI 类型（如"景点"）
}
```

解析自高德 `/v3/place/text` 响应的 `pois[]` 数组。

---

## 边界处理

| 情况 | 处理 |
|------|------|
| `coordinate == "0,0"` 或空 | 不渲染 Marker，行程 Tab 正常显示 |
| 当天只有 1 个站点 | 不绘制虚线路径，仅显示单个 Marker |
| POI 搜索无结果 | 不显示 InfoBar，Toast "未找到相关地点" |
| 搜索请求失败（网络/后端） | Toast 错误提示，isSearching → false |
| 所有站点无有效坐标 | 地图默认显示 travel.cities[0] 区域（高德 AMapWidget city 参数） |
| scheduleProvider 加载中 | 地图显示空白（无 Marker），不影响地图底图渲染 |

---

## 行程 Tab 联动

- `startTime==null` 的 Schedule 在行程 Tab 归入 day 0（"待规划"）分组
- `selectedDayProvider` 共享：行程 Tab 切换天数时，地图 Tab 同步高亮对应天路线（Tab 切换后触发）
- 行程 Tab 的"待规划"分组 UI 改造不在本次范围内

---

## 不在本次范围内

- 路线规划（驾车 / 步行导航）
- 离线地图缓存
- 地图样式切换（白昼 / 夜间）
- 多天路线同时显示
- 行程 Tab 的"待规划"分组 UI 改造
