# Drawer UI Specification: 小肥路书 · Frosted Warmth

**Date:** 2026-04-15
**Extends:** SPEC.md (Glass Surfaces, Color Palette, Motion)
**Platform:** Flutter iOS/Android mobile

---

## 1. Drawer 分类 (Taxonomy)

路书中所有从边缘滑入的覆盖层统称 **Drawer**。按出现方式和用途分为四档：

| 类型 | 入场方向 | 最大高度 | 场景 |
|------|----------|----------|------|
| **Action Sheet** | 底部滑入 | 40% 屏高 | 单步操作：确认、选择、分享 |
| **Form Sheet** | 底部滑入 | 85% 屏高 | 多字段表单：创建行程、编辑行程单 |
| **Picker Sheet** | 底部滑入 | 70% 屏高 | 选择列表：时间、城市、协作者 |
| **Side Drawer** | 右侧滑入 | 100% 屏高 | 重内容面板：行程单详情、照片浏览 |

---

## 2. 通用结构 (Shared Anatomy)

所有 Drawer 共享相同的基础层结构，从外到内：

```
┌─ Scrim (半透明遮罩) ─────────────────────────────────┐
│                                                        │
│  ┌─ ClipRRect ─────────────────────────────────────┐  │
│  │  ┌─ BackdropFilter (磨砂) ───────────────────┐  │  │
│  │  │  ┌─ Container (玻璃面) ────────────────┐   │  │  │
│  │  │  │                                      │   │  │  │
│  │  │  │  [Drag Handle]          [Close Btn]  │   │  │  │
│  │  │  │  [Title]                             │   │  │  │
│  │  │  │  ─────────────────────               │   │  │  │
│  │  │  │  [Content Area]                      │   │  │  │
│  │  │  │                                      │   │  │  │
│  │  │  │  [Footer / CTA]                      │   │  │  │
│  │  │  │                                      │   │  │  │
│  │  │  └──────────────────────────────────────┘   │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### 2.1 Scrim (遮罩层)

| 属性 | 值 |
|------|-----|
| Color | `rgba(28,28,30,0.20)` |
| Tap to dismiss | 是 (Action Sheet / Picker Sheet)；否 (Form Sheet 编辑中) |
| 动画 | 与 Drawer 同步 fade in/out |

**禁止:** 纯黑遮罩 `rgba(0,0,0,*)` — 太冷，破坏暖色调。

### 2.2 Glass Surface (玻璃面)

Bottom Sheet 类 Drawer 使用 **Card Frost Strong** 材质：

```
backdrop-filter:  blur(50px) saturate(1.8)
background:       rgba(255,255,255,0.72)
border-top:       1px solid rgba(255,255,255,0.55)
shadow:           0 -8px 32px rgba(0,0,0,0.06)
border-radius:    24px 24px 0 0      (bottom sheet)
                  0 24px 24px 0      (side drawer, 左侧圆角)
