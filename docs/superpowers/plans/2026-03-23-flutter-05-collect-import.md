# Roadbook Flutter — Plan 5: Batch Import (CollectImportSheet)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现批量导入面板，支持两种模式：AI 采集（粘贴 JSON 数组）和点评收藏（粘贴大众点评 JSON），逐条调用 `ScheduleRepository.add()` 并展示每条的成功/失败状态。

**Architecture:** Feature-first。在 `features/schedule/data/` 新增 `CollectImportService`（纯解析/转换，可单元测试）；`features/schedule/presentation/` 新增 `CollectImportSheet`（底部面板，状态机驱动的进度展示）；`TravelDetailScreen` 的批量导入按钮替换为真实实现。

**Tech Stack:** Flutter (stable), flutter_riverpod ^2.5 (manual, non-codegen), mocktail ^1.0, dart:convert

**Spec:** `docs/superpowers/specs/2026-03-20-roadbook-flutter-design.md` §5.5

> **坐标系说明：** AI 采集模式要求用户输入 GCJ-02（高德标准）坐标。客户端不做坐标转换，直接存储传入值。
> **Dianping 点评模式：** `lng/lat` 字段已为 GCJ-02，直接拼接为 `"lng,lat"` 格式。
> **startTime 格式：** AI 模式 JSON 中的 `startTime` 为 `"YYYY-MM-DD HH:mm:ss"` 字符串，需用 `DateTime.tryParse()` 解析；解析失败时跳过该字段（视为待规划）。

---

## File Map

### 新建文件
```
lib/
└── features/schedule/
    ├── data/
    │   └── collect_import_service.dart   # 纯解析/转换函数
    └── presentation/
        └── collect_import_sheet.dart     # 批量导入底部面板

test/
└── features/schedule/
    └── data/
        └── collect_import_service_test.dart
```

### 修改文件
- `lib/features/travel/presentation/travel_detail_screen.dart` — 批量导入按钮从 SnackBar 替换为 `CollectImportSheet.show()`

---

## Task 1: CollectImportService — 解析与转换

纯函数，无副作用，不依赖 Dio / Riverpod，容易单元测试。

**Files:**
- Create: `lib/features/schedule/data/collect_import_service.dart`
- Create: `test/features/schedule/data/collect_import_service_test.dart`

- [ ] **Step 1: 写测试（先写）**

创建 `test/features/schedule/data/collect_import_service_test.dart`：

