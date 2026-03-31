# 小肥路书 Flutter APP — UI/UX 设计规范

**日期**: 2026-03-27
**状态**: 已确认，待实现

---

## 1. 设计方向

**全面重新设计**，参考 Klook + iOS 设计语言，保留活泼气质但整体沉稳。

### 核心原则

- 背景固定为 iOS 系统灰 `#F2F2F7`，登录/注册页用纯白
- 渐变色**只用于旅程状态卡片和主操作按钮**，其他区域克制
- iOS Large Title 导航风格（大标题 + 毛玻璃底栏）
- Klook 卡片风格：白底圆角卡片，带封面色块的发现页列表
- 全部使用 SVG 线性图标，不使用 emoji 作为 UI 图标

---

## 2. 设计系统

### 颜色

| Token | 色值 | 用途 |
|-------|------|------|
| `primary` | `#FF5B2E` | 品牌色、FAB、导航激活、主按钮 |
| `primaryLight` | `#FF8C42` | 渐变搭配色 |
| `background` | `#F2F2F7` | 全局背景（iOS 系统灰） |
| `surface` | `#FFFFFF` | 卡片、Sheet、登录页 |
| `textPrimary` | `#1C1C1E` | 主文字 |
| `textSecondary` | `#8E8E93` | 辅助文字、placeholder |
| `textTertiary` | `#C7C7CC` | 分隔线颜色、禁用 |
| `separator` | `rgba(60,60,67,0.1)` | iOS 细分隔线（0.5px） |
| `destructive` | `#FF3B30` | 删除、退出登录 |
| `hotel` | `#8B5CF6` | 住宿标记（沿用现有） |

### 旅程状态色（仅用于旅程卡片）

| 状态 | 条件 | 渐变起点 | 渐变终点 |
|------|------|---------|---------|
| 旅行中 | startDate ≤ 今天 ≤ endDate | `#FF5B2E` | `#FF8C42` |
| 即将出发 | 今天 < startDate ≤ 7天内 | `#F59E0B` | `#D97706` |
| 规划中 | startDate > 7天后 | `#6366F1` | `#4F46E5` |
| 已结束 | endDate < 今天 | `#14B8A6` | `#0D9488` |

### 字体

- **中文**: PingFang SC（系统字体，保留现有）
- **字号规范（设备实际尺寸）**:
  - Large Title: 34px / weight 800（iOS 大标题）
  - Title: 20px / weight 700
  - Body: 17px / weight 400
  - Subheadline: 15px / weight 400
  - Caption: 13px / weight 400
  - Micro: 11px / weight 400

### 圆角

| 元素 | 圆角 |
|------|------|
| 旅程状态卡片 | 14px |
| 白色内容卡片（发现页、菜单组） | 12px |
| 输入框 | 10px |
| 小标签/Badge | 6px |
| FAB | 50%（正圆） |
| 头像 | 50% |
| 菜单图标背景 | 6px |

### 间距

| 用途 | 值 |
|------|-----|
| 页面水平边距 | 16px |
| 卡片间距 | 8px |
| 卡片内边距 | 12px |
| 菜单行高 | 44px（符合 iOS 触摸目标） |

---

## 3. 导航结构

### 底部导航栏（3 Tab）

```
旅程（填充图标）· 发现（罗盘图标）· 我的（用户图标）
```

- 激活态：`#FF5B2E` 填充图标 + 加粗标签
- 非激活态：`#8E8E93` 线框图标
- 背景：`rgba(249,249,249,0.94)` + `backdrop-filter: blur(20px)`
- 边框：`0.5px solid rgba(0,0,0,0.1)`

### 页面层级

```
底部导航
├── Tab 1: 旅程列表 (TravelListScreen)
│   ├── Sheet: 新建/编辑旅程 (TravelFormSheet) — 保留现有
│   └── → 旅程详情 (TravelDetailScreen) — push
│       ├── Tab: 行程时间线 (ScheduleListPanel) — 保留现有交互
│       ├── Tab: 地图视图 (MapTabView) — 保留现有交互
│       ├── Sheet: 行程编辑 (ScheduleEditSheet) — 保留现有
│       ├── Sheet: 快速时间 (ScheduleQuickTimeSheet) — 保留现有
│       ├── Sheet: 批量导入 (CollectImportSheet) — 保留现有
│       ├── Sheet: 协作者管理 (CollaboratorSheet) — 保留现有
│       └── → 行李清单 (LuggageScreen) — push（新增）
├── Tab 2: 发现 (DiscoverScreen) — 新增
│   └── → 公开旅程详情（只读）— push
└── Tab 3: 我的 (ProfileScreen) — 新增
    ├── → 消息中心 (MessagesScreen) — push（新增）
    ├── → 编辑资料 (EditProfileScreen) — push（新增）
    ├── → 设置 (SettingsScreen) — push（新增）
    └── 退出登录

独立路由:
└── /share/:id — 旅程分享页（公开，无需登录）（新增）
```