```

Side Drawer 使用同材质，但圆角在左侧两角。

### 2.3 Drag Handle (拖拽手柄)

仅底部 Drawer 使用。Side Drawer 不需要。

| 属性 | 值 |
|------|-----|
| 尺寸 | 36 × 4 px |
| 圆角 | 2px (pill) |
| 颜色 | `rgba(28,28,30,0.16)` |
| 位置 | 水平居中，距顶部 10px |
| 触控区 | 扩展到 44 × 20px (满足 touch target) |

### 2.4 Close Button (关闭按钮)

| 属性 | 值 |
|------|-----|
| 容器 | 26 × 26px 圆形 |
| 背景 | `rgba(28,28,30,0.06)` |
| 图标 | `Icons.close`，12px，`Ink Secondary` |
| 位置 | Header 行右侧 |
| Press 反馈 | `scale(0.88)` spring 400ms |
| 触控区 | 扩展到 44 × 44px |

### 2.5 Header (标题区)

```
┌──────────────────────────────────────┐
│  [Drag Handle 36×4]                  │   ← 10px from top
│                                      │   ← 12px gap
│  标题文字              [Close 26×26] │   ← 水平 20px padding
│                                      │   ← 16px bottom gap
│  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ (optional)     │   ← divider (仅 Form Sheet)
└──────────────────────────────────────┘
```

**标题排版：**

| 属性 | 值 |
|------|-----|
| 字号 | 17px |
| 字重 | w500 |
| 颜色 | Ink Primary `rgba(28,28,30,0.90)` |
| 对齐 | 左对齐 (永不居中) |

**可选副标题 / 描述：**

| 属性 | 值 |
|------|-----|
| 字号 | 13px |
| 字重 | w400 |
| 颜色 | Ink Tertiary `rgba(28,28,30,0.28)` |
| 间距 | 标题下方 2px |

### 2.6 Content Area (内容区)

- 水平 padding: `20px` (page-h)
- 可滚动区域使用 `Expanded` + `SingleChildScrollView` 或 `ListView`
- 当内容超过可视区时，底部自然截断（无 fade mask）
- 键盘弹起时：`padding-bottom: MediaQuery.of(context).viewInsets.bottom`

### 2.7 Footer (底部操作区)

固定在 Drawer 底部，不随内容滚动。

```
┌──────────────────────────────────────┐
│  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈ (divider)      │   ← 只有上方有滚动内容时显示
│                                      │   ← 12px top gap
│  [Secondary Ghost]    [Primary CTA]  │   ← 水平 20px padding
│                                      │   ← SafeArea bottom
└──────────────────────────────────────┘
```

**Footer Divider（滚动提示线）：**
- 颜色 `rgba(28,28,30,0.06)`
- 仅在内容可滚动且未滚到底时显示
- 渐显/渐隐 200ms ease

---

## 3. Action Sheet (操作面板)

用于轻量级选择和确认。最多 6 个操作项。

### 3.1 布局

```
┌─────────────────────────────────────┐
│          [Drag Handle]              │
│                                     │
│  操作标题                   [Close] │
│  副标题说明文字 (optional)          │
│                                     │
│  ┌─ Action Item ─────────────────┐  │
│  │  [Icon 20]  操作名称          │  │  ← 每项 48px 高
│  └───────────────────────────────┘  │
│  ┌─ Action Item ─────────────────┐  │
│  │  [Icon 20]  操作名称          │  │
│  └───────────────────────────────┘  │
│  ┌─ Destructive Item ────────────┐  │
│  │  [Icon 20]  删除 (红色)       │  │
│  └───────────────────────────────┘  │
│                                     │
│           [取消] ghost btn          │  ← optional, 仅多项时
└─────────────────────────────────────┘
```

### 3.2 Action Item Token

| 属性 | 常规项 | 危险项 (Destructive) |
|------|--------|----------------------|
| 高度 | 48px | 48px |
| 背景 | 透明 | 透明 |
| 圆角 | 12px | 12px |
| 图标颜色 | Ink Secondary | `#D4410A` (暗红) |
| 文字颜色 | Ink Primary | `#D4410A` |
| 文字字号 | 15px w400 | 15px w500 |
| Press 状态 | bg `rgba(28,28,30,0.04)` | bg `rgba(212,65,10,0.06)` |
| 间距 | 图标与文字 12px | 同左 |

**分隔：** 项目之间用 `rgba(28,28,30,0.06)` 1px divider 分隔，距两侧 20px indent。

### 3.3 确认型 Action Sheet

简单确认场景（如"确定删除？"）使用精简布局：

```
┌─────────────────────────────────────┐
│          [Drag Handle]              │
│                                     │
│  确定删除这个行程吗？              │  ← 17px w500, Ink Primary
│  删除后无法恢复                     │  ← 13px w400, Ink Tertiary
│                                     │  ← 24px gap
│  [取消 Ghost]      [删除 Coral CTA] │  ← 双按钮横排
│                                     │
└─────────────────────────────────────┘
```

**按钮布局：**
- 双按钮：左 Ghost (flex 1)，右 Primary/Destructive (flex 1)，间距 12px
- 单按钮：全宽
- Destructive CTA 使用 `#D4410A` 填充（非 Coral，区分破坏性）

---

## 4. Form Sheet (表单面板)

