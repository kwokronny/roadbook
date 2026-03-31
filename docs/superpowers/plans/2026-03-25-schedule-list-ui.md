# Schedule List UI Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将行程列表从传统卡片式重设计为时间轴风格，含封面图、导航按钮、快捷时间弹窗与全屏截图查看器。

**Architecture:** 新建 4 个组件（`ScheduleTimelineItem`、`ScheduleNavButton`、`SchedulePhotoViewer`、`ScheduleQuickTimeSheet`），改造 `DaySidebar`（加星期 + 移到右侧）和 `ScheduleListPanel`（切换为时间轴布局）。`ScheduleNotifier` 新增 `quickEditTime()` 实现乐观更新+回滚。

**Tech Stack:** Flutter 3.x, Riverpod 2.x, mocktail, url_launcher, dart:io, intl

---

## 文件清单

| 动作 | 文件 |
|------|------|
| Modify | `packages/roadbook-flutter/pubspec.yaml` |
| Modify | `packages/roadbook-flutter/ios/Runner/Info.plist` |
| Modify | `packages/roadbook-flutter/lib/core/theme.dart` |
| Modify | `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/day_sidebar.dart` |
| Modify | `packages/roadbook-flutter/lib/features/schedule/domain/schedule_provider.dart` |
| Modify | `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_list_panel.dart` |
| Create | `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_timeline_item.dart` |
| Create | `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_nav_button.dart` |
| Create | `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_photo_viewer.dart` |
| Create | `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_quick_time_sheet.dart` |
| Modify | `packages/roadbook-flutter/test/features/schedule/domain/schedule_provider_test.dart` |
| Create | `packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart` |
| Create | `packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_nav_button_test.dart` |
| Create | `packages/roadbook-flutter/test/unit/features/schedule/quick_time_sheet_logic_test.dart` |

---

## Task 1: 添加 url_launcher 依赖 + iOS URL Scheme

**Files:**
- Modify: `packages/roadbook-flutter/pubspec.yaml`
- Modify: `packages/roadbook-flutter/ios/Runner/Info.plist`

- [ ] **Step 1: 在 pubspec.yaml 的 dependencies 中新增 url_launcher**

  打开 `packages/roadbook-flutter/pubspec.yaml`，在 `dependencies:` 块中（`flutter_riverpod` 行下方）添加：
  ```yaml
    url_launcher: ^6.3.0
  ```

- [ ] **Step 2: 安装依赖**

  ```bash
  cd packages/roadbook-flutter && flutter pub get
  ```
  Expected: 输出 `Got dependencies!`，无 conflict。

- [ ] **Step 3: 在 Info.plist 中声明 LSApplicationQueriesSchemes**

  打开 `packages/roadbook-flutter/ios/Runner/Info.plist`，在 `</dict>` 标签前添加：
  ```xml
  <key>LSApplicationQueriesSchemes</key>
  <array>
    <string>iosamap</string>
    <string>amapuri</string>
  </array>
  ```

- [ ] **Step 4: 验证 iOS 编译通过**

  ```bash
  cd packages/roadbook-flutter && flutter build ios --no-codesign --simulator 2>&1 | tail -5
  ```
  Expected: `Build complete.`（或 archive 成功，无新错误）

- [ ] **Step 5: Commit**

  ```bash
  git add packages/roadbook-flutter/pubspec.yaml packages/roadbook-flutter/pubspec.lock packages/roadbook-flutter/ios/Runner/Info.plist
  git commit -m "feat(deps): add url_launcher and declare AMap URL schemes in Info.plist"
  ```

---

## Task 2: 补充设计 Token

**Files:**
- Modify: `packages/roadbook-flutter/lib/core/theme.dart`

- [ ] **Step 1: 在 AppColors 中添加 unplanned 和 unplannedLight**

  打开 `lib/core/theme.dart`，在 `// 住宿色（紫）` 块下方、`// 状态色` 块上方插入：

  ```dart
  // 待规划色（灰）
  static const Color unplanned      = Color(0xFFD4C8BF); // 圆点边框 / 封面轮廓
  static const Color unplannedLight = Color(0xFFEDE8E3); // 封面背景
  ```

- [ ] **Step 2: 运行全部测试确保无 break**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All tests pass。

- [ ] **Step 3: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/core/theme.dart
  git commit -m "feat(theme): add unplanned color tokens"
  ```

---

## Task 3: 升级 DaySidebar（加星期 + 宽度调整）

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/day_sidebar.dart`

