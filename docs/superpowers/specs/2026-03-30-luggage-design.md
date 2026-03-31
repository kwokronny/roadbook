# 行李清单 — 设计规范

**日期**: 2026-03-30
**状态**: 已确认，待实现

---

## 1. 范围

| 屏幕 | 路由 | 类型 |
|------|------|------|
| 行李清单 (LuggageScreen) | `/travel/:id/luggage` | Push |

入口：`TravelDetailScreen` 更多菜单 → 「行李清单」（当前为 SnackBar 占位，替换为 `context.push`）。

---

## 2. 设计原则

沿用全局设计规范：
- 背景 `#F2F2F7`，卡片白底 `#FFFFFF`，圆角 12px
- 菜单行高 44px，分隔线 `rgba(60,60,67,0.1) 0.5px`
- 品牌色 `#FF5B2E`，破坏性操作 `#FF3B30`

---

## 3. 数据存储

行李清单存储在现有 `Travel.equip` TEXT 字段（JSON 字符串）。

### 3.1 JSON 结构

```json
[
  {
    "id": "uuid-v4",
    "name": "证件",
    "emoji": "📋",
    "items": [
      { "id": "uuid-v4", "text": "护照" },
      { "id": "uuid-v4", "text": "签证" }
    ]
  },
  {
    "id": "uuid-v4",
    "name": "自定义分类",
    "emoji": "📦",
    "items": []
  }
]
```

**注意**：`checked` 状态**不存入后端**，仅在当前会话本地维护。

### 3.2 后端接口

| 接口 | 说明 | 变更 |
|------|------|------|
| `POST /api/travel/equip/set` | 保存整个清单 JSON | 已存在，仅需在 Flutter `ApiEndpoints` 中添加常量 |
| `POST /api/travel/detail` | 获取旅程详情（含 equip 字段） | 已存在，无需改动 |

Flutter 端 `ApiEndpoints` 补充：
```dart
static const String equipSet = '/api/travel/equip/set';
```

---

## 4. Flutter 数据模型

```dart
// lib/shared/models/luggage.dart

class LuggageItem {
  const LuggageItem({ required this.id, required this.text });
  final String id;
  final String text;

  factory LuggageItem.fromJson(Map<String, dynamic> json) =>
      LuggageItem(id: json['id'] as String, text: json['text'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class LuggageCategory {
  const LuggageCategory({ required this.id, required this.name, required this.emoji, required this.items });
  final String id;
  final String name;
  final String emoji;
  final List<LuggageItem> items;

  factory LuggageCategory.fromJson(Map<String, dynamic> json) => LuggageCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    emoji: (json['emoji'] as String?) ?? '📦',
    items: (json['items'] as List<dynamic>)
        .map((e) => LuggageItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'emoji': emoji,
    'items': items.map((i) => i.toJson()).toList(),
  };

  LuggageCategory copyWith({ String? name, List<LuggageItem>? items }) =>
      LuggageCategory(id: id, name: name ?? this.name, emoji: emoji, items: items ?? this.items);
}
```

---

## 5. 状态管理

### 5.1 LuggageState

```dart
// lib/features/luggage/domain/luggage_provider.dart

class LuggageState {
  const LuggageState({
    required this.categories,
    required this.checkedIds,   // 本地勾选状态，不持久化
    required this.isSaving,
    required this.canEdit,      // 当前用户角色是否可编辑
  });
  final List<LuggageCategory> categories;
  final Set<String> checkedIds;
  final bool isSaving;
  final bool canEdit;

  int get totalItems => categories.fold(0, (s, c) => s + c.items.length);
  int get checkedCount => checkedIds.length;
}
```

### 5.2 LuggageNotifier

```dart
class LuggageNotifier extends AutoDisposeAsyncNotifier<LuggageState> {
  // build(): 从 Travel.equip 解析，判断用户角色
  // toggleCheck(String itemId)  — 纯本地，不调用 API
  // addCategory(String name)    — 生成 UUID，emoji 固定 '📦'，调用 _save()
  // deleteCategory(String catId)
  // addItems(String catId, List<String> texts)  — 批量添加物品
  // deleteItem(String catId, String itemId)
  // importTemplate(LuggageSeason season)        — 追加合并，跳过同名已有物品
  // _save()  — POST /api/travel/equip/set，更新 isSaving
}

final luggageProvider = AsyncNotifierProvider.autoDispose
    .family<LuggageNotifier, LuggageState, int>(LuggageNotifier.new);
```

---

## 6. 预设数据

```dart
// lib/shared/constants/luggage_presets.dart

enum LuggageSeason { spring, summer, autumn, winter }

// 按季节返回分类+物品列表（Dart 常量，无网络请求）
List<LuggageCategory> seasonTemplate(LuggageSeason season) { ... }

// 按分类名返回常用物品建议列表（用于添加物品面板）
// categoryName 匹配不到时返回通用列表
List<String> presetItemsFor(String categoryName) { ... }

// 跨分类通用物品（充电宝、雨伞、耳机等）
const List<String> universalPresets = [...];
```

**四季模板内容**：

| 季节 | 月份 | 分类预设 |
|------|------|---------|
| 🌸 春季 | 3–5月 | 证件、衣物（薄外套/长袖）、电子、洗漱 |
| ☀️ 夏季 | 6–8月 | 证件、衣物（T恤/短裤/凉鞋）、防晒护肤、电子、药品（防蚊液）|
| 🍂 秋季 | 9–11月 | 证件、衣物（外套/针织衫）、电子、洗漱、药品 |
| ❄️ 冬季 | 12–2月 | 证件、御寒衣物（羽绒服/围巾/手套）、电子、药品（感冒药/暖宝宝）、洗漱（保湿面霜）|