用于创建和编辑操作。包含输入框、选择器、开关等表单控件。

### 4.1 布局

```
┌─────────────────────────────────────┐
│          [Drag Handle]              │
│                                     │
│  创建旅程                   [Close] │
│  ──────────────── (divider)         │
│                                     │
│  ┌─ Form Group (白底卡片) ───────┐  │
│  │  标签          [输入框]       │  │
│  │  ─────────────────────        │  │
│  │  标签          [选择器 >]     │  │
│  │  ─────────────────────        │  │
│  │  标签          [开关]         │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌─ Form Group ──────────────────┐  │
│  │  ...                          │  │
│  └───────────────────────────────┘  │
│                                     │
│  ──────────────── (footer divider)  │
│  [保存 / 创建]  Dark Pill CTA      │  ← 全宽
└─────────────────────────────────────┘
```

### 4.2 Form Group Card (表单组卡片)

iOS 风格分组表单，白底卡片嵌套在磨砂 Sheet 内：

| 属性 | 值 |
|------|-----|
| 背景 | `rgba(255,255,255,0.70)` (白底在磨砂上) |
| 圆角 | 14px |
| 内间距 | 0（由每行自行控制） |
| 组间距 | 16px |
| 组标题 | 12px w400, Ink Tertiary, 距组顶 8px, 左 20px |

### 4.3 Form Row (表单行)

```
┌──────────────────────────────────────┐
│  16px │ Label 60px │ 12px │ Input │ 16px │
│       │ fixed      │      │ flex  │      │
└──────────────────────────────────────┘
Height: 48px (single line), auto (multi-line)
```

| 元素 | 属性 |
|------|------|
| Label | 15px w400, Ink Primary, 60px 固定宽 |
| Input | 15px w400, Ink Primary, 右对齐 (单行) 或 左对齐 (多行) |
| Placeholder | 15px w400, Ink Tertiary |
| Row Divider | `rgba(28,28,30,0.06)`, 左侧 indent 76px (label宽 + gap) |

### 4.4 Form Controls

**Text Input (on Form Card):**
```
background:    transparent (行内无额外背景)
border:        无
focus 指示:    行左侧 2px coral 竖线 (替代 focus ring)
```

**Selector Row (点击展开):**
```
右侧:          值文字 + chevron.right 12px, Ink Tertiary
Press 状态:    行背景 rgba(28,28,30,0.03)
```

**Toggle/Switch:**
```
Track on:      Coral Ember #FF6B3D
Track off:     rgba(28,28,30,0.10)
Thumb:         White, shadow 0 1px 3px rgba(0,0,0,0.12)
尺寸:          51 × 31px (iOS 标准)
```

**Multi-line Input:**
```
最少行数:      3
最大行数:      6 (可滚动)
行高:          auto, 不固定 48px
底部 padding:  12px
```

### 4.5 表单验证

| 状态 | 表现 |
|------|------|
| 默认 | 无特殊样式 |
| Focus | 行左侧 2px coral 竖线 |
| Error | Label 变为 `#D4410A`，错误文字 12px `#D4410A` 出现在行下方 |
| Disabled | Ink Tertiary 文字，不可交互 |

错误动画：`translateX` 抖动 — `[0, -6, 6, -4, 4, 0]` @ 400ms，spring 曲线。

---

## 5. Picker Sheet (选择面板)

用于从列表中选择一个或多个项目。

### 5.1 布局

```
┌─────────────────────────────────────┐
│          [Drag Handle]              │
│                                     │
│  选择城市                   [Close] │
│                                     │
│  ┌─ Search Input ────────────────┐  │  ← optional
│  │  🔍  搜索城市                 │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌─ Filter Chips (横向滚动) ─────┐  │  ← optional
│  │  [全部] [热门] [最近]         │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌─ Scrollable List ─────────────┐  │
│  │  Section Header "A"           │  │
│  │  ☐  阿坝                      │  │
│  │  ☐  安顺                      │  │
│  │  Section Header "B"           │  │
│  │  ☑  北京                      │  │
│  │  ☐  保定                      │  │
│  │  ...                          │  │
│  └───────────────────────────────┘  │
│                                     │
│  ──────────────── (footer)          │
│  已选 2 个城市     [确定] Dark Pill │
└─────────────────────────────────────┘
```

