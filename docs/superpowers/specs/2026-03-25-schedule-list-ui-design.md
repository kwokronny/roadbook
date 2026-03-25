# 行程列表 UI 交互设计文档

**日期**: 2026-03-25
**状态**: 已确认
**涉及文件**: `packages/roadbook-flutter/lib/features/schedule/`

---

## 背景与目标

现有 `ScheduleListPanel` 使用传统卡片列表（左侧色条 + 白色背景卡片），存在信息密度过高、时间显示太小、视觉层级不清晰的问题。本次全面重设计为**时间轴风格**，提升可读性与操作效率。

---

## 整体布局

```
┌─────────────────────────────────────┐
│  AppBar（旅程名 · 城市 · 地图/列表切换）  │
├───────────────────────┬─────────────┤
│                       │  右侧天数栏  │
│   左侧时间轴内容区      │  (56px)     │
│                       │  DAY 1 周一  │
│  ○ 09:00  ✏  [nav]   │  DAY 2 周二  │
│  ⛩ 太宰府天满宫        │  DAY 3 周三  │
│    福冈县太宰府市...    │  ...        │
│    [📷][📷][📷] +2    │  待规划     │
│  │                    │             │
│  ○ 住宿  ✏  [nav]    │             │
│  🏨 博多阿维斯塔酒店   │             │
│    福冈市博多区...     │             │
│  │                    │             │
│  ○ 14:30  ✏  [nav]   │             │
│  📍 柳川川下り         │             │
│    ...                │             │
├───────────────────────┴─────────────┤
│                              [+ FAB] │
└─────────────────────────────────────┘
```

---

## 组件设计

### 1. 右侧天数栏（`DaySidebar`）

**变更**：
- 位置从左侧移至**右侧**
- 宽度 56px，每格高度 58px
- 每格显示三行：`DAY`（7px）、数字（18px 粗体）、星期（8px，如「周一」）
- 选中态：橙色背景 + 边框；未选中：灰色文字
- 底部保留「待规划」格
- **接口变更**：新增 `travelStartDate: DateTime` 参数，组件内部通过 `travelStartDate.add(Duration(days: day - 1)).weekday` 计算星期标签，无需父组件预计算

### 2. 时间轴内容区（`ScheduleListPanel` 主体）

**竖线**：`position:absolute`，左侧 27px，上下各留 14px 内边距，宽 2px，颜色 `AppColors.border`

**每个行程站点结构**：
```
[封面图 40×40] 时间文字(15px) [编辑图标 18×18] ··· [导航图标 26×26]
               地点名称（12px 加粗，单行截断）
               地址（10px 次色，单行截断）
               [截图缩略图 36×36] [截图] ... [+N]
```

### 3. 封面图（替代原圆点）

- 尺寸：40×40，圆角 10，置于竖线上（`z-index:1`）
- 外轮廓色：普通行程=橙色 `AppColors.primary`，住宿=紫色 `AppColors.hotel`，待规划=灰色 `#D4C8BF`
- 有 `cover` URL：显示网络图片
- 无 `cover`：按类型显示默认图标
  - 普通行程：📍，背景 `#FEE2C8`
  - 住宿：🏨，背景 `AppColors.hotelLight`
  - 待规划：📍，背景 `#EDE8E3`

### 4. 时间行

```
[时间文字 15px 加粗，颜色按类型] [编辑图标 18×18] flex:1 [导航图标 26×26]
```

- 普通行程：显示 `HH:mm`，颜色 `AppColors.primary`
- 住宿：显示「住宿」，颜色 `AppColors.hotel`
- 待规划：显示「待规划」，颜色 `AppColors.textSecondary`
- 整个时间行（文字 + 编辑图标）为可点击区域，触发快捷时间弹窗
- `canEdit == false` 时隐藏编辑图标

### 5. 截图缩略图

- 尺寸：36×36，圆角 6
- 最多显示 4 张，超出显示 `+N` 灰色格
- 点击任意缩略图：全屏查看器（`SchedulePhotoViewer`）

### 6. 全屏截图查看器（`SchedulePhotoViewer`）

- 黑底全屏，左右箭头切换（`PageView`）
- 顶部：关闭按钮 + 行程名 + 当前/总数（`1 / 5`）
- 底部：胶片缩略图条，当前页高亮白色边框
- 打开时定位至被点击的截图

---

## 导航功能（`ScheduleNavButton`）

