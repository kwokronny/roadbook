# Roadbook Flutter — 设计文档

**日期：** 2026-03-20
**版本：** v1.0
**对应后端：** packages/roadbook-api（现有 REST API，无需修改）

---

## 1. 项目定位

将 `roadbook-vue` 的核心功能以 Flutter 原生 App 形式重写，目标平台为 iOS 和 Android。功能与现有 Web 版对齐（装备清单功能留待后续迭代）。App 直接调用现有 roadbook-api，不新增后端接口。

---

## 2. 技术栈

| 类目 | 选型 |
|---|---|
| 框架 | Flutter（稳定渠道） |
| 平台 | iOS + Android |
| 状态管理 | Riverpod（`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`） |
| 路由 | GoRouter |
| 地图 | `amap_flutter_map`（高德地图 Flutter SDK） |
| HTTP 客户端 | `dio`（含拦截器处理 token / 401 重定向） |
| 本地持久化 | `shared_preferences`（token + 用户信息） |
| 图片上传 | `image_picker` + `flutter_image_compress` |
| 表单校验 | 自定义 validator，参考 async-validator 逻辑 |
| 时间处理 | `intl` |
| 密码哈希 | `crypto`（MD5，与 Vue 版一致） |

---

## 3. 项目结构

Feature-first 架构，每个功能模块自包含，共享代码放 `shared/`。

```
lib/
├── main.dart
├── app.dart                    # GoRouter 配置、全局 ProviderScope
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── auth_provider.dart
│   │   └── presentation/
│   │       ├── auth_screen.dart
│   │       ├── sign_in_screen.dart
│   │       └── sign_up_screen.dart
│   ├── travel/
│   │   ├── data/
│   │   │   └── travel_repository.dart
│   │   ├── domain/
│   │   │   ├── travel_provider.dart
│   │   │   └── travel_list_provider.dart
│   │   └── presentation/
│   │       ├── travel_list_screen.dart
│   │       ├── travel_detail_screen.dart
│   │       └── widgets/
│   │           ├── travel_card.dart
│   │           ├── travel_form_sheet.dart      # 新建/编辑旅程
│   │           └── collaborator_sheet.dart     # 协作者管理
│   ├── schedule/
│   │   ├── data/
│   │   │   └── schedule_repository.dart
│   │   ├── domain/
│   │   │   └── schedule_provider.dart
│   │   └── presentation/
│   │       ├── schedule_list_panel.dart        # 行程列表面板（含左侧天数栏）
│   │       ├── schedule_edit_sheet.dart        # 编辑行程底部面板
│   │       └── widgets/
│   │           ├── schedule_item.dart
│   │           ├── day_sidebar.dart            # 左侧天数导航
│   │           └── collect_import_sheet.dart   # 批量导入/AI采集
│   └── map/
│       ├── domain/
│       │   └── map_provider.dart
│       └── presentation/
│           ├── map_panel.dart                  # 地图面板
│           └── widgets/
│               ├── amap_container.dart
│               └── poi_marker.dart
├── shared/
│   ├── api/
│   │   ├── dio_client.dart                     # Dio 实例 + 拦截器
│   │   └── api_endpoints.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── travel.dart
│   │   ├── schedule.dart
│   │   └── user_travel.dart
│   ├── providers/
│   │   └── auth_state_provider.dart            # token、userInfo 全局状态
│   └── widgets/
│       ├── loading_button.dart
│       ├── limit_date_picker.dart
│       └── avatar_row.dart
└── core/
    ├── router.dart
    ├── theme.dart
    └── constants.dart
```

---

## 4. 路由设计

使用 GoRouter，守卫逻辑通过 `redirect` 实现。

```
/signin               — 登录（无需 token）
/signup               — 注册（无需 token）
/accept               — 接受邀请（无需 token，带 inviteToken query param）
/travel               — 旅程列表（需要 token）
/travel/:id           — 旅程详情（需要 token）
```

**守卫规则（GoRouter `redirect` 实现）：**
- 无 token 且目标路由非公开（非 `/signin`、`/signup`、`/accept`）→ 返回 `/signin`
- 有 token 且目标为 `/signin` 或 `/signup` → 返回 `/travel`
- 其他情况 → 返回 `null`（放行）
- `/accept?inviteToken=X`：有 token → 自动调用 accept API → 跳转 `/travel/:id`；无 token → 展示登录/注册引导页，`inviteToken` 保留在 query param 中透传

---

## 5. 页面设计

### 5.1 Auth（登录/注册）

- 登录：用户名 + 密码（MD5 哈希后提交）
- 注册：用户名 + 密码 + 确认密码
- 成功后写入 token 与 userInfo 到 Riverpod state + SharedPreferences
- 有 `inviteToken` query param 时，登录/注册成功后转入 accept 流程