- [ ] **Step 1: 写失败的 widget 测试**

  创建 `test/widget/features/schedule/day_sidebar_test.dart`：

  ```dart
  // test/widget/features/schedule/day_sidebar_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:roadbook_flutter/features/schedule/presentation/widgets/day_sidebar.dart';

  void main() {
    final monday = DateTime(2026, 3, 23); // known Monday

    testWidgets('renders weekday label for day 1', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DaySidebar(
            totalDays: 3,
            selectedDay: 1,
            travelStartDate: monday,
            onDaySelected: (_) {},
          ),
        ),
      ));
      expect(find.text('周一'), findsOneWidget);
    });

    testWidgets('renders weekday label for day 2', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DaySidebar(
            totalDays: 3,
            selectedDay: 1,
            travelStartDate: monday,
            onDaySelected: (_) {},
          ),
        ),
      ));
      expect(find.text('周二'), findsOneWidget);
    });

    testWidgets('always renders 待规划 cell', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: DaySidebar(
            totalDays: 2,
            selectedDay: 0,
            travelStartDate: monday,
            onDaySelected: (_) {},
          ),
        ),
      ));
      expect(find.text('待规划'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 2: 运行测试确认失败**

  ```bash
  cd packages/roadbook-flutter && flutter test test/widget/features/schedule/day_sidebar_test.dart
  ```
  Expected: FAIL（`travelStartDate` parameter does not exist yet）

- [ ] **Step 3: 更新 DaySidebar**

  完整替换 `lib/features/schedule/presentation/widgets/day_sidebar.dart`：

  ```dart
  // lib/features/schedule/presentation/widgets/day_sidebar.dart
  import 'package:flutter/material.dart';
  import '../../../../core/theme.dart';

  class DaySidebar extends StatelessWidget {
    const DaySidebar({
      super.key,
      required this.totalDays,
      required this.selectedDay,
      required this.travelStartDate,
      required this.onDaySelected,
    });

    final int totalDays;
    final int selectedDay;
    final DateTime travelStartDate;
    final ValueChanged<int> onDaySelected;

    static const _weekLabels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    String _weekLabel(int day) {
      final date = travelStartDate.add(Duration(days: day - 1));
      return _weekLabels[date.weekday - 1];
    }

    @override
    Widget build(BuildContext context) {
      final days = [for (int d = 1; d <= totalDays; d++) d, 0];

      return SizedBox(
        width: 56,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: days.length,
          itemBuilder: (context, i) {
            final day = days[i];
            final isSelected = day == selectedDay;
            return GestureDetector(
              onTap: () => onDaySelected(day),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                height: 58,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBorder : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: day == 0
                      ? Text(
                          '待规划',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'DAY',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.primary : AppColors.textDisabled,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? AppColors.primary : AppColors.textDisabled,
                                height: 1,
                              ),
                            ),
                            Text(
                              _weekLabel(day),
                              style: TextStyle(
                                fontSize: 8,
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.7)
                                    : AppColors.textDisabled,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      );
    }
  }
  ```

- [ ] **Step 4: 修复 ScheduleListPanel 中传递 travelStartDate**

  打开 `lib/features/schedule/presentation/schedule_list_panel.dart`，将 `DaySidebar(` 调用改为：

  ```dart
  DaySidebar(
    totalDays: _totalDays,
    selectedDay: selectedDay,
    travelStartDate: travel.startDate,
    onDaySelected: (d) =>
        ref.read(selectedDayProvider(travel.id!).notifier).state = d,
  ),
  ```

- [ ] **Step 5: 运行测试**

  ```bash
  cd packages/roadbook-flutter && flutter test test/widget/features/schedule/day_sidebar_test.dart
  ```
  Expected: All pass。

- [ ] **Step 6: 运行全部测试**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All pass。

- [ ] **Step 7: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/widgets/day_sidebar.dart \
          packages/roadbook-flutter/lib/features/schedule/presentation/schedule_list_panel.dart \
          packages/roadbook-flutter/test/widget/features/schedule/day_sidebar_test.dart
  git commit -m "feat(schedule): upgrade DaySidebar with weekday labels and 58px height"
  ```

---

## Task 4: 添加 quickEditTime() 到 ScheduleNotifier

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/schedule/domain/schedule_provider.dart`
- Modify: `packages/roadbook-flutter/test/features/schedule/domain/schedule_provider_test.dart`

- [ ] **Step 1: 写失败的测试**

  在 `test/features/schedule/domain/schedule_provider_test.dart` 中，在最后一个 `test(...)` 块后添加：

  ```dart
  test('quickEditTime optimistically updates then rolls back on error', () async {
    final original = _make(1); // startTime = null
    when(() => mockRepo.list(10)).thenAnswer((_) async => [original]);
    when(() => mockRepo.update(any())).thenThrow('网络错误');

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(scheduleProvider(10).future);

    final newTime = DateTime(2026, 3, 25, 9, 0);
    await expectLater(
      container.read(scheduleProvider(10).notifier).quickEditTime(
        schedule: original,
        travelId: 10,
        newStartTime: newTime,
        newEndTime: null,
      ),
      throwsA(isA<String>()),
    );

    // After rollback, the original schedule is restored
    final items = container.read(scheduleProvider(10)).value!;
    expect(items.first.startTime, isNull);
  });

  test('quickEditTime updates list on success', () async {
    final original = _make(1);
    when(() => mockRepo.list(10)).thenAnswer((_) async => [original]);
    final newTime = DateTime(2026, 3, 25, 9, 0);
    final updated = Schedule(
      id: 1, tId: 10, name: 'Place 1',
      coordinate: '116.4,39.9', address: '北京',
      isHotel: false, startTime: newTime,
    );
    when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(scheduleProvider(10).future);

    await container.read(scheduleProvider(10).notifier).quickEditTime(
      schedule: original,
      travelId: 10,
      newStartTime: newTime,
      newEndTime: null,
    );

    final items = container.read(scheduleProvider(10)).value!;
    expect(items.first.startTime, newTime);
  });
  ```

- [ ] **Step 2: 运行测试确认失败**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/domain/schedule_provider_test.dart
  ```
  Expected: 2 new tests FAIL（`quickEditTime` method does not exist）

- [ ] **Step 3: 在 ScheduleNotifier 中实现 quickEditTime()**

  在 `lib/features/schedule/domain/schedule_provider.dart` 中，在 `clone()` 方法后追加：

  ```dart
  /// 快捷时间修改：乐观更新，失败时回滚。
  /// 调用方负责关闭弹窗，此方法会 throw 错误供调用方显示 SnackBar。
  Future<void> quickEditTime({
    required Schedule schedule,
    required int travelId,
    required DateTime? newStartTime,
    required DateTime? newEndTime,
  }) async {
    final current = state.valueOrNull ?? [];
    final snapshot = List<Schedule>.from(current); // rollback snapshot

    // Optimistic update
    final optimistic = Schedule(
      id: schedule.id,
      tId: schedule.tId,
      name: schedule.name,
      coordinate: schedule.coordinate,
      address: schedule.address,
      cover: schedule.cover,
      dianpingUUID: schedule.dianpingUUID,
      isHotel: schedule.isHotel,
      startTime: newStartTime,
      endTime: newEndTime,
      screenshots: schedule.screenshots,
      notes: schedule.notes,
    );
    state = AsyncData(current.map((s) => s.id == schedule.id ? optimistic : s).toList());

    try {
      final form = ScheduleFormData(
        id: schedule.id,
        tId: travelId,
        name: schedule.name,
        coordinate: schedule.coordinate,
        address: schedule.address,
        isHotel: schedule.isHotel,
        startTime: newStartTime,
        endTime: newEndTime,
        cover: schedule.cover,
        dianpingUUID: schedule.dianpingUUID,
        notes: schedule.notes,
        screenshots: schedule.screenshots,
      );
      final server = await ref.read(scheduleRepositoryProvider).update(form);
      state = AsyncData(
          (state.valueOrNull ?? []).map((s) => s.id == server.id ? server : s).toList());
    } catch (e) {
      state = AsyncData(snapshot); // rollback
      rethrow;
    }
  }
  ```

  注意：`ScheduleFormData` 已在 `schedule_repository.dart` 中定义，需确保 import 正确。检查文件顶部已有 `import '../data/schedule_repository.dart';`。

- [ ] **Step 4: 运行测试**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/domain/schedule_provider_test.dart
  ```
  Expected: All 7 tests pass。

- [ ] **Step 5: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/domain/schedule_provider.dart \
          packages/roadbook-flutter/test/features/schedule/domain/schedule_provider_test.dart
  git commit -m "feat(schedule): add quickEditTime with optimistic update and rollback"
  ```

---

## Task 5: 创建 ScheduleNavButton

**Files:**
- Create: `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_nav_button.dart`
- Create: `packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_nav_button_test.dart`

- [ ] **Step 1: 写失败的测试**

  创建 `test/features/schedule/presentation/widgets/schedule_nav_button_test.dart`：

  ```dart
  // test/features/schedule/presentation/widgets/schedule_nav_button_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_nav_button.dart';

  void main() {
    testWidgets('disabled when coordinate is 0,0', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ScheduleNavButton(
            coordinate: '0,0',
            name: 'Test',
            isHotel: false,
          ),
        ),
      ));
      // Button renders with opacity
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('disabled when coordinate is empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ScheduleNavButton(
            coordinate: '',
            name: 'Test',
            isHotel: false,
          ),
        ),
      ));
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('enabled when coordinate is valid', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ScheduleNavButton(
            coordinate: '116.4,39.9',
            name: '故宫',
            isHotel: false,
          ),
        ),
      ));
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, equals(1.0));
    });

    testWidgets('shows bottom sheet with 5 transport options on tap', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ScheduleNavButton(
            coordinate: '116.4,39.9',
            name: '故宫',
            isHotel: false,
          ),
        ),
      ));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();
      expect(find.text('驾车'), findsOneWidget);
      expect(find.text('打车'), findsOneWidget);
      expect(find.text('公交'), findsOneWidget);
      expect(find.text('步行'), findsOneWidget);
      expect(find.text('骑行'), findsOneWidget);
    });
  }
  ```

- [ ] **Step 2: 运行测试确认失败**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/presentation/widgets/schedule_nav_button_test.dart
  ```
  Expected: FAIL（file does not exist）

- [ ] **Step 3: 创建 ScheduleNavButton**

  创建 `lib/features/schedule/presentation/widgets/schedule_nav_button.dart`：

  ```dart
  // lib/features/schedule/presentation/widgets/schedule_nav_button.dart
  import 'dart:io';
  import 'package:flutter/material.dart';
  import 'package:url_launcher/url_launcher.dart';
  import '../../../../core/theme.dart';

  class ScheduleNavButton extends StatelessWidget {
    const ScheduleNavButton({
      super.key,
      required this.coordinate,
      required this.name,
      required this.isHotel,
    });

    final String coordinate;
    final String name;
    final bool isHotel;

    bool get _isEnabled {
      if (coordinate.isEmpty) return false;
      if (coordinate == '0,0') return false;
      final parts = coordinate.split(',');
      if (parts.length < 2) return false;
      return true;
    }

    Color get _bgColor => isHotel ? AppColors.hotelLight : AppColors.primaryLight;
    Color get _borderColor => isHotel ? AppColors.hotelBorder : AppColors.primaryBorder;
    Color get _iconColor => isHotel ? AppColors.hotel : AppColors.primary;

    String _buildUrl(String mapMode) {
      final parts = coordinate.split(',');
      final lon = parts[0];
      final lat = parts[1];
      final encodedName = Uri.encodeComponent(name);
      final t = {'car': 0, 'taxi': 0, 'bus': 1, 'walk': 2, 'ride': 3}[mapMode] ?? 0;

      if (Platform.isIOS) {
        return 'iosamap://path?sourceApplication=roadbook'
            '&dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
      } else {
        return 'amapuri://route/plan/'
            '?dlat=$lat&dlon=$lon&dname=$encodedName&dev=0&t=$t';
      }
    }

    Future<void> _launch(String mapMode) async {
      final urlStr = _buildUrl(mapMode);
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    void _showModeSheet(BuildContext context) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('导航至 $name', style: AppTextStyles.cardTitle),
                const SizedBox(height: 4),
                Text('选择出行方式', style: AppTextStyles.caption),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ModeCell(icon: '🚗', label: '驾车', onTap: () { Navigator.pop(context); _launch('car'); }),
                    _ModeCell(icon: '🚕', label: '打车', onTap: () { Navigator.pop(context); _launch('taxi'); }),
                    _ModeCell(icon: '🚌', label: '公交', onTap: () { Navigator.pop(context); _launch('bus'); }),
                    _ModeCell(icon: '🚶', label: '步行', onTap: () { Navigator.pop(context); _launch('walk'); }),
                    _ModeCell(icon: '🚲', label: '骑行', onTap: () { Navigator.pop(context); _launch('ride'); }),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Opacity(
        opacity: _isEnabled ? 1.0 : 0.38,
        child: GestureDetector(
          onTap: _isEnabled ? () => _showModeSheet(context) : null,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Center(
              child: Icon(Icons.navigation_rounded, size: 14, color: _iconColor),
            ),
          ),
        ),
      );
    }
  }

  class _ModeCell extends StatelessWidget {
    const _ModeCell({required this.icon, required this.label, required this.onTap});
    final String icon;
    final String label;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      );
    }
  }
  ```

- [ ] **Step 4: 运行测试**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/presentation/widgets/schedule_nav_button_test.dart
  ```
  Expected: All 4 tests pass。