### UI
- 26×26 圆角按钮，背景/边框按行程类型配色
- 待规划行程（坐标为 `0,0`）：半透明禁用

### 点击行为
弹出 BottomSheet，展示 5 种交通方式：

| 图标 | 标签 | mapMode | t 值 |
|------|------|---------|------|
| 🚗 | 驾车 | car | 0 |
| 🚕 | 打车 | taxi | 0 |
| 🚌 | 公交 | bus | 1 |
| 🚶 | 步行 | walk | 2 |
| 🚲 | 骑行 | ride | 3 |

### URL 规则（参考 `roadbook-vue/TrafficBtn.vue`）

coordinate 格式：`lon,lat`（经度在前）

```dart
// iOS
iosamap://path?sourceApplication=roadbook
  &dlat={lat}&dlon={lon}&dname={name}&dev=0&t={t}

// Android
amapuri://route/plan/
  ?dlat={lat}&dlon={lon}&dname={name}&dev=0&t={t}
```

使用 `url_launcher` 包的 `launchUrl()`，通过 `Platform.isIOS / isAndroid` 分发。

---

## 快捷时间弹窗（`ScheduleQuickTimeSheet`）

通过 `isHotel` 参数切换两种模式，组件复用同一 Widget。

### 普通行程模式

**结构**：
1. 标题栏：「修改出发时间」+ 行程名 + 关闭
2. **出行日**：横向滚动天格（Day1~N + 待规划），单选
3. **出发时间（可选）**：0–23 小时宫格（6列×4行），单选，再次点击可取消
4. 确认按钮（橙色渐变）→ PATCH 接口

**小时宫格样式**：
- 格子：高 32px，圆角 6，字号 12px
- 未选：`#F5F5F4` 背景，`AppColors.textSecondary` 文字
- 选中：`AppColors.primaryLight` 背景，`AppColors.primaryBorder` 边框，`AppColors.primary` 文字

### 住宿模式

**结构**：
1. 标题栏：「修改住宿时间」+ 酒店名 + 关闭
2. **住宿周期**：横向滚动天格，范围选择（入住日 → 退房日）
   - 状态提示文字随交互动态切换：
     - State 0（未选任何天）：「点击选择入住日」
     - State 1（已选入住、等待退房）：「点击选择退房日」
     - State 2（范围已选定）：隐藏提示，范围高亮保持
   - 交互逻辑与现有 `_onDayTap` 完全一致：首次点设入住，再次点设退房，早于入住时自动互换，第三次点重置
   - 中间天浅紫高亮（`AppColors.hotelLight`）
3. **入退房时间（可选）**：单一 0–23 小时宫格，范围选择
   - 交互逻辑与天格范围选择完全一致（参见「住宿小时范围状态机」）
   - 状态提示文字（位于标题行右侧）：
     - State 0（未选任何时）：「点击选择入住时间」
     - State 1（已选入住时、等待退房时）：「点击选择退房时间」
     - State 2（范围已选定）：隐藏提示
   - 选中端点：`AppColors.hotelLight` 背景 + `AppColors.hotel` 边框
   - 中间小时段：`AppColors.hotelLight` 浅色背景
4. **选择回显条**：「Day2 入住 12:00 → Day4 退房 15:00 · 2晚」
5. 确认按钮（紫色渐变）→ PATCH 接口

---

## 数据提交逻辑

### 乐观更新
1. 用户点击「确认修改」，弹窗立即关闭（`Navigator.of(context).pop()`）
2. 调用 `scheduleProvider.notifier` 方法前，先将**当前 `Schedule` 对象快照**保存到局部变量
3. 乐观更新：用新的 `startTime`/`endTime` 替换 provider 中对应条目
4. 后台发送 `PATCH /api/travels/:tId/schedules/:id`，body 使用完整 `ScheduleFormData`（从完整 `Schedule` 对象构建，仅 `startTime`/`endTime` 替换为新值）
5. 成功：无需额外操作
6. 失败：用步骤 2 的快照**恢复** provider 状态，`ScaffoldMessenger` 显示 SnackBar 错误提示

### 权限控制
- `canEdit`（`RoleType.manage` 或 `RoleType.edit`）：显示编辑图标、导航图标
- `view` 权限：隐藏编辑图标，保留导航图标（导航是只读操作）

---

## 新增组件清单