### 5.2 旅程列表页

- 顶部搜索框（防抖 500ms）
- 分页加载，滚动到底部触发下一页（`ScrollController` 监听）
- 旅程卡片展示：名称、日期范围、状态徽章（待出发/旅行中/已结束）、协作者头像（最多3个）、天数
- 右上角用户头像：点击展开菜单（编辑资料、修改密码、退出登录）
- 右下角 FAB：打开新建旅程底部面板

### 5.3 旅程详情页

**布局：** 顶部 AppBar + 下方 Tab 切换（地图 / 行程）

**AppBar 操作（按权限显示）：**
- `manage` 权限：编辑旅程信息、协作者管理、批量导入
- `edit` 权限：批量导入
- 所有权限：查看

**地图 Tab：**
- 高德地图全屏展示
- 顶部搜索栏 + 城市下拉选择
- 已排行程：数字圆形标记（颜色按天区分），酒店显示「H」，待排显示「?」
- **切换天数 → 地图自动 fitBounds**：左侧天数栏切换时，地图 camera 动画飞到当天所有行程标记的边界范围内，确保当天行程全部可见
- **点击地图标记 → 直接打开编辑底部面板**：点击已排行程的标记，立即弹出该行程的编辑面板（`schedule_edit_sheet.dart`），与行程 Tab 中点击卡片行为一致
- **全览模式浮层按钮**：地图右上角悬浮小圆按钮切换全览/当天模式；全览模式下所有天标记同时可见，当天模式下仅高亮当天标记、其余天半透明
- 搜索结果：「+」标记；**点击立即加入待规划**，自动填充 POI 数据（名称、地址、坐标、isHotel、封面、dianpingUUID），标记样式切换为「?」，同时显示 Toast「已加入待规划」，不打断用户继续搜索
- isHotel 判断：`poi.type.contains("住宿服务")` 为 true（高德 POI 分类的精确字符串，避免误判）

**行程 Tab：**
- 左侧固定天数数字竖栏（含「?」待排项）；当前选中天高亮
- 右侧当前天的行程列表，按 startTime 排序
- 酒店跨天处理：跨天酒店在每个覆盖的天中都显示
- 每个行程卡片：时间、名称、地址、Dianping 按钮（有 dianpingUUID 时显示）；**无交通方式显示**
- 长按或更多菜单：编辑、克隆、删除
- 点击行程卡片 → 打开**编辑底部面板**

**编辑行程底部面板（`schedule_edit_sheet.dart`）：**

普通地点字段：
- 名称（文本输入）
- 备注（文本输入，可选）
- **天选择**：日历宫格（3列），每格显示「第N天 + 星期几」；末尾加「待规划」格；单选，选中格橙棕色高亮
- **时间选择**（可选）：24格小时宫格（6列），点击选择出发小时；可不选（待排）
- 截图上传（多张，点击可删除）

酒店字段（isHotel = true 时）：
- 名称（文本输入）
- 备注（文本输入，可选）
- **入住/退房天**：同一日历宫格，第一次点击选入住天，第二次点击选退房天；两端橙棕高亮，中间天浅橙填充，角落显示「入住」/「退房」标签；自动计算晚数
- 截图上传（多张，点击可删除）
- **无时间选择、无交通方式选择**

天 → startTime/endTime 转换规则：
- 普通地点：`startTime = travelStart + (day-1) days + selectedHour`；无时间时存 null
- 酒店：`startTime = travelStart + (checkInDay-1) days + "12:00:00"`，`endTime = travelStart + (checkOutDay-1) days + "12:00:00"`
- 待规划：startTime = null

保存调用 `schedule/update` 或 `schedule/add`（从待规划转正式时填充天和时间）

### 5.4 协作者管理页（底部面板）

- 展示邀请链接 + 复制按钮
- 协作者列表：头像、用户名、角色下拉（manage/edit/view）、移除
- 本人（owner）不可修改自己角色

### 5.5 批量导入面板（`collect_import_sheet.dart`）

- 两种模式：**AI 采集**（粘贴 JSON 数组）和**点评收藏**（粘贴点评 JSON）
- 流程：客户端解析 JSON → 根据模式转换数据格式 → 逐条循环调用 `POST /api/travel/schedule/add` → 每条显示成功/失败状态
  - AI 模式：JSON 为行程数组，直接映射字段
  - 点评模式：提取 `records[0].collectItemList`，通过 `dianpingDataTransform()` 转换为行程格式
- 界面展示逐步进度（类似 checklist 动画），每条独立展示结果
- 注意：`/api/travel/schedule/pull_collect` 为遗留接口（接受 URL 参数），**不用于批量导入**

---

## 6. 数据模型

