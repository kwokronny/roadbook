# 发现页 & 我的页 — 设计规范

**日期**: 2026-03-28
**状态**: 已确认，待实现

---

## 1. 范围

本文档覆盖以下 4 个屏幕的完整设计：

| 屏幕 | 路由 | 类型 |
|------|------|------|
| 发现页 (DiscoverScreen) | `/discover` | Tab 根页面 |
| 我的页 (ProfileScreen) | `/profile` | Tab 根页面 |
| 编辑资料 (EditProfileScreen) | `/profile/edit` | Push |
| 设置 (SettingsScreen) | `/profile/settings` | Push |

消息中心 (MessagesScreen) 推迟到后续版本（需要实时通知支持）。

---

## 2. 设计原则

沿用全局设计规范（`2026-03-27-app-ui-ux-design.md`）：

- 背景 `#F2F2F7`，卡片白底 `#FFFFFF`
- iOS Large Title 风格导航
- 白色内容卡片圆角 12px
- 菜单行高 44px，分隔线 `rgba(60,60,67,0.1) 0.5px`
- 品牌色 `#FF5B2E`，破坏性操作 `#FF3B30`

---

## 3. 后端新增接口

### 3.1 `POST /api/travel/discover`

列出所有公开旅程（无需登录）。

**请求体：**
```json
{
  "page": 1,
  "size": 20,
  "city": "东京",
  "keyword": "深度游"
}
```
- `city` 可选，为空时返回全部公开旅程
- `keyword` 可选，对 `name` 做 LIKE 模糊匹配
- `city` 和 `keyword` 不同时使用（keyword 优先）
- 按 `updatedAt` 降序

**响应体：**
```json
{
  "code": 200,
  "data": {
    "total": 100,
    "list": [
      {
        "id": 1,
        "name": "东京7日深度游",
        "city": "东京,大阪,京都",
        "startDate": "2026-04-01",
        "endDate": "2026-04-07",
        "viewCount": 1200,
        "owner": {
          "id": 5,
          "username": "xiaoli",
          "nickname": "旅行达人小李",
          "avatar": "https://..."
        }
      }
    ]
  }
}
```

**后端实现要点：**
- 查询 `Travel` 表中 `public = true` 的记录
- JOIN `UserTravel`（role = 'manage'）获取 owner 信息
- `viewCount` 字段新增到 Travel 模型（INTEGER，默认 0）；每次 detail 接口被匿名用户访问时 +1
- 路由无需 JWT（与 `/api/travel/detail` 同级的白名单）

### 3.2 `POST /api/user/update`

更新当前用户的昵称。

**请求体：**
```json
{ "nickname": "新昵称" }
```

**响应体：**
```json
{ "code": 200, "data": { "id": 1, "username": "xiaowang", "nickname": "新昵称", "avatar": "..." } }
```

**后端实现要点：**
- 需要 JWT（当前用户）
- 只允许修改 `nickname`，`username` 不可改
- 若 User 模型缺少 `nickname`、`avatar` 字段，本 task 一并迁移新增

### 3.3 `POST /api/user/avatar`

上传头像（复用现有截图上传逻辑）。

**请求**：multipart/form-data，字段名 `file`（图片，最大 5MB）

**响应体：**
```json
{ "code": 200, "data": { "avatar": "https://..." } }
```

**后端实现要点：**
- 复用现有 `schedule/upload` 的文件处理逻辑
- 返回图片 URL，前端存入 User 记录

---

## 4. 发现页 (DiscoverScreen)

### 4.1 布局结构

```
SafeArea
├── Large Title「发现」(34px/800)
├── 搜索栏 (iOS 风格胶囊，rgba(118,118,128,0.12))
│   └── 占位文字「搜索旅程、目的地」
├── 目的地 Chip 横向滚动列表
│   └── Chip: 热门(默认选中) / 日本 / 泰国 / 韩国 / 欧洲 / 东南亚 / 国内
└── 公开旅程列表 (ListView，下拉刷新，滚动加载更多)
    └── PublicTravelCard × N
```

### 4.2 PublicTravelCard

```
Card (白底，圆角12px，margin水平16px，垂直4px)
├── 封面色块 (60px高，渐变色按旅程状态色规则分配)
└── 内容区 (padding 10px)
    ├── 旅程名称 (14px/700/textPrimary)
    ├── 目的地 + 天数 (11px/textSecondary)，如「东京 · 大阪 · 7天」
    └── 底部行
        ├── 作者头像 (16px圆形) + 作者昵称 (11px/textSecondary)
        └── 右侧浏览数 (11px/textTertiary)，如「👁 1.2k」
```