```dart
// test/features/schedule/data/collect_import_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/data/collect_import_service.dart';
import 'package:roadbook_flutter/features/schedule/data/schedule_repository.dart';

void main() {
  const tId = 42;

  // ─── AI mode ──────────────────────────────────────────────────────────────

  group('CollectImportService.parseAiJson', () {
    test('parses valid JSON array into ScheduleFormData list', () {
      const json = '''[
        {
          "name": "颐和园",
          "coordinate": "116.27,39.99",
          "address": "北京市海淀区",
          "notes": "著名皇家园林",
          "startTime": "2024-06-01 09:00:00"
        },
        {
          "name": "故宫",
          "coordinate": "116.40,39.92",
          "address": "北京市东城区",
          "isHotel": false
        }
      ]''';

      final result = CollectImportService.parseAiJson(json, tId: tId);

      expect(result.length, 2);
      expect(result[0].tId, tId);
      expect(result[0].name, '颐和园');
      expect(result[0].coordinate, '116.27,39.99');
      expect(result[0].address, '北京市海淀区');
      expect(result[0].notes, '著名皇家园林');
      expect(result[0].startTime, DateTime(2024, 6, 1, 9, 0, 0));
      expect(result[0].isHotel, isFalse);

      expect(result[1].name, '故宫');
      expect(result[1].startTime, isNull);
    });

    test('defaults coordinate to "0,0" and address to "" when missing', () {
      const json = '[{"name": "测试地点"}]';
      final result = CollectImportService.parseAiJson(json, tId: tId);
      expect(result[0].coordinate, '0,0');
      expect(result[0].address, '');
      expect(result[0].isHotel, isFalse);
    });

    test('ignores invalid startTime and treats as null', () {
      const json = '[{"name": "X", "startTime": "not-a-date"}]';
      final result = CollectImportService.parseAiJson(json, tId: tId);
      expect(result[0].startTime, isNull);
    });

    test('throws CollectImportException on invalid JSON', () {
      expect(
        () => CollectImportService.parseAiJson('not json', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('throws CollectImportException when root is not an array', () {
      expect(
        () => CollectImportService.parseAiJson('{"name": "x"}', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('returns empty list for empty array', () {
      final result = CollectImportService.parseAiJson('[]', tId: tId);
      expect(result, isEmpty);
    });
  });

  // ─── Dianping mode ────────────────────────────────────────────────────────

  group('CollectImportService.parseDianpingJson', () {
    const dianpingJson = '''
    {
      "records": [
        {
          "collectItemList": [
            {
              "title": "小龙坎",
              "image": "https://img.example.com/1.jpg",
              "favorCore": {"bizUuid": "abc-123"},
              "lng": 104.06,
              "lat": 30.67,
              "address": "成都市锦江区",
              "collectShare": {"content": "超好吃的火锅"}
            }
          ]
        }
      ]
    }
    ''';

    test('parses Dianping JSON into ScheduleFormData list', () {
      final result = CollectImportService.parseDianpingJson(dianpingJson, tId: tId);

      expect(result.length, 1);
      expect(result[0].tId, tId);
      expect(result[0].name, '小龙坎');
      expect(result[0].cover, 'https://img.example.com/1.jpg');
      expect(result[0].dianpingUUID, 'abc-123');
      expect(result[0].coordinate, '104.06,30.67');
      expect(result[0].address, '成都市锦江区');
      expect(result[0].notes, '====大众点评====\n超好吃的火锅');
      expect(result[0].isHotel, isFalse);
      expect(result[0].startTime, isNull);
    });

    test('throws CollectImportException on invalid JSON', () {
      expect(
        () => CollectImportService.parseDianpingJson('bad', tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('throws CollectImportException when collectItemList is missing', () {
      const noItems = '{"records": [{}]}';
      expect(
        () => CollectImportService.parseDianpingJson(noItems, tId: tId),
        throwsA(isA<CollectImportException>()),
      );
    });

    test('handles missing favorCore gracefully (dianpingUUID = null)', () {
      const json = '''
      {"records": [{"collectItemList": [
        {"title": "X", "lng": 1.0, "lat": 2.0, "address": "A",
         "collectShare": {"content": "note"}}
      ]}]}
      ''';
      final result = CollectImportService.parseDianpingJson(json, tId: tId);
      expect(result[0].dianpingUUID, isNull);
    });

    test('notes is null when collectShare is missing', () {
      const json = '''
      {"records": [{"collectItemList": [
        {"title": "X", "lng": 1.0, "lat": 2.0, "address": "A"}
      ]}]}
      ''';
      final result = CollectImportService.parseDianpingJson(json, tId: tId);
      expect(result[0].notes, isNull);
    });
  });
}
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter test test/features/schedule/data/collect_import_service_test.dart -v
```

Expected: FAIL — `CollectImportService` not found

- [ ] **Step 3: 实现 collect_import_service.dart**

创建 `lib/features/schedule/data/collect_import_service.dart`：