- [ ] **Step 5: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_nav_button.dart \
          packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_nav_button_test.dart
  git commit -m "feat(schedule): add ScheduleNavButton with AMap deep link and transport mode sheet"
  ```

---

## Task 6: 创建 SchedulePhotoViewer

**Files:**
- Create: `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_photo_viewer.dart`

- [ ] **Step 1: 创建 SchedulePhotoViewer**

  创建 `lib/features/schedule/presentation/schedule_photo_viewer.dart`：

  ```dart
  // lib/features/schedule/presentation/schedule_photo_viewer.dart
  import 'package:flutter/material.dart';
  import '../../../core/theme.dart';

  class SchedulePhotoViewer extends StatefulWidget {
    const SchedulePhotoViewer({
      super.key,
      required this.urls,
      required this.scheduleName,
      required this.initialIndex,
    });

    final List<String> urls;
    final String scheduleName;
    final int initialIndex;

    static Future<void> show(
      BuildContext context, {
      required List<String> urls,
      required String scheduleName,
      required int initialIndex,
    }) {
      return showDialog<void>(
        context: context,
        barrierColor: Colors.black,
        barrierDismissible: true,
        builder: (_) => SchedulePhotoViewer(
          urls: urls,
          scheduleName: scheduleName,
          initialIndex: initialIndex,
        ),
      );
    }

    @override
    State<SchedulePhotoViewer> createState() => _SchedulePhotoViewerState();
  }

  class _SchedulePhotoViewerState extends State<SchedulePhotoViewer> {
    late final PageController _pageCtrl;
    late int _current;

    @override
    void initState() {
      super.initState();
      _current = widget.initialIndex;
      _pageCtrl = PageController(initialPage: widget.initialIndex);
    }

    @override
    void dispose() {
      _pageCtrl.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Main PageView
            PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => Center(
                child: Image.network(
                  widget.urls[i],
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white54)),
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),

            // Top bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.scheduleName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${_current + 1} / ${widget.urls.length}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Left/right arrows
            if (widget.urls.length > 1) ...[
              Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowButton(
                    icon: Icons.chevron_left,
                    onTap: _current > 0
                        ? () => _pageCtrl.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut)
                        : null,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowButton(
                    icon: Icons.chevron_right,
                    onTap: _current < widget.urls.length - 1
                        ? () => _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut)
                        : null,
                  ),
                ),
              ),
            ],

            // Bottom filmstrip
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: List.generate(widget.urls.length, (i) {
                        final isActive = i == _current;
                        return GestureDetector(
                          onTap: () => _pageCtrl.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: isActive ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(
                                widget.urls[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const ColoredBox(
                                  color: Colors.white12,
                                  child: Icon(Icons.broken_image_outlined,
                                      color: Colors.white38, size: 14),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _ArrowButton extends StatelessWidget {
    const _ArrowButton({required this.icon, required this.onTap});
    final IconData icon;
    final VoidCallback? onTap;

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: onTap != null ? 1.0 : 0.3,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      );
    }
  }
  ```

- [ ] **Step 2: 运行全部测试**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All pass（此组件暂无独立 widget 测试，依赖集成验证）

- [ ] **Step 3: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/schedule_photo_viewer.dart
  git commit -m "feat(schedule): add SchedulePhotoViewer full-screen photo viewer"
  ```

---

## Task 7: 创建快捷时间弹窗 ScheduleQuickTimeSheet

**Files:**
- Create: `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_quick_time_sheet.dart`
- Create: `packages/roadbook-flutter/test/unit/features/schedule/quick_time_sheet_logic_test.dart`

- [ ] **Step 1: 写失败的状态机单元测试**

  创建 `test/unit/features/schedule/quick_time_sheet_logic_test.dart`：

  ```dart
  // test/unit/features/schedule/quick_time_sheet_logic_test.dart
  import 'package:flutter_test/flutter_test.dart';
  import 'package:roadbook_flutter/features/schedule/presentation/schedule_quick_time_sheet.dart';

  void main() {
    group('HotelHourRangeState', () {
      test('state0: first tap sets checkIn, clears checkOut', () {
        var state = HotelHourRangeState.empty();
        state = state.tap(12);
        expect(state.checkInHour, 12);
        expect(state.checkOutHour, isNull);
        expect(state.phase, HotelHourPhase.awaitingCheckOut);
      });

      test('state1→state2: second tap sets checkOut', () {
        var state = HotelHourRangeState.empty().tap(10);
        state = state.tap(14);
        expect(state.checkInHour, 10);
        expect(state.checkOutHour, 14);
        expect(state.phase, HotelHourPhase.complete);
      });

      test('state1→state2: auto-swaps when checkOut < checkIn', () {
        var state = HotelHourRangeState.empty().tap(14);
        state = state.tap(10);
        expect(state.checkInHour, 10);
        expect(state.checkOutHour, 14);
      });

      test('state2: third tap resets to empty', () {
        var state = HotelHourRangeState.empty().tap(10).tap(14).tap(8);
        expect(state.checkInHour, isNull);
        expect(state.checkOutHour, isNull);
        expect(state.phase, HotelHourPhase.awaitingCheckIn);
      });

      test('isInRange returns true for middle hours', () {
        final state = HotelHourRangeState.empty().tap(10).tap(14);
        expect(state.isInRange(12), isTrue);
        expect(state.isInRange(10), isFalse); // endpoints not "range middle"
        expect(state.isInRange(14), isFalse);
        expect(state.isInRange(9), isFalse);
      });
    });

    group('buildStartTime (regular schedule)', () {
      final travelStart = DateTime(2026, 3, 23); // Day 1

      test('day + hour → correct DateTime', () {
        final result = buildStartTime(
            travelStart: travelStart, selectedDay: 1, selectedHour: 9);
        expect(result, DateTime(2026, 3, 23, 9, 0, 0));
      });

      test('day + no hour → midnight', () {
        final result = buildStartTime(
            travelStart: travelStart, selectedDay: 2, selectedHour: null);
        expect(result, DateTime(2026, 3, 24, 0, 0, 0));
      });

      test('day 0 (待规划) → null', () {
        final result = buildStartTime(
            travelStart: travelStart, selectedDay: 0, selectedHour: 9);
        expect(result, isNull);
      });
    });

    group('buildHotelDateTime', () {
      final travelStart = DateTime(2026, 3, 23);

      test('day + hour → correct DateTime', () {
        final result = buildHotelDateTime(
            travelStart: travelStart, day: 2, hour: 14);
        expect(result, DateTime(2026, 3, 24, 14, 0, 0));
      });

      test('day + no hour → noon default', () {
        final result = buildHotelDateTime(
            travelStart: travelStart, day: 2, hour: null);
        expect(result, DateTime(2026, 3, 24, 12, 0, 0));
      });
    });
  }
  ```

- [ ] **Step 2: 运行测试确认失败**

  ```bash
  cd packages/roadbook-flutter && flutter test test/unit/features/schedule/quick_time_sheet_logic_test.dart
  ```
  Expected: FAIL（types not defined）

- [ ] **Step 3: 创建 ScheduleQuickTimeSheet**

  创建 `lib/features/schedule/presentation/schedule_quick_time_sheet.dart`（以下为完整实现）：

  ```dart
  // lib/features/schedule/presentation/schedule_quick_time_sheet.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../core/theme.dart';
  import '../../../shared/models/schedule.dart';
  import '../../../shared/models/travel.dart';
  import '../../../shared/utils/schedule_day_helper.dart';
  import '../domain/schedule_provider.dart';

  // ─── Pure logic helpers (exported for testing) ────────────────────────────────

  enum HotelHourPhase { awaitingCheckIn, awaitingCheckOut, complete }

  class HotelHourRangeState {
    const HotelHourRangeState({
      required this.checkInHour,
      required this.checkOutHour,
      required this.phase,
    });

    final int? checkInHour;
    final int? checkOutHour;
    final HotelHourPhase phase;

    factory HotelHourRangeState.empty() => const HotelHourRangeState(
          checkInHour: null,
          checkOutHour: null,
          phase: HotelHourPhase.awaitingCheckIn,
        );

    HotelHourRangeState tap(int hour) {
      switch (phase) {
        case HotelHourPhase.awaitingCheckIn:
          return HotelHourRangeState(
            checkInHour: hour,
            checkOutHour: null,
            phase: HotelHourPhase.awaitingCheckOut,
          );
        case HotelHourPhase.awaitingCheckOut:
          final ci = checkInHour!;
          final inH = hour < ci ? hour : ci;
          final outH = hour < ci ? ci : hour;
          return HotelHourRangeState(
            checkInHour: inH,
            checkOutHour: outH,
            phase: HotelHourPhase.complete,
          );
        case HotelHourPhase.complete:
          return HotelHourRangeState.empty();
      }
    }

    bool isInRange(int hour) {
      if (phase != HotelHourPhase.complete) return false;
      return hour > checkInHour! && hour < checkOutHour!;
    }
  }

  /// 普通行程：计算 startTime。selectedDay=0 → null（待规划）
  DateTime? buildStartTime({
    required DateTime travelStart,
    required int selectedDay,
    required int? selectedHour,
  }) {
    if (selectedDay == 0) return null;
    final base = travelStart.add(Duration(days: selectedDay - 1));
    return DateTime(base.year, base.month, base.day, selectedHour ?? 0, 0, 0);
  }

  /// 住宿：计算 startTime 或 endTime。无 hour 时默认正午。
  DateTime buildHotelDateTime({
    required DateTime travelStart,
    required int day,
    required int? hour,
  }) {
    final base = travelStart.add(Duration(days: day - 1));
    return DateTime(base.year, base.month, base.day, hour ?? 12, 0, 0);
  }

  // ─── Sheet entry point ────────────────────────────────────────────────────────

  class ScheduleQuickTimeSheet extends ConsumerStatefulWidget {
    const ScheduleQuickTimeSheet({
      super.key,
      required this.travel,
      required this.schedule,
    });

    final Travel travel;
    final Schedule schedule;

    static Future<void> show(
      BuildContext context, {
      required Travel travel,
      required Schedule schedule,
    }) {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            ScheduleQuickTimeSheet(travel: travel, schedule: schedule),
      );
    }

    @override
    ConsumerState<ScheduleQuickTimeSheet> createState() =>
        _ScheduleQuickTimeSheetState();
  }

  class _ScheduleQuickTimeSheetState
      extends ConsumerState<ScheduleQuickTimeSheet> {
    // ── Regular schedule state
    late int? _selectedDay;
    late int? _selectedHour;

    // ── Hotel state
    late int? _checkInDay;
    late int? _checkOutDay;
    bool _hotelDayIsCheckIn = true; // mirrors _onDayTap phase
    late HotelHourRangeState _hourRange;

    bool _saving = false;

    int get _totalDays =>
        widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;

    @override
    void initState() {
      super.initState();
      final s = widget.schedule;
      final start = widget.travel.startDate;
      if (s.isHotel) {
        _checkInDay = s.startTime != null
            ? s.startTime!.toLocal().difference(start).inDays + 1
            : null;
        _checkOutDay = s.endTime != null
            ? s.endTime!.toLocal().difference(start).inDays + 1
            : null;
        _hotelDayIsCheckIn = true;
        _selectedDay = null;
        _selectedHour = null;
        // Init hour range from existing times
        final inHour = s.startTime?.toLocal().hour;
        final outHour = s.endTime?.toLocal().hour;
        if (inHour != null && outHour != null) {
          _hourRange = HotelHourRangeState(
            checkInHour: inHour,
            checkOutHour: outHour,
            phase: HotelHourPhase.complete,
          );
        } else if (inHour != null) {
          _hourRange = HotelHourRangeState(
            checkInHour: inHour,
            checkOutHour: null,
            phase: HotelHourPhase.awaitingCheckOut,
          );
        } else {
          _hourRange = HotelHourRangeState.empty();
        }
      } else {
        if (s.startTime != null) {
          _selectedDay = s.startTime!.toLocal().difference(start).inDays + 1;
          _selectedHour = s.startTime!.toLocal().hour;
        } else {
          _selectedDay = 0;
          _selectedHour = null;
        }
        _checkInDay = null;
        _checkOutDay = null;
        _hourRange = HotelHourRangeState.empty();
      }
    }

    // ── Hotel day tap (mirrors existing _onDayTap in ScheduleEditSheet) ─────────
    void _onHotelDayTap(int day) {
      if (day == 0) return;
      setState(() {
        if (_hotelDayIsCheckIn) {
          _checkInDay = day;
          _checkOutDay = null;
          _hotelDayIsCheckIn = false;
        } else {
          final ci = _checkInDay!;
          if (day < ci) {
            _checkInDay = day;
            _checkOutDay = ci;
          } else {
            _checkOutDay = day;
          }
          _hotelDayIsCheckIn = true;
        }
      });
    }

    // ── Submit ────────────────────────────────────────────────────────────────────
    Future<void> _submit() async {
      setState(() => _saving = true);
      Navigator.of(context).pop(); // close immediately (optimistic)

      final s = widget.schedule;
      DateTime? newStart, newEnd;

      if (!s.isHotel) {
        newStart = buildStartTime(
          travelStart: widget.travel.startDate,
          selectedDay: _selectedDay ?? 0,
          selectedHour: _selectedHour,
        );
      } else {
        newStart = _checkInDay != null
            ? buildHotelDateTime(
                travelStart: widget.travel.startDate,
                day: _checkInDay!,
                hour: _hourRange.checkInHour,
              )
            : null;
        newEnd = _checkOutDay != null
            ? buildHotelDateTime(
                travelStart: widget.travel.startDate,
                day: _checkOutDay!,
                hour: _hourRange.checkOutHour,
              )
            : null;
      }

      try {
        await ref.read(scheduleProvider(widget.travel.id!).notifier).quickEditTime(
              schedule: s,
              travelId: widget.travel.id!,
              newStartTime: newStart,
              newEndTime: newEnd,
            );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }

    // ── Build ─────────────────────────────────────────────────────────────────────
    @override
    Widget build(BuildContext context) {
      return Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20,
                  AppSpacing.pageHorizontal, 24),
              child: widget.schedule.isHotel
                  ? _buildHotelContent()
                  : _buildRegularContent(),
            ),
          ),
        ),
      );
    }

    // ── Regular content ────────────────────────────────────────────────────────────
    Widget _buildRegularContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: '修改出发时间',
            subtitle: widget.schedule.name,
          ),
          const SizedBox(height: 16),
          Text('出行日', style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _DayScrollRow(
            totalDays: _totalDays,
            selectedDay: _selectedDay,
            isHotel: false,
            checkInDay: null,
            checkOutDay: null,
            onTap: (d) => setState(() => _selectedDay = d),
          ),
          const SizedBox(height: 16),
          Text('出发时间（可选）',
              style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _HourGrid(
            selectedHour: _selectedHour,
            isHotel: false,
            onTap: (h) =>
                setState(() => _selectedHour = h == _selectedHour ? null : h),
          ),
          const SizedBox(height: 20),
          _ConfirmButton(isHotel: false, saving: _saving, onTap: _submit),
        ],
      );
    }

    // ── Hotel content ─────────────────────────────────────────────────────────────
    Widget _buildHotelContent() {
      final nights = (_checkInDay != null && _checkOutDay != null)
          ? _checkOutDay! - _checkInDay!
          : null;
      final nightsLabel = nights == null
          ? null
          : nights == 0
              ? '当日退房'
              : '$nights晚';

      String dayPrompt;
      if (!_hotelDayIsCheckIn && _checkInDay != null) {
        dayPrompt = '点击选择退房日';
      } else if (_checkInDay != null && _checkOutDay != null) {
        dayPrompt = '';
      } else {
        dayPrompt = '点击选择入住日';
      }

      String hourPrompt;
      switch (_hourRange.phase) {
        case HotelHourPhase.awaitingCheckIn:
          hourPrompt = '点击选择入住时间';
          break;
        case HotelHourPhase.awaitingCheckOut:
          hourPrompt = '点击选择退房时间';
          break;
        case HotelHourPhase.complete:
          hourPrompt = '';
          break;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            title: '修改住宿时间',
            subtitle: widget.schedule.name,
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text('住宿周期',
                style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
            const Spacer(),
            if (dayPrompt.isNotEmpty)
              Text(dayPrompt,
                  style: AppTextStyles.micro
                      .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          _DayScrollRow(
            totalDays: _totalDays,
            selectedDay: null,
            isHotel: true,
            checkInDay: _checkInDay,
            checkOutDay: _checkOutDay,
            onTap: _onHotelDayTap,
          ),
          const SizedBox(height: 16),
          Row(children: [
            Text('入退房时间（可选）',
                style: AppTextStyles.micro.copyWith(letterSpacing: 0.5)),
            const Spacer(),
            if (hourPrompt.isNotEmpty)
              Text(hourPrompt,
                  style: AppTextStyles.micro
                      .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          _HourGrid(
            isHotel: true,
            hourRange: _hourRange,
            onTap: (h) => setState(() => _hourRange = _hourRange.tap(h)),
          ),
          if (_checkInDay != null && _checkOutDay != null) ...[
            const SizedBox(height: 12),
            _HotelSummaryBar(
              checkInDay: _checkInDay!,
              checkOutDay: _checkOutDay!,
              checkInHour: _hourRange.checkInHour,
              checkOutHour: _hourRange.checkOutHour,
              nightsLabel: nightsLabel!,
            ),
          ],
          const SizedBox(height: 20),
          _ConfirmButton(isHotel: true, saving: _saving, onTap: _submit),
        ],
      );
    }
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────────────

  class _SheetHeader extends StatelessWidget {
    const _SheetHeader({required this.title, required this.subtitle});
    final String title;
    final String subtitle;

    @override
    Widget build(BuildContext context) {
      return Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.appBarTitle),
          const SizedBox(height: 2),
          Text(subtitle,
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        ]),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.of(context).pop(),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]);
    }
  }

  class _DayScrollRow extends StatelessWidget {
    const _DayScrollRow({
      required this.totalDays,
      required this.selectedDay,
      required this.isHotel,
      required this.checkInDay,
      required this.checkOutDay,
      required this.onTap,
    });

    final int totalDays;
    final int? selectedDay;
    final bool isHotel;
    final int? checkInDay;
    final int? checkOutDay;
    final ValueChanged<int> onTap;

    @override
    Widget build(BuildContext context) {
      final days = [for (int d = 1; d <= totalDays; d++) d, if (!isHotel) 0];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: days.map((day) {
            bool isSelected = false;
            bool isRange = false;
            String? tag;

            if (isHotel) {
              if (day == checkInDay) { isSelected = true; tag = '入住'; }
              else if (day == checkOutDay) { isSelected = true; tag = '退房'; }
              else if (checkInDay != null && checkOutDay != null &&
                  day > checkInDay! && day < checkOutDay!) {
                isRange = true;
              }
            } else {
              isSelected = day == selectedDay;
            }

            final bg = isSelected
                ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
                : isRange
                    ? (isHotel ? AppColors.hotelLight : const Color(0xFFFFF7ED))
                    : const Color(0xFFF5F5F4);
            final border = isSelected
                ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
                : Colors.transparent;
            final textColor = isSelected || isRange
                ? (isHotel ? AppColors.hotel : AppColors.primary)
                : AppColors.textSecondary;

            return GestureDetector(
              onTap: () => onTap(day),
              child: Container(
                margin: const EdgeInsets.only(right: 5),
                width: day == 0 ? 64 : 48,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  border: Border.all(color: border),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: day == 0
                          ? Text('待规划',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: textColor))
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('DAY',
                                    style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                        height: 1.1)),
                                Text('$day',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                        height: 1.1)),
                              ],
                            ),
                    ),
                    if (tag != null)
                      Positioned(
                        bottom: 1,
                        left: 0,
                        right: 0,
                        child: Text(tag,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                color: textColor)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  class _HourGrid extends StatelessWidget {
    const _HourGrid({
      required this.isHotel,
      this.selectedHour,
      this.hourRange,
      required this.onTap,
    });

    final bool isHotel;
    final int? selectedHour;           // regular mode
    final HotelHourRangeState? hourRange; // hotel mode
    final ValueChanged<int> onTap;

    @override
    Widget build(BuildContext context) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1.5,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: 24,
        itemBuilder: (_, h) {
          bool isSelected = false;
          bool isRange = false;

          if (!isHotel) {
            isSelected = h == selectedHour;
          } else {
            final r = hourRange!;
            isSelected = h == r.checkInHour || h == r.checkOutHour;
            isRange = r.isInRange(h);
          }

          final bg = isSelected
              ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
              : isRange
                  ? (isHotel ? AppColors.hotelLight : AppColors.primaryLight)
                  : const Color(0xFFF5F5F4);
          final border = isSelected
              ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
              : isRange
                  ? (isHotel ? AppColors.hotelBorder : AppColors.primaryBorder)
                  : Colors.transparent;
          final textColor = isSelected || isRange
              ? (isHotel ? AppColors.hotel : AppColors.primary)
              : AppColors.textSecondary;

          return GestureDetector(
            onTap: () => onTap(h),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(AppRadius.timeCell),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Text(
                  '$h',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  class _HotelSummaryBar extends StatelessWidget {
    const _HotelSummaryBar({
      required this.checkInDay,
      required this.checkOutDay,
      required this.checkInHour,
      required this.checkOutHour,
      required this.nightsLabel,
    });

    final int checkInDay;
    final int checkOutDay;
    final int? checkInHour;
    final int? checkOutHour;
    final String nightsLabel;

    String _hourStr(int? h) => h != null ? '${h.toString().padLeft(2, '0')}:00' : '--';

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.hotelLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Text('Day$checkInDay 入住 ${_hourStr(checkInHour)}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('→', style: AppTextStyles.caption),
          ),
          Text('Day$checkOutDay 退房 ${_hourStr(checkOutHour)}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.hotel, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('· $nightsLabel', style: AppTextStyles.caption),
        ]),
      );
    }
  }

  class _ConfirmButton extends StatelessWidget {
    const _ConfirmButton(
        {required this.isHotel, required this.saving, required this.onTap});
    final bool isHotel;
    final bool saving;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
      return Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: isHotel
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
        child: TextButton(
          onPressed: saving ? null : onTap,
          child: saving
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('确认修改',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
        ),
      );
    }
  }
  ```

- [ ] **Step 4: 运行状态机单元测试**

  ```bash
  cd packages/roadbook-flutter && flutter test test/unit/features/schedule/quick_time_sheet_logic_test.dart
  ```
  Expected: All 7 tests pass。

- [ ] **Step 5: 运行全部测试**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All pass。

- [ ] **Step 6: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/schedule_quick_time_sheet.dart \
          packages/roadbook-flutter/test/unit/features/schedule/quick_time_sheet_logic_test.dart
  git commit -m "feat(schedule): add ScheduleQuickTimeSheet with hotel range selection and optimistic submit"
  ```

---

## Task 8: 创建 ScheduleTimelineItem

**Files:**
- Create: `packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_timeline_item.dart`
- Create: `packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart`

- [ ] **Step 1: 写失败的 widget 测试**

  创建 `test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart`：

  ```dart
  // test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:roadbook_flutter/features/schedule/presentation/widgets/schedule_timeline_item.dart';
  import 'package:roadbook_flutter/shared/models/schedule.dart';

  Schedule _make({bool isHotel = false, DateTime? start, String? screenshots}) =>
      Schedule(
        id: 1, tId: 1,
        name: 'Test Stop',
        coordinate: '116.4,39.9',
        address: 'Test Address long enough to potentially truncate',
        isHotel: isHotel,
        startTime: start,
        screenshots: screenshots,
      );

  final _travel = DateTime(2026, 3, 23);

  Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

  void main() {
    group('ScheduleTimelineItem time label', () {
      testWidgets('shows formatted time for regular schedule', (tester) async {
        final s = _make(start: DateTime(2026, 3, 23, 9, 30));
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.text('09:30'), findsOneWidget);
      });

      testWidgets('shows 待规划 when startTime is null', (tester) async {
        final s = _make();
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.text('待规划'), findsOneWidget);
      });

      testWidgets('shows 住宿 for hotel schedule', (tester) async {
        final s = _make(isHotel: true);
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.text('住宿'), findsOneWidget);
      });
    });

    group('ScheduleTimelineItem edit icon visibility', () {
      testWidgets('edit icon hidden when canEdit is false', (tester) async {
        final s = _make(start: DateTime(2026, 3, 23, 9, 0));
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.byKey(const Key('editIcon')), findsNothing);
      });

      testWidgets('edit icon shown when canEdit is true', (tester) async {
        // Need a Travel object - use a minimal fake one via callback approach
        final s = _make(start: DateTime(2026, 3, 23, 9, 0));
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: true,
          onEditTimeTap: () {},
        )));
        expect(find.byKey(const Key('editIcon')), findsOneWidget);
      });
    });

    group('ScheduleTimelineItem screenshots', () {
      testWidgets('shows 3 thumbnails for 3 screenshots', (tester) async {
        final s = _make(
            screenshots: 'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg');
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.byKey(const Key('screenshotThumb')), findsNWidgets(3));
        expect(find.textContaining('+'), findsNothing);
      });

      testWidgets('shows 4 thumbs + overflow when >4 screenshots', (tester) async {
        final s = _make(
            screenshots:
                'http://a.com/1.jpg,http://a.com/2.jpg,http://a.com/3.jpg'
                ',http://a.com/4.jpg,http://a.com/5.jpg,http://a.com/6.jpg');
        await tester.pumpWidget(_wrap(ScheduleTimelineItem(
          schedule: s,
          travelStartDate: _travel,
          canEdit: false,
        )));
        expect(find.byKey(const Key('screenshotThumb')), findsNWidgets(4));
        expect(find.text('+2'), findsOneWidget);
      });
    });
  }
  ```

- [ ] **Step 2: 运行测试确认失败**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart
  ```
  Expected: FAIL（file does not exist）

