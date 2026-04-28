# 砂旅 SandTrail · Design System

> 小肥路书的设计系统 — 温暖砂色画布上的磨砂玻璃界面

**砂旅 (SandTrail)** — 取自沙地上的旅行足迹。温暖的砂色调画布（Sand），旅途的轨迹（Trail），两者构成这套设计语言的核心：在温暖质感的底色上，用磨砂玻璃承载每一段旅程的记忆。

## 设计理念

- **Warm Canvas** — `#F2EDE8` 温暖砂色画布，缓慢流动的光斑呼吸
- **Frost Glass** — 52% 半透明白 + blur 40 的磨砂玻璃卡片
- **Dark Pill** — 近黑色胶囊按钮，沉稳有力
- **Coral Ember** — `#FF6B3D` 珊瑚色点睛，克制使用
- **Ink Family** — 单色调 `#1C1C1E` 文字体系，通过透明度区分层级

## 文件结构

```
packages/design-system/
├── README.md          # 本文件
├── SPEC.md            # 完整设计规范文档
├── MASCOT.md          # 吉祥物（猫鼬）设计 Brief
├── index.html         # 导航首页
├── design-system.html # 设计规范可视化（色板、字体、组件、动效）
├── all-screens.html   # 全部页面 Mockup
├── icons.html         # SVG 图标系统
└── dock-bouncy.html   # Dock 交互演示
```

## 查看设计系统

```bash
cd packages/design-system
python3 -m http.server 8080
# 打开 http://localhost:8080
```

## 设计规范速查

| Token | Value |
|-------|-------|
| Canvas | `#F2EDE8` |
| Card Frost | `rgba(255,255,255,0.52)` blur 40 saturate 1.4 |
| Sheet Frost | `rgba(255,255,255,0.72)` blur 50 saturate 1.8 |
| Dock Glass | `rgba(255,255,255,0.30)` blur 50 saturate 1.8 brightness 1.05 |
| Ink Primary | `rgba(28,28,30,0.90)` |
| Ink Secondary | `rgba(28,28,30,0.50)` |
| Ink Tertiary | `rgba(28,28,30,0.28)` |
| Coral Ember | `#FF6B3D` |
| Dark Pill | `rgba(28,28,30,0.88)` |
| Lavender | `#8C5CF6` |
| Display | 34px w200 |
| Title | 22px w300 |
| Headline | 17px w500 |
| Body | 15px w400 |
| Caption | 12px w400 |
| Card Radius | 24px |
| Pill Radius | 100px |
| Sheet Radius | 24px |
| Spring Curve | `Cubic(0.34, 1.3, 0.64, 1)` 600ms |
| Ease Out | `Cubic(0.22, 0, 0.36, 1)` 280ms |