```dart
// lib/features/schedule/data/collect_import_service.dart
import 'dart:convert';
import 'schedule_repository.dart';

/// 解析/转换失败时抛出
class CollectImportException implements Exception {
  const CollectImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class CollectImportService {
  // ── AI 采集模式 ─────────────────────────────────────────────────────────────

  /// 解析 AI 生成的 JSON 数组，返回 [ScheduleFormData] 列表。
  ///
  /// 期望格式：
  /// ```json
  /// [{"name": "...", "coordinate": "lng,lat", "address": "...",
  ///   "startTime": "YYYY-MM-DD HH:mm:ss", "notes": "...", "isHotel": false}]
  /// ```
  static List<ScheduleFormData> parseAiJson(String json, {required int tId}) {
    late dynamic decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      throw const CollectImportException('JSON 格式错误，请检查输入内容');
    }
    if (decoded is! List) {
      throw const CollectImportException('JSON 必须是数组（以 [ 开头）');
    }

    return (decoded as List<dynamic>).map((e) {
      final m = e as Map<String, dynamic>;
      final startTimeStr = m['startTime'] as String?;
      final startTime =
          startTimeStr != null ? DateTime.tryParse(startTimeStr) : null;
      return ScheduleFormData(
        tId: tId,
        name: (m['name'] as String?) ?? '',
        coordinate: (m['coordinate'] as String?) ?? '0,0',
        address: (m['address'] as String?) ?? '',
        isHotel: (m['isHotel'] as bool?) ?? false,
        startTime: startTime,
        endTime: null,
        cover: m['cover'] as String?,
        dianpingUUID: m['dianpingUUID'] as String?,
        notes: m['notes'] as String?,
        screenshots: m['screenshots'] as String?,
      );
    }).toList();
  }

  // ── 点评收藏模式 ───────────────────────────────────────────────────────────

  /// 解析大众点评收藏 JSON，返回 [ScheduleFormData] 列表。
  ///
  /// 期望格式：
  /// ```json
  /// {"records": [{"collectItemList": [
  ///   {"title": "...", "image": "...", "favorCore": {"bizUuid": "..."},
  ///    "lng": 0.0, "lat": 0.0, "address": "...",
  ///    "collectShare": {"content": "..."}}
  /// ]}]}
  /// ```
  static List<ScheduleFormData> parseDianpingJson(String json, {required int tId}) {
    late dynamic decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      throw const CollectImportException('JSON 格式错误，请检查输入内容');
    }

    final records = (decoded as Map<String, dynamic>)['records'] as List<dynamic>?;
    final items = records?.firstOrNull != null
        ? (records!.first as Map<String, dynamic>)['collectItemList'] as List<dynamic>?
        : null;

    if (items == null) {
      throw const CollectImportException('未找到 collectItemList，请确认粘贴的是点评收藏 JSON');
    }

    return items.map((e) {
      final m = e as Map<String, dynamic>;
      final favorCore = m['favorCore'] as Map<String, dynamic>?;
      final collectShare = m['collectShare'] as Map<String, dynamic>?;
      final lng = m['lng'];
      final lat = m['lat'];
      final coordinate = '${lng ?? 0},${lat ?? 0}';

      final content = collectShare?['content'] as String?;
      return ScheduleFormData(
        tId: tId,
        name: (m['title'] as String?) ?? '',
        coordinate: coordinate,
        address: (m['address'] as String?) ?? '',
        isHotel: false,
        cover: m['image'] as String?,
        dianpingUUID: favorCore?['bizUuid'] as String?,  // null when favorCore absent
        notes: (content != null && content.isNotEmpty)
            ? '====大众点评====\n$content'
            : null,
      );
    }).toList();
  }
}
```

- [ ] **Step 4: 运行测试（预期通过）**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter test test/features/schedule/data/collect_import_service_test.dart -v
```

Expected: 10 tests passed

- [ ] **Step 5: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze lib/features/schedule/data/collect_import_service.dart
```

Expected: No issues found!

- [ ] **Step 6: Commit**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
git add lib/features/schedule/data/collect_import_service.dart \
        test/features/schedule/data/collect_import_service_test.dart
git commit -m "feat: add CollectImportService for AI and Dianping JSON parsing"
```

---

## Task 2: CollectImportSheet UI

底部面板：模式切换 → JSON 输入框 → 开始导入 → 逐条进度展示。纯展示组件，无需测试，analyze 验证即可。

**Files:**
- Create: `lib/features/schedule/presentation/collect_import_sheet.dart`

- [ ] **Step 1: 实现 collect_import_sheet.dart**

创建 `lib/features/schedule/presentation/collect_import_sheet.dart`：