### 5.2 Search Input (on Sheet)

| 属性 | 值 |
|------|-----|
| 背景 | `rgba(28,28,30,0.05)` |
| 圆角 | 14px |
| 高度 | 40px |
| 图标 | 搜索 icon, 16px, Ink Tertiary |
| Placeholder | 14px w400, Ink Tertiary |
| Focus Border | `rgba(255,107,61,0.40)` |
| 水平 margin | 20px (page-h) |

### 5.3 List Item

| 属性 | 未选中 | 已选中 |
|------|--------|--------|
| 高度 | 48px | 48px |
| 背景 | 透明 | `rgba(255,107,61,0.04)` |
| 文字 | 15px w400, Ink Primary | 15px w500, Ink Primary |
| 左侧 | 圆形框 20px, border `rgba(28,28,30,0.16)` | 圆形框 20px, Coral 填充 + 白色勾 |
| Press | bg `rgba(28,28,30,0.04)` | bg `rgba(255,107,61,0.06)` |

**Checkbox 动画：** 选中时 `scale(0) → scale(1.0)` + 勾号描边动画，Spring `(0.34,1.3,0.64,1)` 400ms。

### 5.4 Section Header (分组标题)

| 属性 | 值 |
|------|-----|
| 字号 | 12px w500 |
| 颜色 | Ink Tertiary |
| Padding | 左 20px, 上 16px, 下 4px |
| 背景 | 透明 (与 sheet 融合) |
| Sticky | 是 (SliverPersistentHeader) |

### 5.5 Right-side Letter Index (字母索引)

城市类长列表可选配右侧字母导航：

| 属性 | 值 |
|------|-----|
| 字母字号 | 10px w500 |
| 颜色 | Ink Tertiary，触摸时 Coral |
| 宽度 | 16px，触控区扩展 28px |
| 位置 | 固定右侧，垂直居中 |
| 触摸反馈 | 放大到 24px 圆形 Coral 背景 + 白色字母 |

### 5.6 Footer Counter

```
已选 N 个 [item]                    [确定 →]
```

| 元素 | 属性 |
|------|------|
| 计数文字 | 13px w400, Ink Secondary |
| 数字 | 13px w500, Coral Ember |
| CTA | Dark Pill, 带 → 箭头 |
| CTA disabled | 无选择时 `rgba(28,28,30,0.12)` 背景, Ink Tertiary 文字 |

---

## 6. Side Drawer (侧边面板)

用于重内容展示，如详情预览、照片浏览。从右侧滑入。

### 6.1 布局

```
┌─ Scrim ────────────┬─ Side Drawer ──────┐
│                    │                     │
│                    │  [Header]           │
│    可见的底层页面   │  ───────────        │
│    parallax 偏移    │                     │
│                    │  [Content]          │
│                    │                     │
│                    │                     │
│                    │  [Footer]           │
│                    │                     │
└────────────────────┴─────────────────────┘
```

### 6.2 Surface Token

| 属性 | 值 |
|------|-----|
| 宽度 | 85% 屏宽 (max 380px) |
| 高度 | 100% 屏高 |
| 圆角 | 24px 0 0 24px (左侧两角) |
| 背景 | `rgba(255,255,255,0.72)` |
| Blur | `blur(50px) saturate(1.8)` |
| 左边框 | 1px solid `rgba(255,255,255,0.55)` |
| Shadow | `-8px 0 32px rgba(0,0,0,0.06)` |

### 6.3 Header

```
┌──────────────────────────────────┐
│  [Back ←]  标题文字     [Action] │  ← 56px 高
│  ──────────────────────────────  │
└──────────────────────────────────┘
```

- Back 按钮: Dark Pill Circle 32px，`Icons.arrow_back` 16px
- Action 按钮: Ghost 或 icon button (optional)
- 标题: 17px w500, Ink Primary, 居中

### 6.4 Parallax Effect (底层偏移)

