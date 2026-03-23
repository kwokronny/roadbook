# Flutter Monorepo Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将独立的 `roadbook_flutter/` 项目迁移进 monorepo，落地为 `packages/roadbook-flutter/`，并更新根级配置。

**Architecture:** 纯文件复制（不保留 git 历史），排除构建产物和本地生成文件。同步更新根 `package.json` 和 `.gitignore`，Flutter 包保留自身的 `.gitignore`，pnpm workspace 无需修改。

**Tech Stack:** Flutter/Dart, pnpm monorepo, zsh

---

## File Map

| 操作 | 文件 |
|---|---|
| Create (dir) | `packages/roadbook-flutter/`（含所有子文件） |
| Modify | `package.json` |
| Modify | `.gitignore` |

---

### Task 1: 复制 Flutter 源码到 packages/roadbook-flutter/

**Files:**
- Create: `packages/roadbook-flutter/`（目录及全部内容）

源目录：`/Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/`
目标目录：`packages/roadbook-flutter/`

排除以下内容：
- `.dart_tool/` — Dart 工具缓存
- `build/` — 构建产物
- `*.iml` — IDE 索引文件（`roadbook_flutter.iml`）
- `.flutter-plugins-dependencies` — 本地生成文件

保留（含隐藏文件）：
- `lib/`, `test/`, `android/`, `ios/`
- `pubspec.yaml`, `pubspec.lock`
- `analysis_options.yaml`, `devtools_options.yaml`
- `README.md`, `.metadata`, `.gitignore`

- [ ] **Step 1: 创建目标目录并复制文件**

```bash
rsync -av \
  --exclude='.git/' \
  --exclude='.dart_tool/' \
  --exclude='build/' \
  --exclude='*.iml' \
  --exclude='.flutter-plugins' \
  --exclude='.flutter-plugins-dependencies' \
  /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/ \
  packages/roadbook-flutter/
```

Expected: 输出复制的文件列表，以 `sent ... bytes` 结尾，无报错。

- [ ] **Step 2: 验证目录结构**

```bash
ls -la packages/roadbook-flutter/
```

Expected: 输出包含 `lib  test  android  ios  pubspec.yaml  pubspec.lock  analysis_options.yaml  devtools_options.yaml  README.md`，以及隐藏文件 `.metadata` 和 `.gitignore`

- [ ] **Step 3: 确认排除项未被复制**

```bash
ls packages/roadbook-flutter/.dart_tool 2>/dev/null && echo "FAIL: .dart_tool found" || echo "OK: .dart_tool excluded"
ls packages/roadbook-flutter/*.iml 2>/dev/null && echo "FAIL: .iml found" || echo "OK: .iml excluded"
```

Expected: 两行均输出 `OK: ...`

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/
git commit -m "feat: add roadbook-flutter package to monorepo"
```

---

### Task 2: 更新根 package.json — 新增 Flutter 脚本

**Files:**
- Modify: `package.json`

- [ ] **Step 1: 在 scripts 末尾新增三条 Flutter 命令**

编辑 `package.json`，在 `"build-doc"` 条目后追加：

```json
"dev-flutter": "cd packages/roadbook-flutter && flutter run",
"build-flutter-ios": "cd packages/roadbook-flutter && flutter build ios --release",
"build-flutter-android": "cd packages/roadbook-flutter && flutter build apk --release"
```

最终 `scripts` 块应为：

```json
"scripts": {
  "dev-api": "pnpm -F ./packages/roadbook-api dev",
  "build-api": "pnpm -F ./packages/roadbook-api --legacy --prod deploy roadbook-api",
  "dev-web": "pnpm -F ./packages/roadbook-vue dev",
  "build-web": "pnpm -F ./packages/roadbook-vue build",
  "dev-doc": "pnpm -F ./packages/docs dev",
  "build-doc": "pnpm -F ./packages/docs build",
  "dev-flutter": "cd packages/roadbook-flutter && flutter run",
  "build-flutter-ios": "cd packages/roadbook-flutter && flutter build ios --release",
  "build-flutter-android": "cd packages/roadbook-flutter && flutter build apk --release"
}
```

- [ ] **Step 2: 验证 JSON 语法**

```bash
node -e "JSON.parse(require('fs').readFileSync('package.json','utf8')); console.log('OK: valid JSON')"
```

Expected: `OK: valid JSON`

- [ ] **Step 3: Commit**

```bash
git add package.json
git commit -m "feat: add flutter scripts to root package.json"
```

---

### Task 3: 更新根 .gitignore — 追加 Flutter 忽略项

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: 在 .gitignore 末尾追加 Flutter 忽略项**

在 `.gitignore` 文件末尾追加以下内容：

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

- [ ] **Step 2: 验证 .gitignore 内容**

```bash
grep -c "roadbook-flutter" .gitignore
```

Expected: 输出 `16`（共 16 条含 `roadbook-flutter` 的行，含注释行）

- [ ] **Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: add flutter gitignore rules to root"
```