封面渐变色分配规则（无需旅程状态，固定按 id % 4 轮转）：
- 0: `#FF5B2E → #FF8C42`
- 1: `#6366F1 → #4F46E5`
- 2: `#14B8A6 → #0D9488`
- 3: `#F59E0B → #D97706`

### 4.3 目的地 Chip

- 激活态：背景 `#FF5B2E`，文字白色
- 非激活态：背景 `#E5E5EA`，文字 `#8E8E93`
- 选中 Chip 时刷新列表（city 参数）
- 「热门」Chip 不传 city，返回全部公开旅程

### 4.4 搜索行为

- 搜索栏输入后实时过滤（debounce 500ms）
- 搜索时忽略 Chip 选择，直接用关键词请求 `/api/travel/discover`（后端 name LIKE）
- 清空搜索时恢复 Chip 筛选状态

### 4.5 空状态

居中展示：旅行插画占位（用 Icon 代替）+ 「暂无公开旅程」

### 4.6 状态管理

```dart
// discover_provider.dart
@riverpod
class DiscoverNotifier extends _$DiscoverNotifier {
  // state: AsyncValue<DiscoverState>
  // DiscoverState { List<PublicTravel> travels, String selectedCity, String keyword, bool hasMore, int page }
  Future<void> load({ bool refresh = false }) ...
  Future<void> selectCity(String city) ...
  Future<void> search(String keyword) ...
  Future<void> loadMore() ...
}
```

---

## 5. 我的页 (ProfileScreen)

### 5.1 布局结构

```
SafeArea
├── Large Title「我的」
├── 用户信息卡 (白底，圆角12px，margin水平16px)
│   ├── 头像 (50px圆形，渐变色占位或真实图片)
│   ├── 昵称 (17px/700)
│   ├── 统计行：旅程数 / 城市数 / 天数
│   └── 右侧箭头 › (点击跳转编辑资料)
├── 菜单分组一 (白底，圆角12px)
│   ├── 消息中心 (红点badge，占位不可点击，标注「即将推出」)
│   ├── 编辑资料 → push EditProfileScreen
│   └── 设置 → push SettingsScreen
└── 菜单分组二 (白底，圆角12px)
    └── 退出登录 (居中，#FF3B30，点击弹确认 AlertDialog)
```

### 5.2 统计数据来源

- 旅程数：`ref.watch(travelListProvider).valueOrNull?.length ?? 0`
- 城市数：所有旅程的 `cities` 列表去重后的数量
- 天数：所有旅程的 `(endDate - startDate).inDays + 1` 求和

统计读取现有 `travelListProvider`，无需新接口。

### 5.3 菜单图标

| 菜单项 | 图标背景色 | 图标 |
|--------|-----------|------|
| 消息中心 | `#FF5B2E` | Icons.mail_outline |
| 编辑资料 | `#34C759` | Icons.edit_outlined |
| 设置 | `#8E8E93` | Icons.settings_outlined |

图标背景为 6px 圆角正方形（22×22），图标白色 14px。

### 5.4 退出登录

点击「退出登录」弹出 AlertDialog 确认：
- 标题：「确认退出」
- 内容：「退出后需重新登录」
- 操作：取消 / 退出（#FF3B30）
- 确认后清空 token，跳转 `/signin`

---

## 6. 编辑资料 (EditProfileScreen)

### 6.1 布局结构

```
Scaffold (背景 #F2F2F7)
├── AppBar「编辑资料」+ 右侧「保存」按钮 (#FF5B2E)
├── 头像区 (居中)
│   ├── 圆形头像 (70px，可点击)
│   ├── 右下角相机图标 badge (黑色圆，18px)
│   └── 「更换头像」文字 (11px, #FF5B2E)
└── 表单组 (白底，圆角12px)
    ├── 用户名行 (只读，灰色文字)
    ├── 昵称行 (可编辑 TextField)
    └── 密码行 (「修改密码 ›」→ 暂为 SnackBar 提示「即将推出」)
```

### 6.2 头像更换

点击头像 → `ImagePicker.pickImage(source: ImageSource.gallery)`
→ 上传到 `/api/user/avatar`
→ 更新本地 User 状态