```dart
// lib/features/schedule/presentation/collect_import_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../data/collect_import_service.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';

enum _ImportMode { ai, dianping }

enum _Phase { input, importing, done }

enum _ItemStatus { pending, loading, success, error }

class _ImportItem {
  _ImportItem({required this.formData});
  final ScheduleFormData formData;
  _ItemStatus status = _ItemStatus.pending;
  String? errorMessage;
}

class CollectImportSheet extends ConsumerStatefulWidget {
  const CollectImportSheet({super.key, required this.travelId});
  final int travelId;

  static Future<void> show(BuildContext context, int travelId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollectImportSheet(travelId: travelId),
    );
  }

  @override
  ConsumerState<CollectImportSheet> createState() => _CollectImportSheetState();
}

class _CollectImportSheetState extends ConsumerState<CollectImportSheet> {
  _ImportMode _mode = _ImportMode.ai;
  _Phase _phase = _Phase.input;
  final _jsonCtrl = TextEditingController();
  String? _parseError;
  List<_ImportItem> _items = [];

  @override
  void dispose() {
    _jsonCtrl.dispose();
    super.dispose();
  }

  Future<void> _startImport() async {
    setState(() => _parseError = null);

    // ── 解析 JSON ────────────────────────────────────────────────────────────
    List<ScheduleFormData> forms;
    try {
      forms = _mode == _ImportMode.ai
          ? CollectImportService.parseAiJson(_jsonCtrl.text.trim(),
              tId: widget.travelId)
          : CollectImportService.parseDianpingJson(_jsonCtrl.text.trim(),
              tId: widget.travelId);
    } on CollectImportException catch (e) {
      setState(() => _parseError = e.message);
      return;
    }

    if (forms.isEmpty) {
      setState(() => _parseError = '未找到任何行程，请检查 JSON 内容');
      return;
    }

    setState(() {
      _items = forms.map((f) => _ImportItem(formData: f)).toList();
      _phase = _Phase.importing;
    });

    // ── 逐条导入 ─────────────────────────────────────────────────────────────
    final repo = ref.read(scheduleRepositoryProvider);
    for (int i = 0; i < _items.length; i++) {
      setState(() => _items[i].status = _ItemStatus.loading);
      try {
        await repo.add(_items[i].formData);
        if (mounted) setState(() => _items[i].status = _ItemStatus.success);
      } catch (e) {
        if (mounted) {
          setState(() {
            _items[i].status = _ItemStatus.error;
            _items[i].errorMessage = e.toString();
          });
        }
      }
    }

    if (mounted) setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: _phase == _Phase.input
                    ? _buildInputPhase()
                    : _buildProgressPhase(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
      child: Row(
        children: [
          Text('批量导入', style: AppTextStyles.appBarTitle),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPhase() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 12, AppSpacing.pageHorizontal, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 模式切换
          SegmentedButton<_ImportMode>(
            segments: const [
              ButtonSegment(
                  value: _ImportMode.ai,
                  label: Text('AI 采集'),
                  icon: Icon(Icons.auto_awesome, size: 16)),
              ButtonSegment(
                  value: _ImportMode.dianping,
                  label: Text('点评收藏'),
                  icon: Icon(Icons.star_outline, size: 16)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) =>
                setState(() => _mode = s.first),
            style: ButtonStyle(
              iconSize: const WidgetStatePropertyAll(16),
            ),
          ),
          const SizedBox(height: 12),
          // ── 说明文字
          Text(
            _mode == _ImportMode.ai
                ? 'AI 采集：粘贴行程 JSON 数组（包含 name / coordinate / address 字段）'
                : '点评收藏：粘贴大众点评导出的完整 JSON（含 records[0].collectItemList）',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          // ── JSON 输入框
          TextField(
            controller: _jsonCtrl,
            maxLines: 10,
            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: '在此粘贴 JSON…',
              filled: true,
              fillColor: const Color(0xFFF5F5F4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.input),
                borderSide: BorderSide.none,
              ),
              errorText: _parseError,
            ),
          ),
          const SizedBox(height: 16),
          // ── 导入按钮
          Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.fab),
            ),
            child: TextButton(
              onPressed: _startImport,
              child: const Text(
                '开始导入',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPhase() {
    final successCount =
        _items.where((i) => i.status == _ItemStatus.success).length;
    final errorCount =
        _items.where((i) => i.status == _ItemStatus.error).length;
    final isRunning = _phase == _Phase.importing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 统计行
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 12),
          child: Row(
            children: [
              Text(
                isRunning ? '导入中…' : '导入完成',
                style: AppTextStyles.cardTitle,
              ),
              const Spacer(),
              Text(
                '✓ $successCount  ✗ $errorCount',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // ── 进度列表
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
                vertical: 8, horizontal: AppSpacing.pageHorizontal),
            itemCount: _items.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, i) {
              final item = _items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    _statusIcon(item.status),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.formData.name,
                              style: AppTextStyles.body,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          if (item.errorMessage != null)
                            Text(item.errorMessage!,
                                style: AppTextStyles.caption.copyWith(
                                    color: Colors.red),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // ── 关闭按钮（仅完成后显示）
        if (_phase == _Phase.done)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 8, AppSpacing.pageHorizontal, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statusIcon(_ItemStatus status) {
    switch (status) {
      case _ItemStatus.pending:
        return const SizedBox(
          width: 20, height: 20,
          child: Icon(Icons.circle_outlined,
              size: 18, color: AppColors.textDisabled),
        );
      case _ItemStatus.loading:
        return const SizedBox(
          width: 20, height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary),
        );
      case _ItemStatus.success:
        return const Icon(Icons.check_circle,
            size: 20, color: AppColors.success);
      case _ItemStatus.error:
        return const Icon(Icons.cancel, size: 20, color: Colors.red);
    }
  }
}
```