- [ ] **Step 3: 创建 ScheduleTimelineItem**

  创建 `lib/features/schedule/presentation/widgets/schedule_timeline_item.dart`：

  ```dart
  // lib/features/schedule/presentation/widgets/schedule_timeline_item.dart
  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import '../../../../core/theme.dart';
  import '../../../../shared/models/schedule.dart';
  import '../schedule_photo_viewer.dart';

  class ScheduleTimelineItem extends StatelessWidget {
    const ScheduleTimelineItem({
      super.key,
      required this.schedule,
      required this.travelStartDate,
      required this.canEdit,
      this.onEditTimeTap,
      this.onMoreTap,
    });

    final Schedule schedule;
    final DateTime travelStartDate;
    final bool canEdit;
    final VoidCallback? onEditTimeTap;   // triggers ScheduleQuickTimeSheet
    final VoidCallback? onMoreTap;       // opens full ScheduleEditSheet

    static const _maxThumbs = 4;

    String get _timeLabel {
      if (schedule.isHotel) return '住宿';
      if (schedule.startTime == null) return '待规划';
      return DateFormat('HH:mm').format(schedule.startTime!.toLocal());
    }

    Color get _accentColor {
      if (schedule.isHotel) return AppColors.hotel;
      if (schedule.startTime == null) return AppColors.textSecondary;
      return AppColors.primary;
    }

    Color get _coverBorderColor {
      if (schedule.isHotel) return AppColors.hotel;
      if (schedule.startTime == null) return AppColors.unplanned;
      return AppColors.primary;
    }

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image (replaces dot)
            _CoverImage(schedule: schedule),
            const SizedBox(width: 10),
            // ── Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time row
                  _buildTimeRow(context),
                  const SizedBox(height: 3),
                  // Name
                  Text(
                    schedule.name,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Address
                  if (schedule.address.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      schedule.address,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  // Screenshots
                  if (schedule.screenshotList.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _buildScreenshots(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildTimeRow(BuildContext context) {
      return Row(
        children: [
          // Time + edit icon (tappable area)
          GestureDetector(
            onTap: canEdit ? onEditTimeTap : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _timeLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _accentColor,
                    height: 1,
                  ),
                ),
                if (canEdit) ...[
                  const SizedBox(width: 5),
                  Container(
                    key: const Key('editIcon'),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: schedule.isHotel
                          ? AppColors.hotelLight
                          : schedule.startTime == null
                              ? const Color(0xFFF5F5F4)
                              : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: schedule.isHotel
                            ? AppColors.hotelBorder
                            : schedule.startTime == null
                                ? const Color(0xFFE8E0D8)
                                : AppColors.primaryBorder,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 10,
                      color: _accentColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Nav button imported from sibling widget — passed as builder to avoid
          // coupling this widget to url_launcher.
          if (onMoreTap != null)
            GestureDetector(
              onTap: onMoreTap,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: schedule.isHotel
                      ? AppColors.hotelLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: schedule.isHotel
                        ? AppColors.hotelBorder
                        : AppColors.primaryBorder,
                  ),
                ),
                child: Icon(Icons.more_horiz,
                    size: 14, color: _accentColor),
              ),
            ),
        ],
      );
    }

    Widget _buildScreenshots(BuildContext context) {
      final urls = schedule.screenshotList;
      final visible = urls.take(_maxThumbs).toList();
      final overflow = urls.length - _maxThumbs;

      return Row(
        children: [
          for (int i = 0; i < visible.length; i++) ...[
            GestureDetector(
              key: const Key('screenshotThumb'),
              onTap: () => SchedulePhotoViewer.show(
                context,
                urls: urls,
                scheduleName: schedule.name,
                initialIndex: i,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  visible[i],
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: AppColors.border,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 14, color: AppColors.textDisabled),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (overflow > 0)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('+$overflow',
                    style: AppTextStyles.micro
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      );
    }
  }

  // ─── Cover Image ──────────────────────────────────────────────────────────────

  class _CoverImage extends StatelessWidget {
    const _CoverImage({required this.schedule});
    final Schedule schedule;

    Color get _borderColor {
      if (schedule.isHotel) return AppColors.hotel;
      if (schedule.startTime == null) return AppColors.unplanned;
      return AppColors.primary;
    }

    Color get _defaultBg {
      if (schedule.isHotel) return AppColors.hotelLight;
      if (schedule.startTime == null) return AppColors.unplannedLight;
      return const Color(0xFFFEE2C8);
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor, width: 2),
          color: _defaultBg,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: schedule.cover != null && schedule.cover!.isNotEmpty
              ? Image.network(
                  schedule.cover!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _DefaultIcon(schedule: schedule),
                )
              : _DefaultIcon(schedule: schedule),
        ),
      );
    }
  }

  class _DefaultIcon extends StatelessWidget {
    const _DefaultIcon({required this.schedule});
    final Schedule schedule;

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Text(
          schedule.isHotel ? '🏨' : '📍',
          style: const TextStyle(fontSize: 20),
        ),
      );
    }
  }
  ```