| 组件 | 文件路径 | 说明 |
|------|---------|------|
| `ScheduleTimelineItem` | `schedule/presentation/widgets/schedule_timeline_item.dart` | 替换 `ScheduleItem`，时间轴风格 |
| `ScheduleNavButton` | `schedule/presentation/widgets/schedule_nav_button.dart` | 导航图标 + 交通方式 BottomSheet |
| `ScheduleQuickTimeSheet` | `schedule/presentation/schedule_quick_time_sheet.dart` | 快捷时间弹窗（普通 + 住宿） |
| `SchedulePhotoViewer` | `schedule/presentation/schedule_photo_viewer.dart` | 全屏截图查看器 |

**修改组件**：
- `ScheduleListPanel`：移除左侧侧边栏，改为右侧；使用 `ScheduleTimelineItem`
- `DaySidebar`：增加星期信息，移至右侧（由父组件调整布局）

---

## 依赖

- `url_launcher`：**需要新增**到 `pubspec.yaml`（当前 pubspec 中不存在）
- iOS `Info.plist` 需新增 `LSApplicationQueriesSchemes`：`iosamap`、`amapuri`，否则 `canLaunchUrl` 在 iOS 9+ 上返回 false
- `dart:io`：直接使用 `Platform.isIOS` / `Platform.isAndroid` 判断平台（`platform_util.dart` 仅提供模拟器检测，与导航无关）

---

## 待解决的边界情况

### 住宿小时范围状态机（精确定义）

小时宫格使用与天格相同的**三态循环**：

```
State 0 → 用户点击 h1 → State 1（checkInHour=h1, checkOutHour=null，提示「选择退房时间」）
State 1 → 用户点击 h2 →
    if h2 >= h1: State 2（checkOutHour=h2，h1~h2 范围高亮）
    if h2 < h1:  State 2（checkInHour=h2, checkOutHour=h1，自动互换）
State 2 → 用户再次点击任意格 → 回到 State 0（全部清空，重新开始）
```

注意：与现有 `_onDayTap` 的区别是 State 2 后第三次点击**清空**（而非立即进入新一轮选入住），目的是让用户有机会看清当前范围后决定是否重置。

### `startTime`/`endTime` 构造规则

普通行程：
- 有选 day + 有选 hour → `DateTime(travelStart + day-1, hour, 0, 0)`
- 有选 day，无选 hour → `DateTime(travelStart + day-1, 0, 0, 0)`（00:00，表示「当天但未定时间」）
- day == 0（待规划） → `startTime = null`

住宿：
- checkInDay + checkInHour → `DateTime(...day, checkInHour, 0, 0)`
- checkInDay，无 checkInHour → `DateTime(...day, 12, 0, 0)`（默认正午，与现有逻辑一致）
- checkOutDay 同上

### `coordinate` 校验

`ScheduleNavButton` 在以下情况禁用（半透明，不可点击）：
- `coordinate` 为空字符串
- `coordinate == "0,0"`
- `coordinate` 格式不合法（不含 `,` 或 split 后元素不足 2 个）

### 同日退房（0 晚）显示

回显条当 `checkOutDay == checkInDay` 时显示「· 当日退房」而非「· 0晚」。

### `canEdit` 与时间行点击区域

- `canEdit == true`：时间文字 + 编辑图标整体为点击区域，触发快捷弹窗
- `canEdit == false`：编辑图标隐藏，时间文字**不可点击**（纯展示）

### 列表架构：过滤式（确认保持现有方式）

`ScheduleListPanel` 保持现有**按天过滤**模式（`selectedDayProvider` 驱动），不改为全天连续滚动。右侧 `DaySidebar` 点击切换 `selectedDay`，列表重新过滤渲染。

### `SchedulePhotoViewer` 触发方式

`ScheduleTimelineItem` 内部直接调用 `showDialog(barrierColor: Colors.black)` 打开 `SchedulePhotoViewer`（全屏黑底），不使用 `showModalBottomSheet`（无法覆盖全屏）。不通过回调冒泡。图片加载中显示居中 `CircularProgressIndicator`；加载失败显示与 `_ScreenshotThumbnails` 一致的 `broken_image_outlined` 占位图标。

### 弹窗关闭时机

`ScheduleQuickTimeSheet` 在乐观更新完成后立即调用 `Navigator.of(context).pop()`，与 `ScheduleEditSheet` 行为一致。

### 设计 Token 补充

以下颜色需添加至 `AppColors`：
```dart
static const Color unplanned      = Color(0xFFD4C8BF); // 待规划圆点边框
static const Color unplannedLight = Color(0xFFEDE8E3); // 待规划封面背景
```