```dart
class Travel {
  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  // API 返回逗号分隔字符串，模型层拆分为 List
  // e.g. "北京,上海" -> ["北京", "上海"]
  final List<String> cities;
  final List<UserWithRole> collaborators;
  final List<Schedule> schedules;
  final String? equip; // 暂不使用，保留字段
}

class Schedule {
  final int? id;
  final int tId;
  final String name;
  final String coordinate;   // "lng,lat"
  final String address;
  final String? cover;
  final String? dianpingUUID;
  final bool isHotel;
  final DateTime? startTime;
  final DateTime? endTime;
  // traffic 字段由后端保留但 Flutter 端不展示也不编辑
  // API 返回逗号分隔字符串，e.g. "url1,url2"
  // 序列化：List<String> -> join(',')；反序列化：split(',').where(isNotEmpty)
  final String? screenshots;
  List<String> get screenshotList =>
      screenshots?.split(',').where((s) => s.isNotEmpty).toList() ?? [];
  final String? notes;
}

class UserWithRole {
  final User user;
  final RoleType role; // manage | edit | view
}

enum RoleType { manage, edit, view }
// TrafficType 不在 Flutter 端使用，保留注释供将来参考
// enum TrafficType { car, taxi, ride, walk, bus }
```

---

## 7. 状态管理设计

使用 Riverpod code generation（`@riverpod`）。

**全局状态（`shared/providers/`）：**
- `authStateProvider`：token + userInfo，持久化到 SharedPreferences

**Feature 级状态：**
- `travelListProvider`：分页旅程列表 + 搜索关键词
- `travelDetailProvider(id)`：单个旅程详情（含协作者）
- `schedulesProvider(travelId)`：行程列表（从 detail 派生）
- `selectedDayProvider(travelId)`：当前选中天
- `mapSearchResultsProvider`：地图搜索 POI 结果
- `currentTabProvider`：地图/行程当前 Tab

**Repository 模式：** Provider 只依赖 Repository，Repository 封装所有 Dio 调用，方便单独测试。

---

## 8. 网络层设计

**Dio 拦截器：**
- Request：默认注入 `Authorization: Bearer {token}`；特殊请求（如 `accept` 邀请接口）可通过 `options.extra['skipAuth'] = true` 跳过注入——无论用户是否已登录，拦截器均跳过 token 注入，适配"未登录也能调用"与"已登录但不希望携带 token"两种场景
- Response：统一解包 `{ code, data, message }` 结构
- 401 → 清空 token → GoRouter 重定向 `/signin`
- 其他错误 → 抛出带 message 的异常，UI 层通过 `AsyncValue.error` 显示

**API Endpoints（对应现有 roadbook-api）：**

| 功能 | 方法 | 路径 |
|---|---|---|
| 登录 | POST | /api/user/login |
| 注册 | POST | /api/user/register |
| 获取用户信息 | POST | /api/user/detail |
| 修改用户信息 | POST | /api/user/update |
| 修改密码 | POST | /api/user/password/modify |
| 旅程列表 | POST | /api/travel/page |
| 旅程详情 | POST | /api/travel/detail |
| 新建/更新旅程 | POST | /api/travel/save |
| 删除旅程 | POST | /api/travel/remove |
| 邀请链接 | POST | /api/travel/invite |
| 接受邀请 | POST | /api/travel/accept |
| 设置协作者角色 | POST | /api/travel/set_role |
| 行程列表 | POST | /api/travel/schedule/list |
| 新增行程 | POST | /api/travel/schedule/add |
| 更新行程 | POST | /api/travel/schedule/update |
| 删除行程 | POST | /api/travel/schedule/remove |
| 克隆行程 | POST | /api/travel/schedule/clone |
| 遗留接口（不用于批量导入） | POST | /api/travel/schedule/pull_collect |
| 上传文件 | POST | /upload |

---

## 9. 权限模型

`perm` 从 `travelDetailProvider` 计算，比较当前用户 id 与协作者列表：

| 权限 | 可操作 |
|---|---|
| `manage` | 编辑旅程信息、管理协作者、添加/编辑/删除行程、批量导入 |
| `edit` | 添加/编辑/删除行程、批量导入 |
| `view` | 只读 |

AppBar 操作按钮、行程卡片操作菜单均根据 `perm` 值决定是否显示。

---

## 10. 视觉设计规范

**风格定位：** 暖橙舒适风（Warm Comfort）— 参考 Headspace × Notion 暖色调。米白底色、暖橙主色渐变、圆润卡片、轻投影，整体传递温暖舒适的旅行情绪感。

**参考 App：** Headspace、Notion（暖色主题）

### 10.1 色彩体系