---

## 4. 各页面设计规范

### 4.1 旅程列表页（重新设计）

**结构**:
1. 状态栏
2. Large Title「我的旅程」+ 右侧用户头像（点击展开菜单：编辑资料 / 退出登录）
3. iOS 风格搜索栏（`rgba(118,118,128,0.12)` 胶囊形）
4. 旅程状态卡片列表（按 startDate 升序排列）
5. FAB（正圆，`#FF5B2E`，右下角）

**旅程卡片内容**:
- 渐变背景（按状态色）
- 左侧图标（40×40 白色半透明方形，内含 SVG 图标）
- 旅程名称（14px / 700 / white）
- 城市列表（11px / white 75%透明）
- 底部：日期范围 + 状态 badge
- 协作者头像叠放（20px 圆形，白色半透明，仅旅行中显示）

**空状态**: 居中图标 + 文字「暂无旅程，点击 + 开始规划」

### 4.2 旅程详情页（保留现有交互，仅调色）

- AppBar 背景改为 `#F2F2F7`
- 行程/地图 Tab 切换按钮沿用现有 toggle 样式，激活色改为 `#FF5B2E`
- FAB 改为正圆，颜色 `#FF5B2E`
- 更多菜单新增「行李清单」入口

### 4.3 发现页（新增）

**结构**:
1. Large Title「发现」
2. iOS 搜索栏
3. 目的地标签横向滚动（热门/日本/泰国/韩国等，激活态 `#FF5B2E`）
4. 公开旅程列表（白底卡片）

**发现卡片内容**:
- 封面色块（60px 高，渐变色，用旅程状态色或随机分配）
- 旅程名称（14px / 700）
- 目的地 + 天数（11px / `#8E8E93`）
- 作者头像（14px 圆形）+ 作者名 + 浏览数

### 4.4 我的页（新增）

**结构**:
1. Large Title「我的」
2. 用户信息卡（白底圆角，头像 + 姓名 + 统计：旅程数/城市数/天数）
3. 菜单分组一（白底圆角，iOS grouped style）：消息中心（红点）/ 编辑资料 / 设置
4. 菜单分组二：退出登录（`#FF3B30`，居中）

### 4.5 消息中心（新增）

**结构**:
1. 标准 AppBar「消息」+ 返回按钮
2. Tab 过滤：全部 / 协作 / 系统
3. 消息列表

**消息类型**:
- 协作邀请：头像 + 「XXX 邀请你加入「旅程名」」+ 接受/拒绝按钮
- 行程变更：头像 + 「XXX 修改了「旅程名」的第N天行程」
- 系统通知：系统图标 + 通知内容
- 未读消息：左侧 `#FF3B30` 3px 竖条标记

### 4.6 编辑资料（新增）

**结构**:
1. AppBar「编辑资料」+ 右侧「保存」按钮（`#FF5B2E`）
2. 头像（可点击更换，右下角相机图标）
3. 表单字段（iOS 风格，`#F2F2F7` 背景输入框）：用户名 / 昵称 / 密码（箭头跳转修改）

### 4.7 行李清单（新增）

**归属**: 每个旅程独立，不共享模板。

**结构**:
1. AppBar「行李清单」+ 右侧「编辑」按钮（进入编辑模式）
2. 进度条（已准备 N/M 件 + 百分比，`#FF5B2E` 进度色）
3. 分类分组列表（可折叠，分类标题右侧显示本类 N/M 进度）
4. 每行：勾选框（已完成为 `#FF5B2E` 填充勾选，文字划线）+ 物品名；**勾选后原位保留，不移动**

**分类管理**:
- 预设默认分类：证件、电子产品、衣物、洗漱、药品、其他
- 用户可新增分类、重命名分类、删除空分类
- 进入编辑模式后，分类标题旁出现拖拽手柄，支持排序

**添加物品**:
- 每个分类右侧有「+」按钮，点击弹出「添加物品」底部面板
- 面板顶部为搜索框，下方展示常用旅行物品网格（分组展示）
- 搜索时实时过滤常用物品列表
- 搜索无结果时，显示「将「xxx」加入清单」按钮，点击直接添加
- 同一物品可点击多次（如多条腿裤子）

**编辑模式**（右上角「编辑」触发）:
- 每行左侧出现红色删除圆点（点击确认删除）
- 每行右侧出现拖拽手柄（支持行内排序）
- 分类标题右侧出现拖拽手柄（支持分类排序）
- 右上角变为「完成」按钮退出编辑模式