Side Drawer 展开时，底层页面向左偏移，增加空间感：

| 属性 | 值 |
|------|-----|
| 偏移量 | -60px (底层向左推) |
| 缩放 | `scale(0.95)` |
| 曲线 | 与 Drawer 滑入同步 |
| 圆角 | 底层添加 16px 临时圆角 |

---

## 7. 动画规范 (Motion Specs)

### 7.1 Bottom Sheet Drawer 入场/退场

| 阶段 | 属性 | 值 | 曲线 | 时长 |
|------|------|----|------|------|
| 入场 | Sheet translateY | 100% → 0 | Expressive `(0.22,1.0,0.36,1)` | 380ms |
| 入场 | Scrim opacity | 0 → 1 | ease | 280ms |
| 退场 | Sheet translateY | 0 → 100% | Ease Out `(0.22,0.0,0.36,1)` | 280ms |
| 退场 | Scrim opacity | 1 → 0 | ease | 200ms |

### 7.2 Side Drawer 入场/退场

| 阶段 | 属性 | 值 | 曲线 | 时长 |
|------|------|----|------|------|
| 入场 | Drawer translateX | 100% → 0 | Spring `(0.34,1.3,0.64,1)` | 500ms |
| 入场 | Scrim opacity | 0 → 1 | ease | 300ms |
| 入场 | 底层 translateX | 0 → -60px | Spring (同步) | 500ms |
| 入场 | 底层 scale | 1.0 → 0.95 | Spring (同步) | 500ms |
| 退场 | Drawer translateX | 0 → 100% | Ease Out | 280ms |
| 退场 | Scrim opacity | 1 → 0 | ease | 200ms |
| 退场 | 底层 restore | 回到原位 | Ease Out | 280ms |

### 7.3 手势交互

**Bottom Sheet 下拉关闭：**

| 属性 | 值 |
|------|-----|
| 触发区域 | Drag Handle + Header 区域，或内容区已滚到顶部 |
| 关闭阈值 | 下拉 > 120px 或 下拉速度 > 700 px/s |
| 弹回阈值 | 下拉 < 120px 且 速度 < 700 px/s |
| 弹回动画 | Spring `(0.34,1.3,0.64,1)` 500ms |
| 跟手阻尼 | 1:1 跟手 (content 未到顶时不拦截) |

**Side Drawer 左滑关闭：**

| 属性 | 值 |
|------|-----|
| 触发区域 | 整个 Drawer 面板 |
| 关闭阈值 | 右滑 > 80px 或 速度 > 500 px/s |
| 弹回 | 同上 spring |

### 7.4 内容进场编排

Drawer 入场后，内部元素需要交错进场（staggered reveal）：

| 元素 | 延迟 (相对 Drawer 打开) | 动画 | 时长 |
|------|--------------------------|------|------|
| Header | 0ms (随 Drawer 一起) | — | — |
| 第 1 个内容块 | 80ms | fade + translateY(12→0) | 320ms Expressive |
| 第 2 个内容块 | 130ms | fade + translateY(12→0) | 320ms Expressive |
| 第 N 个内容块 | 80 + N×50ms | fade + translateY(12→0) | 320ms Expressive |
| Footer CTA | 200ms | fade + translateY(8→0) | 280ms Ease Out |
| Max stagger | Cap 300ms | 最多 5 个元素错开 | — |

---

## 8. 嵌套与堆叠 (Stacking)

### 8.1 Sheet 上再开 Sheet

允许最多 **2 层** Sheet 堆叠（原始页面 + Sheet 1 + Sheet 2）。

| 层级 | 表现 |
|------|------|
| 第 1 层 Sheet | 正常展开 |
| 第 2 层 Sheet | 第 1 层 Sheet 下沉 — `scale(0.96)` + `translateY(-12px)` + blur 加深 |
| 第 2 层关闭 | 第 1 层恢复原位，spring 500ms |

**Scrim 堆叠：** 第 2 层 Scrim 叠加在第 1 层之上，不替换。总遮罩效果自然加深。

### 8.2 Sheet 内打开 Dialog