| Token | 色值 | 用途 |
|---|---|---|
| `colorBackground` | `#FDFAF6` | 页面背景（米白） |
| `colorSurface` | `#FFFFFF` | 卡片/面板/底部面板背景 |
| `colorBorder` | `#F0EBE3` | 分割线、边框 |
| `colorPrimary` | `#F97316` | 主色调（按钮、选中态、高亮） |
| `colorPrimaryGradient` | `#F97316 → #FBBF24` | 渐变色（FAB、保存按钮、旅行中横幅） |
| `colorPrimaryLight` | `#FFF7ED` | 主色浅背景（待出发徽章底色、宫格选中填充） |
| `colorPrimaryBorder` | `#FED7AA` | 主色浅边框（徽章边框、宫格选中边框） |
| `colorHotel` | `#8B5CF6` | 住宿色（紫色） |
| `colorHotelLight` | `#F5F3FF` | 住宿浅背景 |
| `colorHotelBorder` | `#DDD6FE` | 住宿浅边框 |
| `colorSuccess` | `#16A34A` | 旅行中状态 |
| `colorSuccessLight` | `#F0FDF4` | 旅行中浅背景 |
| `colorNeutral` | `#A8A29E` | 已结束状态、辅助文字 |
| `colorTextPrimary` | `#1C1917` | 主文字 |
| `colorTextSecondary` | `#A8A29E` | 辅助文字、标签、占位符 |
| `colorTextDisabled` | `#C4B8B0` | 禁用态文字 |

### 10.2 行程卡片视觉规范

- **封面图**：顶部全宽展示，高度 `90–120dp`，`object-fit: cover`
- **无封面图 fallback**：高度 `72dp` 的彩色色块 + 居中 emoji 图标，色块背景色取对应类型的浅色（`colorPrimaryLight` / `colorHotelLight`）
- **左侧色条**：宽 `3dp`，普通行程用 `colorPrimary`，住宿用 `colorHotel`
- **时间/住宿天数角标**：叠在封面图左上角，`background: rgba(0,0,0,0.38)`，白色文字，`blur(4dp)`
- **截图缩略图**：有截图时在卡片底部展示，尺寸 `42×42dp`，`8dp` 圆角，最多展示 4 张
- **导航按钮**：卡片底部全宽，点击唤起系统导航选择器（高德/百度/Apple Maps）

### 10.3 字体规范

- **中文**：系统字体（iOS: PingFang SC，Android: Noto Sans SC）
- **数字 / 英文**：DM Sans（Google Fonts）
- **字号层级**：
  - 页面大标题：20sp ExtraBold（旅程列表顶部）
  - 页面标题：17sp Bold（AppBar）
  - 卡片主标题：14sp SemiBold
  - 正文：12sp Regular
  - 辅助说明：11sp Regular
  - 微标签：10sp Medium

### 10.4 圆角与间距

- 卡片圆角：`14dp`
- 底部面板圆角：`24dp`（顶部两角）
- 输入框/宫格圆角：`8dp`
- 时间宫格圆角：`6dp`
- 状态徽章圆角：`20dp`（胶囊形）
- 页面水平内边距：`16dp`
- 卡片内边距：`14dp`
- 卡片间距：`10dp`

### 10.5 投影

- 普通行程卡：`BoxShadow(color: #F9731614, blurRadius: 8, offset: Offset(0, 2))`
- 住宿卡：`BoxShadow(color: #8B5CF614, blurRadius: 8, offset: Offset(0, 2))`
- 旅程列表卡：`BoxShadow(color: #1C191708, blurRadius: 12, offset: Offset(0, 2))`

### 10.6 主题切换

仅支持亮色模式（暗色模式留待后续迭代）。高德地图使用亮色样式：`amap://styles/fresh`

### 10.7 状态徽章

| 状态 | 背景色 | 文字色 | 边框色 | 文案 |
|---|---|---|---|---|
| 待出发 | `#FFF7ED` | `#F97316` | `#FED7AA` | 待出发 |
| 旅行中 | `#F0FDF4` | `#16A34A` | `#A7F3D0` | 旅行中 |
| 已结束 | `#F5F5F4` | `#A8A29E` | transparent | 已结束 |
| 住宿标签 | `#F5F3FF` | `#8B5CF6` | `#DDD6FE` | 住宿 |

### 10.8 旅程列表页特殊组件

- **进行中横幅**：渐变背景 `#F97316 → #FB923C`，白色文字，`14dp` 圆角，展示在列表顶部
- **用户头像**：渐变背景 `#F97316 → #FBBF24`，`12dp` 圆角方块
- **FAB**：渐变背景 `#F97316 → #FBBF24`，`14dp` 圆角，白色 `＋`

---

## 11. 不在本次范围内

- 装备清单（后续迭代）
- 推送通知
- 离线缓存
- Flutter Web / Desktop