### 6.3 保存逻辑

- 昵称变更时才启用「保存」按钮（否则灰色不可点）
- 点击「保存」→ POST `/api/user/update` → 更新全局 authStateProvider 中的 user 信息 → pop

### 6.4 状态管理

使用本地 `ConsumerStatefulWidget` 管理表单状态，无需独立 Provider。保存成功后通过 `ref.invalidate(authStateProvider)` 刷新用户信息。

---

## 7. 设置页 (SettingsScreen)

### 7.1 布局结构

```
Scaffold (背景 #F2F2F7)
├── AppBar「设置」
├── Section「通用」
│   ├── 深色模式 (开关，暂时只存本地 SharedPreferences，不实际切换主题)
│   └── 语言 (只读，显示「简体中文」，不可修改)
├── Section「存储」
│   └── 清除缓存 (显示缓存大小，点击清除后 SnackBar 提示)
└── Section「关于」
    ├── 版本号 (读取 package_info_plus)
    └── 意见反馈 (跳转到 GitHub Issues 或邮件，用 url_launcher)
```

### 7.2 深色模式

- 当前阶段仅保存开关状态到 `SharedPreferences`（key: `dark_mode`）
- 实际主题切换留在后续迭代（需要 ThemeMode Provider）
- 开关 UI 用 Flutter Switch，激活色 `#34C759`

### 7.3 缓存计算

遍历 `getTemporaryDirectory()` 计算目录大小，格式化为「X.X MB」。清除调用 `deleteSync(recursive: true)` 后重新计算。

### 7.4 依赖

- `package_info_plus: ^8.0.0` — 读取版本号（需新增到 pubspec.yaml）
- `shared_preferences` — 已有（^2.3.1）
- `url_launcher` — 已有

---

## 8. 数据模型扩展

### 8.1 PublicTravel（前端新增模型）

```dart
class PublicTravel {
  final int id;
  final String name;
  final List<String> cities;
  final DateTime startDate;
  final DateTime endDate;
  final int viewCount;
  final PublicTravelOwner owner;
}

class PublicTravelOwner {
  final int id;
  final String username;
  final String nickname;
  final String? avatar;
}
```

### 8.2 User 模型扩展（后端 + 前端）

User 模型新增字段：
- `nickname` (STRING，默认等于 username)
- `avatar` (STRING，可为 null)

前端 User 类同步增加 `nickname`、`avatar` 字段。

---

## 9. 路由扩展

在 `lib/core/router.dart` 的 `/profile` branch 下新增：

```dart
GoRoute(path: 'edit',   builder: (_, __) => const EditProfileScreen()),
GoRoute(path: 'settings', builder: (_, __) => const SettingsScreen()),
```

---

## 10. 文件清单

| 操作 | 路径 |
|------|------|
| 修改 | `packages/roadbook-api/models/user.js` — 新增 nickname/avatar 字段 |
| 新增迁移 | `packages/roadbook-api/migrations/YYYYMMDD-add-user-profile.js` |
| 修改 | `packages/roadbook-api/models/travel.js` — 新增 viewCount 字段 |
| 新增迁移 | `packages/roadbook-api/migrations/YYYYMMDD-add-travel-viewcount.js` |
| 修改 | `packages/roadbook-api/service/travel.js` — discover 逻辑 |
| 修改 | `packages/roadbook-api/service/user.js` — update/avatar 逻辑 |
| 修改 | `packages/roadbook-api/controller/travel.js` — discover 路由处理 |
| 修改 | `packages/roadbook-api/controller/user.js` — update/avatar 路由处理 |
| 修改 | `packages/roadbook-api/router/index.js` — 新增路由 |
| 新增 | `packages/roadbook-flutter/lib/shared/models/public_travel.dart` |
| 修改 | `packages/roadbook-flutter/lib/shared/models/user.dart` — nickname/avatar |
| 新增 | `packages/roadbook-flutter/lib/features/discover/data/discover_repository.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/discover/domain/discover_provider.dart` |
| 修改 | `packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/discover/presentation/widgets/public_travel_card.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/data/profile_repository.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/domain/profile_provider.dart` |
| 修改 | `packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/presentation/edit_profile_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/presentation/settings_screen.dart` |
| 修改 | `packages/roadbook-flutter/lib/core/router.dart` — 新增子路由 |
| 修改 | `packages/roadbook-flutter/pubspec.yaml` — 新增 package_info_plus |