**常用物品预设清单**（添加面板内）:
- 证件类：护照、身份证、签证、机票行程单、酒店预订单、保险单
- 电子类：手机、充电宝、数据线、转换插头、相机、耳机、笔记本
- 衣物类：上衣、裤子、内衣、袜子、外套、泳衣、睡衣
- 洗漱类：牙刷、牙膏、洗发水、沐浴露、护肤品、剃须刀
- 药品类：感冒药、止泻药、创可贴、防晒霜、驱蚊液

**数据存储**: 旅程的 `equip` 字段，格式为 JSON 字符串：
```json
{
  "categories": [
    {
      "id": "uuid",
      "name": "证件",
      "items": [
        { "id": "uuid", "name": "护照", "checked": true },
        { "id": "uuid", "name": "签证", "checked": false }
      ]
    }
  ]
}
```

### 4.8 旅程分享（新增）

**结构**:
1. 旅程预览卡片（旅程状态渐变色，含名称/城市/天数/景点数/城市数统计）
2. 分享方式：复制链接 / 生成海报 / 系统分享
3. 公开开关（是否展示到发现页）
4. 链接预览

**路由**: `/share/:id`，无需登录可访问

### 4.9 设置（新增）

**分组**:
- 通用：深色模式（开关）/ 语言（选择器）
- 存储：清除缓存（显示当前缓存大小）
- 关于：版本号 / 意见反馈

### 4.10 登录/注册（重新设计）

**登录页**（纯白背景）:
1. 品牌 Logo（52×52，圆角 14px，`#FF5B2E` 渐变）
2. App 名称「小肥路书」+ 副标题
3. 输入框（`#F2F2F7` 背景，圆角 10px）
4. 登录按钮（`#FF5B2E`，圆角 12px）
5. 注册入口

---

## 5. 组件变更清单

### 需要重写的组件

| 组件 | 变更内容 |
|------|---------|
| `AppColors` | 全部色值按本规范更新 |
| `AppTheme` | scaffoldBackgroundColor → `#F2F2F7` |
| `TravelListScreen` | 重写：Large Title + iOS 搜索栏 + 状态卡片 |
| `TravelCard` | 重写：渐变状态卡片样式 |
| `SignInScreen` | 重写：新登录页样式 |
| `SignUpScreen` | 重写：新注册页样式 |

### 需要新增的组件/页面

| 组件 | 说明 |
|------|------|
| `MainShell` | 三 Tab 底部导航容器 |
| `DiscoverScreen` | 发现页 |
| `ProfileScreen` | 我的页 |
| `MessagesScreen` | 消息中心 |
| `EditProfileScreen` | 编辑资料 |
| `LuggageScreen` | 行李清单 |
| `ShareScreen` | 旅程分享 |
| `SettingsScreen` | 设置页 |

### 保留不变的组件（仅调色）

- `TravelDetailScreen` — 交互逻辑不变，AppBar 背景/激活色更新
- `ScheduleListPanel` / `ScheduleTimelineItem` / `DaySidebar`
- `MapTabView` / `MapSearchBar` / `MapDaySelectorBar`
- 所有 Bottom Sheet（ScheduleEditSheet、ScheduleQuickTimeSheet 等）

---

## 6. 路由变更

```dart
// 新增路由
GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen())
GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())
GoRoute(path: '/profile/messages', builder: (_, __) => const MessagesScreen())
GoRoute(path: '/profile/edit', builder: (_, __) => const EditProfileScreen())
GoRoute(path: '/profile/settings', builder: (_, __) => const SettingsScreen())
GoRoute(
  path: '/travel/:id/luggage',
  builder: (_, state) => LuggageScreen(travelId: int.parse(state.pathParameters['id']!)),
)
GoRoute(
  path: '/share/:id',
  builder: (_, state) => ShareScreen(travelId: int.parse(state.pathParameters['id']!)),
)

// 修改：/travel 改为 MainShell 的 Tab 之一
```

---

## 7. 新增 API 端点需求

| 功能 | 方法 | 端点 | 说明 |
|------|------|------|------|
| 获取公开旅程列表 | GET | `/travel/public` | 发现页，支持关键词/城市过滤 |
| 获取消息列表 | GET | `/message` | 支持类型过滤 |
| 标记消息已读 | PUT | `/message/:id/read` | |
| 接受协作邀请 | POST | `/message/:id/accept` | |
| 拒绝协作邀请 | POST | `/message/:id/reject` | |
| 获取分享页数据 | GET | `/travel/:id/share` | 无需鉴权 |
| 更新用户资料 | PUT | `/user/profile` | 昵称、头像 |
