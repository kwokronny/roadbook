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

### 两种模式
| 模式 | 触发 | 顶部 UI |
|------|------|---------|
| **Day 模式**（默认） | 启动 / 退出搜索 | Day Chip 横向滚动 + 右侧搜索图标 |
| **Search 模式** | 点击搜索图标 | 城市选择器 + 文本输入框 + 左箭头退出 |

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
└── map_state_notifier.dart      ← StateNotifier + MapState 数据类
```

### 依赖关系
```
MapTabView
├── consumes: mapStateProvider
├── consumes: travelDetailProvider
├── renders: AMapWidget (amap_flutter_map)
├── renders: MapDaySelectorBar | MapSearchBar (按 mode 切换)
└── renders: MapInfoBar

MapStateNotifier
├── depends on: scheduleRepository (快速添加)
└── depends on: travelDetailProvider (读取 travel.cities)
```

---

## 状态管理

### `MapState` 数据类

```dart
enum MapMode { day, search }

class MapState {
  final MapMode mode;
  final int selectedDayIndex;        // day 模式：当前选中天（0-based）
  final int? selectedScheduleId;     // day 模式：选中的 Schedule ID
  final String searchCity;           // search 模式：搜索城市，默认 "全国"
  final List<AMapPoi> poiResults;    // search 模式：POI 搜索结果
  final String? selectedPoiId;       // search 模式：选中的 POI ID
  final bool isSearching;            // 搜索请求进行中
}
```

### `MapStateNotifier` 方法

| 方法 | 行为 |
|------|------|
| `enterSearchMode()` | mode → search，清空 poiResults、selectedScheduleId |
| `exitSearchMode()` | mode → day，清空 poiResults、selectedPoiId |
| `selectDay(int index)` | 更新 selectedDayIndex，清空 selectedScheduleId，触发镜头 fitBounds |
| `selectMarker(int scheduleId)` | 更新 selectedScheduleId |
| `searchPoi(String keyword)` | 调用高德 POI 搜索 API，更新 poiResults，isSearching 控制 loading |
| `selectPoi(String poiId)` | 更新 selectedPoiId |
| `quickAddSchedule(AMapPoi poi)` | 构建 Schedule → repository.add() → 刷新 → exitSearchMode() → toast |

---

## 数据流

### Day 模式

```
travelDetailProvider.travel.schedules
  → 按 startTime 日期分组：Map<int dayIndex, List<Schedule>>
  → selectedDayIndex 对应列表 → 渲染 Marker + 虚线路径
  → selectedScheduleId 变化 → MapInfoBar 滑入（Schedule 信息）
  → 点击 InfoBar → ScheduleEditSheet（复用已有组件）
```

### Search 模式

```
MapSearchBar 输入 keyword + searchCity
  → mapStateNotifier.searchPoi()
  → 高德 PlaceSearch（keyword, city, pageSize: 20）
  → poiResults → 渲染灰色 POI Marker
  → 点击 POI Marker → MapInfoBar 滑入（POI 信息 + "＋加入待规划"）
  → 点击"＋加入待规划" → quickAddSchedule(poi)
      Schedule {
        name: poi.name,
        coordinate: "${poi.location.longitude},${poi.location.latitude}",
        address: poi.address,
        tId: travelId,
        startTime: null,   // 待规划，无时间
        endTime: null,
      }
      → scheduleRepository.add()
      → travelDetailProvider 刷新
      → exitSearchMode()
      → Toast "已加入待规划"
```

---

## 边界处理

| 情况 | 处理 |
|------|------|
| `coordinate == "0,0"` 或空 | 不渲染 Marker，行程 Tab 正常显示 |
| POI 搜索无结果 | 不显示 InfoBar，地图中央 Toast "未找到相关地点" |
| 搜索请求失败 | Toast 错误提示，isSearching → false |
| 所有站点无有效坐标 | 地图默认显示 travel.cities[0] 区域（高德地图城市定位） |
| 单天只有 1 个站点 | 不绘制虚线路径，仅显示单个 Marker |

---

## 行程 Tab 联动

行程 Tab 中无时间的 Schedule（`startTime == null`）归入"待规划"分组，显示在当天列表末尾或独立区块，与已有 `ScheduleListPanel` 的 day 分组逻辑协调（超出本文档范围，在行程 Tab 迭代中处理）。

---

## 不在本次范围内

- 路线规划（驾车 / 步行导航）
- 离线地图缓存
- 地图样式切换（白昼 / 夜间）
- 多天路线同时显示
- 行程 Tab 的"待规划"分组 UI 改造
