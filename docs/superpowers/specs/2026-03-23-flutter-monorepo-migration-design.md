# Flutter Monorepo Migration — 设计文档

**日期：** 2026-03-23
**版本：** v1.0

---

## 1. 目标

将独立的 `roadbook_flutter/` 项目迁移进现有 pnpm monorepo（`roadbook/`），落地为 `packages/roadbook-flutter/`，与 `roadbook-api`、`roadbook-vue`、`docs` 并列。不保留 git 历史，不新增 CI/CD。

---

## 2. 迁移范围

### 复制的内容

| 路径 | 说明 |
|---|---|
| `lib/` | Dart 源码（全部） |
| `test/` | 测试文件 |
| `android/` | Android 平台配置 |
| `ios/` | iOS 平台配置 |
| `pubspec.yaml` | 依赖声明 |
| `pubspec.lock` | 依赖锁定 |
| `analysis_options.yaml` | Dart 静态分析配置 |
| `devtools_options.yaml` | DevTools 配置 |
| `README.md` | 项目说明 |
| `.metadata` | Flutter 项目元数据，Flutter 工具链需要此文件进行版本升级和能力检测 |

### 排除的内容

| 路径 | 原因 |
|---|---|
| `build/` | 构建产物，不入库 |
| `.dart_tool/` | Dart 工具缓存，本地生成 |
| `*.iml` | IDE 索引文件 |
| `.flutter-plugins` | 本地生成，不入库 |
| `.flutter-plugins-dependencies` | 本地生成，不入库 |

---

## 3. pnpm workspace 配置

`packages/roadbook-flutter/` 没有 `package.json`，pnpm 会自动忽略该目录，**无需修改 `pnpm-workspace.yaml`**。

---

## 4. 根 `package.json` 新增脚本

在根 `package.json` 的 `scripts` 中新增以下条目，脚本在 `packages/roadbook-flutter/` 目录下执行 Flutter CLI：

```json
"dev-flutter": "cd packages/roadbook-flutter && flutter run",
"build-flutter-ios": "cd packages/roadbook-flutter && flutter build ios --release",
"build-flutter-android": "cd packages/roadbook-flutter && flutter build apk --release"
```

> 前提：执行机器已安装 Flutter SDK 并配置好 `flutter` PATH。

---

## 5. `.gitignore` 更新

`packages/roadbook-flutter/` 会保留 Flutter 项目自带的 `.gitignore`，Git 会自动识别子目录中的 `.gitignore`，大部分忽略规则已由其覆盖。

在根 `.gitignore` 末尾追加以下内容，确保在根目录级别也能正确忽略：

```gitignore
# Flutter (packages/roadbook-flutter)
packages/roadbook-flutter/build/
packages/roadbook-flutter/.dart_tool/
packages/roadbook-flutter/.flutter-plugins
packages/roadbook-flutter/.flutter-plugins-dependencies
packages/roadbook-flutter/*.iml
packages/roadbook-flutter/.pub-cache/
packages/roadbook-flutter/.pub/
packages/roadbook-flutter/coverage/
packages/roadbook-flutter/.idea/
packages/roadbook-flutter/android/app/debug/
packages/roadbook-flutter/android/app/profile/
packages/roadbook-flutter/android/app/release/
packages/roadbook-flutter/ios/Flutter/.last_build_id
packages/roadbook-flutter/app.*.symbols
packages/roadbook-flutter/app.*.map.json
```

---

## 6. 目录结构变化

迁移后 monorepo 结构：

```
roadbook/
├── packages/
│   ├── roadbook-api/       # Koa 2 后端
│   ├── roadbook-vue/       # Vue 3 前端
│   ├── roadbook-flutter/   # Flutter App（新增）
│   │   ├── lib/
│   │   ├── test/
│   │   ├── android/
│   │   ├── ios/
│   │   ├── pubspec.yaml
│   │   └── ...
│   └── docs/               # VitePress 文档
├── package.json            # 新增 dev-flutter / build-flutter-* 脚本
├── pnpm-workspace.yaml     # 无需修改
└── .gitignore              # 追加 Flutter 忽略项
```

---

## 7. 不在本次范围内

- 保留 `roadbook_flutter/` 的 git 历史
- GitHub Actions Flutter CI/CD workflow
- Flutter Web / Desktop 支持
- 删除原始 `roadbook_flutter/` 目录（由用户手动决定）