- [ ] **Step 4: 运行测试**

  ```bash
  cd packages/roadbook-flutter && flutter test test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart
  ```
  Expected: All 7 tests pass。

- [ ] **Step 5: 运行全部测试**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All pass。

- [ ] **Step 6: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_timeline_item.dart \
          packages/roadbook-flutter/test/features/schedule/presentation/widgets/schedule_timeline_item_test.dart
  git commit -m "feat(schedule): add ScheduleTimelineItem with cover image, edit icon, screenshot thumbnails"
  ```

---

## Task 9: 重构 ScheduleListPanel（接入所有新组件）

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/schedule/presentation/schedule_list_panel.dart`

- [ ] **Step 1: 完整替换 ScheduleListPanel**

  完整替换 `lib/features/schedule/presentation/schedule_list_panel.dart`：

  ```dart
  // lib/features/schedule/presentation/schedule_list_panel.dart
  // NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../../../core/theme.dart';
  import '../../../shared/models/travel.dart';
  import '../../../shared/models/schedule.dart';
  import '../../../shared/models/user_travel.dart';
  import '../../../shared/utils/schedule_day_helper.dart';
  import '../domain/schedule_provider.dart';
  import 'widgets/day_sidebar.dart';
  import 'widgets/schedule_timeline_item.dart';
  import 'widgets/schedule_nav_button.dart';
  import 'schedule_edit_sheet.dart';
  import 'schedule_quick_time_sheet.dart';

  class ScheduleListPanel extends ConsumerWidget {
    const ScheduleListPanel({
      super.key,
      required this.travel,
      required this.perm,
    });

    final Travel travel;
    final RoleType perm;

    int get _totalDays =>
        travel.endDate.difference(travel.startDate).inDays + 1;

    bool get _canEdit => perm == RoleType.manage || perm == RoleType.edit;

    List<Schedule> _schedulesForDay(int day, List<Schedule> all) =>
        schedulesForDay(day, all, travel.startDate);

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final listAsync = ref.watch(scheduleProvider(travel.id!));
      final selectedDay = ref.watch(selectedDayProvider(travel.id!));

      return Row(
        children: [
          // ── 左侧：时间轴列表
          Expanded(
            child: listAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e.toString(), style: AppTextStyles.caption),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(scheduleProvider(travel.id!)),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final items = _schedulesForDay(selectedDay, all);
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      selectedDay == 0 ? '暂无待规划行程' : '第 $selectedDay 天暂无行程',
                      style: AppTextStyles.caption,
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async =>
                      ref.invalidate(scheduleProvider(travel.id!)),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal, 14,
                        AppSpacing.pageHorizontal, 14),
                    itemCount: items.length + 1, // +1 for timeline line trick
                    itemBuilder: (context, i) {
                      if (i == items.length) return const SizedBox(height: 16);
                      final s = items[i];
                      return Stack(
                        children: [
                          // Vertical timeline line
                          Positioned(
                            left: 19, // center of 40px cover image
                            top: i == 0 ? 20 : 0,
                            bottom: i == items.length - 1 ? 20 : 0,
                            child: Container(
                              width: 2,
                              color: AppColors.border,
                            ),
                          ),
                          ScheduleTimelineItem(
                            schedule: s,
                            travelStartDate: travel.startDate,
                            canEdit: _canEdit,
                            onEditTimeTap: _canEdit
                                ? () => ScheduleQuickTimeSheet.show(
                                      context,
                                      travel: travel,
                                      schedule: s,
                                    )
                                : null,
                            onMoreTap: () => _showMoreMenu(context, ref, s),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // ── 右侧：天数栏（右侧）
          Container(
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: DaySidebar(
              totalDays: _totalDays,
              selectedDay: selectedDay,
              travelStartDate: travel.startDate,
              onDaySelected: (d) =>
                  ref.read(selectedDayProvider(travel.id!).notifier).state = d,
            ),
          ),
        ],
      );
    }

    void _showMoreMenu(BuildContext context, WidgetRef ref, Schedule s) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('编辑'),
                onTap: () {
                  Navigator.pop(context);
                  ScheduleEditSheet.show(context,
                      travel: travel, schedule: s,
                      initialDay: selectedDayProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('克隆'),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(scheduleProvider(travel.id!).notifier).clone(s.id!);
                },
              ),
              // Nav button row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(children: [
                  const Expanded(child: SizedBox()),
                  ScheduleNavButton(
                    coordinate: s.coordinate,
                    name: s.name,
                    isHotel: s.isHotel,
                  ),
                ]),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref, s);
                },
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _confirmDelete(
        BuildContext context, WidgetRef ref, Schedule s) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('删除行程'),
          content: Text('确定删除「${s.name}」？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('删除',
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      );
      if (confirmed == true) {
        await ref
            .read(scheduleProvider(travel.id!).notifier)
            .remove(s.id!);
      }
    }
  }
  ```

  **注意**：`ScheduleEditSheet.show()` 中 `initialDay` 参数在这里传入 `selectedDayProvider` 是错误的，需修正为从 ref 读取的实际值。由于 `_showMoreMenu` 不是 Widget 方法没有 ref 传递，将其改为通过 closure 捕获：

  将 `_showMoreMenu` 调用改为在 `build` 方法内 inline，以能访问 `selectedDay` 变量：

  在 `build` 方法中，将 `onMoreTap: () => _showMoreMenu(context, ref, s)` 改为：
  ```dart
  onMoreTap: () => _showMoreMenu(context, ref, s, selectedDay),
  ```

  并将方法签名改为：
  ```dart
  void _showMoreMenu(BuildContext context, WidgetRef ref, Schedule s, int currentDay) {
  ```

  在 `ScheduleEditSheet.show` 调用中改为：
  ```dart
  ScheduleEditSheet.show(context,
      travel: travel,
      schedule: s,
      initialDay: currentDay);
  ```