**分类专属预设示例**（`presetItemsFor`）：

| 分类名关键词 | 预设物品 |
|------------|---------|
| 证件 | 护照、身份证、签证、机票打印件、酒店预订单、旅行保险单、驾照 |
| 衣物 | T恤、内衣内裤、外套、袜子、运动鞋、正装、睡衣、帽子 |
| 电子 | 充电宝、手机充电线、转换插头、相机、耳机、移动硬盘 |
| 药品 | 感冒药、肠胃药、止痛药、防蚊液、创可贴、防晒霜 |
| 洗漱 | 牙刷、牙膏、洗发水、沐浴露、护手霜、剃须刀 |
| 其他/默认 | 充电宝、雨伞、耳机、眼罩颈枕、保温杯、零食 |

---

## 7. 界面设计

### 7.1 LuggageScreen 主屏

```
Scaffold (背景 #F2F2F7)
├── AppBar「行李清单」
│   └── 右侧「导入模板」按钮（仅 canEdit 时显示）
├── 进度区
│   ├── 进度文字：「X / Y 已打包」（本地实时计算）
│   └── 进度条（LinearProgressIndicator，品牌色）
├── 分类列表（ListView）
│   └── LuggageCategorySection × N
│       ├── 分类标题行（emoji + 名称 + 已勾/总数 + 展开箭头）
│       │   └── 长按 → 删除分类确认 AlertDialog（仅 canEdit）
│       └── 展开时：
│           ├── 物品行 × N
│           │   ├── 圆形勾选框（本地状态，勾选变品牌色）
│           │   ├── 物品名（勾选时灰色删除线）
│           │   └── 左滑 → 红色删除按钮（仅 canEdit）
│           └── 「+ 添加物品」行（仅 canEdit）→ AddItemSheet
└── FAB（仅 canEdit）→ 添加分类 Bottom Sheet
```

### 7.2 添加分类 Bottom Sheet

```
Bottom Sheet
├── Handle
├── 标题「添加分类」
├── TextField（输入分类名称，自动聚焦）
└── 「添加」按钮（名称非空时启用，品牌色）
```

- 新分类默认 emoji：`📦`
- 成功后自动展开新分类

### 7.3 AddItemSheet（添加物品）

```
Bottom Sheet（高度 80% 屏幕）
├── Handle
├── 标题「添加物品」+ 右上「已选 N」
├── 搜索栏（iOS 胶囊风格）
│   └── 有文字时显示清空按钮
├── 滚动区
│   ├── 分类专属预设组（标题：当前分类名常用）
│   │   └── 物品行：圆形多选框 + 物品名
│   │       └── 已存在于该分类的物品：灰色不可选
│   └── 通用常用组
│       └── 物品行 × N
│       └── 「输入自定义物品…」行（点击弹输入框）
├── 搜索状态：
│   ├── 匹配结果列表（关键词高亮）
│   └── 无匹配时：「添加 "XXX" 为新物品」快捷创建
└── 底部固定：「添加 N 项到「分类名」」按钮
```

### 7.4 TemplateSheet（季节模板）

```
Bottom Sheet
├── Handle
├── 标题「选择出行季节」
├── 副标题「点击即导入对应季节的打包建议」
└── 2×2 季节卡片网格
    ├── 🌸 春季（3–5月）
    ├── ☀️ 夏季（6–8月）
    ├── 🍂 秋季（9–11月）
    └── ❄️ 冬季（12–2月）
        └── 点击任意卡片 → 直接导入 → Sheet 关闭
            → SnackBar「已导入夏季模板，新增 X 项」
```

**合并规则**：同名分类追加物品（跳过文字完全相同的已有物品）；不同名分类直接新建追加。

---

## 8. 权限控制

| 角色 | 勾选/取消 | 添加/删除物品 | 添加/删除分类 | 导入模板 |
|------|----------|-------------|-------------|---------|
| manage | ✅ | ✅ | ✅ | ✅ |
| edit | ✅ | ✅ | ✅ | ✅ |
| view | ✅（本地） | ❌ | ❌ | ❌ |

`canEdit` 由 `travel.collaborators` 中当前用户的 role 决定，在 `LuggageNotifier.build()` 中计算。

---

## 9. 路由

在 `lib/core/router.dart` 中，找到 `/travel/:id` 路由，添加子路由：

```dart
GoRoute(
  path: 'luggage',
  builder: (context, state) {
    final id = int.parse(state.pathParameters['id']!);
    return LuggageScreen(travelId: id);
  },
),
```

同时更新 `TravelDetailScreen` 中行李清单菜单项，从 SnackBar 改为：
```dart
context.push('/travel/${travel.id}/luggage');
```

---

## 10. 文件清单

| 操作 | 路径 |
|------|------|
| 新增 | `packages/roadbook-flutter/lib/shared/models/luggage.dart` |
| 新增 | `packages/roadbook-flutter/lib/shared/constants/luggage_presets.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/data/luggage_repository.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/domain/luggage_provider.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/presentation/luggage_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/presentation/widgets/luggage_category_section.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/presentation/widgets/add_item_sheet.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/luggage/presentation/widgets/template_sheet.dart` |
| 修改 | `packages/roadbook-flutter/lib/shared/api/api_endpoints.dart` — 新增 `equipSet` |
| 修改 | `packages/roadbook-flutter/lib/core/router.dart` — 新增 `/travel/:id/luggage` |
| 修改 | `packages/roadbook-flutter/lib/features/travel/presentation/travel_detail_screen.dart` — 行李清单入口改为真实导航 |
| 新增测试 | `packages/roadbook-flutter/test/shared/models/luggage_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/features/luggage/domain/luggage_provider_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/widget/features/luggage/luggage_screen_test.dart` |