- [ ] **Step 2: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze lib/features/schedule/presentation/collect_import_sheet.dart
```

Expected: No issues found!

Fix any lint issues found (common: missing `const`, deprecated API, unused import).

- [ ] **Step 3: Commit**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
git add lib/features/schedule/presentation/collect_import_sheet.dart
git commit -m "feat: add CollectImportSheet with AI and Dianping import modes"
```

---

## Task 3: 接入 TravelDetailScreen

将 AppBar 中批量导入按钮从 SnackBar 占位符替换为真实实现。

**Files:**
- Modify: `lib/features/travel/presentation/travel_detail_screen.dart`

- [ ] **Step 1: 添加 import 并替换 SnackBar**

在 `lib/features/travel/presentation/travel_detail_screen.dart` 中：

1. 在文件顶部 import 列表末尾添加：

```dart
import '../../../features/schedule/presentation/collect_import_sheet.dart';
```

2. 找到以下代码块（批量导入按钮的 `onPressed`）：

```dart
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: '批量导入',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('批量导入 — Plan 5 实现'))),
              ),
```

替换为：

```dart
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: '批量导入',
                onPressed: () =>
                    CollectImportSheet.show(context, widget.travelId),
              ),
```

- [ ] **Step 2: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze lib/features/travel/presentation/travel_detail_screen.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
git add lib/features/travel/presentation/travel_detail_screen.dart
git commit -m "feat: wire CollectImportSheet to TravelDetailScreen bulk import button"
```

---

## Task 4: 全量验证

- [ ] **Step 1: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: flutter test**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter test -v
```

Expected: All tests passed（≥ 73 tests：原 63 + 10 新增）

---

## 完成标准

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — All tests pass（≥ 73 tests）
- [ ] 旅程详情页批量导入按钮可打开 CollectImportSheet
- [ ] 模式切换（AI / 点评）正常工作
- [ ] 粘贴 AI JSON → 解析 → 逐条导入 → 进度展示
- [ ] 粘贴点评 JSON → 解析 → 逐条导入 → 进度展示
- [ ] 解析失败时显示错误提示，不进入导入阶段
- [ ] 每条行程独立显示成功/失败状态
- [ ] 导入完成后显示关闭按钮