Sheet 内可弹出 Dialog（如日期选择器、确认删除）。Dialog 使用标准 Dialog 规范：

```
scale(0.92) → scale(1.0) + fade in, Spring 350ms
```

Sheet 保持原位，Dialog 浮于 Sheet 之上，额外一层 Scrim `rgba(28,28,30,0.15)`。

---

## 9. 响应式与安全区 (Responsive & Safe Area)

### 9.1 SafeArea 处理

```dart
SafeArea(
  top: false,           // Sheet 已有圆角和 handle，不需要顶部安全区
  bottom: true,         // 尊重 home indicator
  child: content,
)
```

### 9.2 键盘适配

| 场景 | 处理 |
|------|------|
| 键盘弹起 | Sheet 整体上推 `viewInsets.bottom` |
| 键盘收起 | Sheet 回到原位，Ease Out 280ms |
| 内容被遮挡 | 自动滚动到当前 focus 的 input |
| Sheet 高度不足 | 键盘弹起时临时扩展到 95% 屏高 |

### 9.3 横屏 (Landscape)

| 类型 | 横屏适配 |
|------|----------|
| Bottom Sheet | max-height: 90% 屏高, max-width: 480px 居中 |
| Side Drawer | 宽度改为 50% 屏宽 (max 420px) |

---

## 10. 无障碍 (Accessibility)

| 属性 | 要求 |
|------|------|
| Semantics | Sheet 标记为 `Semantics(label: '对话框', container: true)` |
| Focus Trap | 焦点限制在 Sheet 内，关闭后恢复原焦点 |
| Close | 支持 `Escape` 键 / iOS VoiceOver 双指 Z 手势关闭 |
| Contrast | 所有文字在 `rgba(255,255,255,0.72)` 背景上满足 WCAG AA (4.5:1) |
| Announce | Sheet 打开时读出标题，关闭时读出 "已关闭" |
| 动画降级 | `MediaQuery.disableAnimations` 时跳过动画，直接显示 |

---

## 11. 示例映射 (Existing Screens → Drawer Type)

| 现有功能 | Drawer 类型 | 说明 |
|----------|------------|------|
| 创建/编辑旅程 (TravelFormSheet) | **Form Sheet** | 表单组卡片，footer CTA |
| 编辑行程单 (ScheduleEditSheet) | **Form Sheet** | 类型切换 + 输入框 |
| 快速设置时间 (QuickTimeSheet) | **Picker Sheet** | Day 横滚 + Hour 网格 |
| 城市选择 (CityPickerSheet) | **Picker Sheet** | 字母索引 + 搜索 + 多选 |
| 协作者管理 (CollaboratorSheet) | **Picker Sheet** | 邀请链接 + 列表 |
| 批量导入 (CollectImportSheet) | **Form Sheet** | 分阶段流程 |
| 行程更多操作 | **Action Sheet** | 编辑/分享/删除选项 |
| 确认删除 | **Action Sheet (确认型)** | 标题 + 双按钮 |
| 照片浏览 | **Side Drawer** | 全高，图片 + 滑动 |

---

## 12. Anti-Patterns (Drawer 专属禁止项)

- **禁止全屏 Sheet** — 最大 85% 屏高，保留顶部可见 canvas，暗示可下拉关闭
- **禁止无 Handle 的 Bottom Sheet** — 所有底部 Sheet 必须有 Drag Handle
- **禁止 Sheet 内嵌 Tab Bar** — Sheet 是单任务面板，不做页面级导航
- **禁止超过 2 层 Sheet 堆叠** — 超过 2 层说明信息架构有问题，应改为页面跳转
- **禁止 Sheet 内使用 Back 按钮** — Sheet 只有 Close，不模拟页面栈
- **禁止冷色调 Scrim** — `rgba(0,0,0,*)` 破坏暖色调，必须用 ink 色系 `rgba(28,28,30,*)`
- **禁止弹跳过大的 spring** — overshoot > 1.3 会显得卡通，保持克制
- **禁止 Sheet 内放全宽图片** — 图片保持 16px margin + 14px radius
- **禁止居中标题** — 所有 Drawer 标题左对齐，与页面标题风格统一