- [ ] **Step 2: 运行全部测试**

  ```bash
  cd packages/roadbook-flutter && flutter test
  ```
  Expected: All pass。如有编译错误根据错误信息修正。

- [ ] **Step 3: 手动验证 UI（热重载）**

  ```bash
  cd packages/roadbook-flutter && flutter run
  ```

  验证清单：
  - [ ] 进入行程详情，列表视图中天数栏在右侧显示，有星期信息
  - [ ] 每个行程站点左侧显示封面图（或默认图标），竖线穿过封面图中心
  - [ ] 时间文字右侧有编辑图标（有编辑权限时）
  - [ ] 点击时间行弹出 `ScheduleQuickTimeSheet`，普通行程可选日和小时，住宿可选范围
  - [ ] 住宿小时宫格：首次点击=入住时间，再次点击=退房时间，第三次清空
  - [ ] 点击更多图标显示 BottomSheet，含导航按钮（弹出 5 种交通方式）
  - [ ] 截图缩略图（36×36）点击后全屏查看器，左右切换，底部胶片条

- [ ] **Step 4: Commit**

  ```bash
  git add packages/roadbook-flutter/lib/features/schedule/presentation/schedule_list_panel.dart
  git commit -m "feat(schedule): refactor ScheduleListPanel to timeline layout with right sidebar"
  ```

---

## Task 10: 最终收尾

- [ ] **Step 1: 运行完整测试套件**

  ```bash
  cd packages/roadbook-flutter && flutter test --coverage
  ```
  Expected: All pass。

- [ ] **Step 2: 删除旧的 ScheduleItem（如已无引用）**

  检查是否还有文件引用 `schedule_item.dart`：
  ```bash
  grep -r "schedule_item" packages/roadbook-flutter/lib/
  ```
  若无引用，删除：
  ```bash
  rm packages/roadbook-flutter/lib/features/schedule/presentation/widgets/schedule_item.dart
  ```
  同步更新 `test/features/schedule/presentation/widgets/schedule_item_test.dart`（重命名为 `schedule_timeline_item_test.dart` 或删除旧测试）。

- [ ] **Step 3: Final commit**

  ```bash
  git add -A
  git commit -m "feat(schedule): complete timeline UI redesign — remove legacy ScheduleItem"
  ```
