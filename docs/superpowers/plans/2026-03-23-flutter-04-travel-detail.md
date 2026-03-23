# Roadbook Flutter — Plan 4: Travel Detail Screen

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现旅程详情页，包含行程 Tab（左侧天数栏 + 右侧行程列表 + 行程编辑面板）和协作者管理面板，地图 Tab 为占位符留待 Plan 5。

**Architecture:** Feature-first。`features/schedule/` 新增行程功能模块（data/domain/presentation）；`features/travel/` 扩展 TravelRepository 和 TravelDetailProvider；详情页以 DefaultTabController 承载 Map 占位和 Schedule 两个 Tab。

**Tech Stack:** Flutter (stable), flutter_riverpod ^2.5 (manual, non-codegen), go_router ^14, dio ^5.4, mocktail ^1.0, intl ^0.19

**Spec:** `docs/superpowers/specs/2026-03-20-roadbook-flutter-design.md` §5.3, §5.4, §9

> **截图上传**：Plan 4 仅展示已有截图数量，上传功能留待 Plan 6 实现。
> **地图 Tab**：仅展示占位符，完整地图实现在 Plan 5。
> **新增行程坐标**：手动新增时默认 `"0,0"`，地图搜索后填充真实坐标在 Plan 5。

---

## File Map

### 修改文件
- `lib/features/travel/data/travel_repository.dart` — 新增 `detail()` / `setRole()` / `invite()`
- `test/features/travel/data/travel_repository_test.dart` — 追加 3 个测试
- `lib/core/router.dart` — 将 `/travel/:id` 从占位符切换为 `TravelDetailScreen`

### 新建文件
```
lib/
├── features/
│   ├── schedule/
│   │   ├── data/
│   │   │   └── schedule_repository.dart     # list/add/update/remove/clone
│   │   ├── domain/
│   │   │   └── schedule_provider.dart       # ScheduleNotifier + selectedDayProvider
│   │   └── presentation/
│   │       ├── schedule_list_panel.dart      # 行程 Tab 主面板
│   │       ├── schedule_edit_sheet.dart      # 新建/编辑行程底部面板
│   │       └── widgets/
│   │           ├── day_sidebar.dart          # 左侧天数栏
│   │           └── schedule_item.dart        # 行程卡片
│   └── travel/
│       ├── domain/
│       │   └── travel_detail_provider.dart   # TravelDetailNotifier + travelPermProvider
│       └── presentation/
│           ├── travel_detail_screen.dart     # AppBar + TabBar 主框架
│           └── widgets/
│               └── collaborator_sheet.dart   # 协作者管理底部面板
test/
├── features/
│   ├── schedule/
│   │   ├── data/
│   │   │   └── schedule_repository_test.dart
│   │   └── domain/
│   │       └── schedule_provider_test.dart
│   └── travel/
│       └── domain/
│           └── travel_detail_provider_test.dart
```

---

## Task 1: 扩展 TravelRepository — detail / setRole / invite

**Files:**
- Modify: `lib/features/travel/data/travel_repository.dart`
- Modify: `test/features/travel/data/travel_repository_test.dart`

- [ ] **Step 1: 在 travel_repository_test.dart 末尾追加 3 个测试（先写）**

在现有 `group('TravelRepository', ...)` 内末尾追加（在最后一个 `test` 之后，`});` 之前）：

```dart
    test('detail returns Travel', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 5);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'id': 5,
              'name': 'Detail Trip',
              'startDate': '2024-06-01',
              'endDate': '2024-06-05',
              'public': false,
              'city': '北京',
              'Users': [],
            },
          ));
        },
      ));

      final travel = await repo.detail(5);
      expect(travel.id, 5);
      expect(travel.name, 'Detail Trip');
    });

    test('setRole sends correct payload', () async {
      Map<String, dynamic>? captured;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options.data as Map<String, dynamic>;
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: null));
        },
      ));

      await repo.setRole(10, userId: 3, role: 'edit');
      expect(captured?['id'], 10);
      expect(captured?['uid'], 3);
      expect(captured?['role'], 'edit');
    });

    test('invite returns token string', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: 'tok.jwt.abc'));
        },
      ));

      final token = await repo.invite(10);
      expect(token, 'tok.jwt.abc');
    });
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter
flutter test test/features/travel/data/travel_repository_test.dart -v
```

Expected: 新增的 3 个 FAIL（method not found）

- [ ] **Step 3: 在 travel_repository.dart 末尾追加三个方法**

在 `remove()` 方法后追加：

```dart
  Future<Travel> detail(int id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelDetail,
        data: {'id': id},
      );
      return Travel.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取旅程详情失败';
    }
  }

  Future<void> setRole(int travelId, {required int userId, required String role}) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.travelSetRole,
        data: {'id': travelId, 'uid': userId, 'role': role},
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '设置权限失败';
    }
  }

  Future<String> invite(int travelId) async {
    try {
      final res = await _dio.post<String>(
        ApiEndpoints.travelInvite,
        data: {'id': travelId},
      );
      return res.data!;
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '生成邀请链接失败';
    }
  }
```

- [ ] **Step 4: 运行测试（预期通过）**

```bash
flutter test test/features/travel/data/travel_repository_test.dart -v
```

Expected: 10 tests passed (7 existing + 3 new)

- [ ] **Step 5: Commit**

```bash
git add lib/features/travel/data/travel_repository.dart \
        test/features/travel/data/travel_repository_test.dart
git commit -m "feat: add TravelRepository.detail/setRole/invite"
```

---

## Task 2: ScheduleRepository

封装行程 CRUD。`ScheduleFormData` 放在同一文件。

**Files:**
- Create: `lib/features/schedule/data/schedule_repository.dart`
- Create: `test/features/schedule/data/schedule_repository_test.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/lib/features/schedule/data
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/test/features/schedule/data
```

- [ ] **Step 2: 写测试（先写）**

```dart
// test/features/schedule/data/schedule_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/schedule/data/schedule_repository.dart';

Map<String, dynamic> _schedJson({int id = 1}) => {
  'id': id,
  'tId': 10,
  'name': 'Place $id',
  'coordinate': '116.4,39.9',
  'address': '北京',
  'cover': null,
  'dianpingUUID': null,
  'isHotel': false,
  'startTime': '2024-06-01T09:00:00.000Z',
  'endTime': null,
  'screenshots': null,
  'notes': null,
};

void main() {
  group('ScheduleRepository', () {
    late Dio dio;
    late ScheduleRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = ScheduleRepository(dio);
    });

    test('list returns parsed schedule list', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 10);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: [_schedJson(id: 1), _schedJson(id: 2)],
          ));
        },
      ));

      final result = await repo.list(10);
      expect(result.length, 2);
      expect(result.first.id, 1);
    });

    test('add sends tId and returns saved schedule', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map;
          expect(body['tId'], 10);
          expect(body['name'], 'New Place');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 99),
          ));
        },
      ));

      final form = ScheduleFormData(
        tId: 10,
        name: 'New Place',
        coordinate: '116.4,39.9',
        address: '北京',
        isHotel: false,
      );
      final s = await repo.add(form);
      expect(s.id, 99);
    });

    test('update sends id and returns updated schedule', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 5),
          ));
        },
      ));

      final form = ScheduleFormData(
        id: 5,
        tId: 10,
        name: 'Updated',
        coordinate: '116.4,39.9',
        address: '北京',
        isHotel: false,
      );
      await repo.update(form);
      expect(capturedId, 5);
    });

    test('remove sends id', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: null));
        },
      ));

      await repo.remove(42);
      expect(capturedId, 42);
    });

    test('clone sends id and returns cloned schedule', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          expect((options.data as Map)['id'], 7);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _schedJson(id: 88),
          ));
        },
      ));

      final s = await repo.clone(7);
      expect(s.id, 88);
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/features/schedule/data/schedule_repository_test.dart -v
```

Expected: FAIL — `ScheduleRepository` not found

- [ ] **Step 4: 实现 schedule_repository.dart**

```dart
// lib/features/schedule/data/schedule_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/schedule.dart';

class ScheduleFormData {
  const ScheduleFormData({
    this.id,
    required this.tId,
    required this.name,
    required this.coordinate,
    required this.address,
    required this.isHotel,
    this.startTime,
    this.endTime,
    this.cover,
    this.dianpingUUID,
    this.notes,
    this.screenshots,
  });

  final int? id;
  final int tId;
  final String name;
  final String coordinate;
  final String address;
  final bool isHotel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? cover;
  final String? dianpingUUID;
  final String? notes;
  final String? screenshots;

  Map<String, dynamic> toAddJson() => {
        'tId': tId,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'isHotel': isHotel,
        if (startTime != null) 'startTime': startTime!.toIso8601String(),
        if (endTime != null) 'endTime': endTime!.toIso8601String(),
        if (cover != null) 'cover': cover,
        if (dianpingUUID != null) 'dianpingUUID': dianpingUUID,
        if (notes != null) 'notes': notes,
        if (screenshots != null) 'screenshots': screenshots,
      };

  Map<String, dynamic> toUpdateJson() => {
        'id': id!,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'isHotel': isHotel,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'cover': cover,
        'dianpingUUID': dianpingUUID,
        'notes': notes,
        'screenshots': screenshots,
      };
}

class ScheduleRepository {
  ScheduleRepository(this._dio);
  final Dio _dio;

  Future<List<Schedule>> list(int travelId) async {
    try {
      final res = await _dio.post<List<dynamic>>(
        ApiEndpoints.scheduleList,
        data: {'id': travelId},
      );
      return (res.data ?? [])
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取行程失败';
    }
  }

  Future<Schedule> add(ScheduleFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleAdd,
        data: form.toAddJson(),
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '添加行程失败';
    }
  }

  Future<Schedule> update(ScheduleFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleUpdate,
        data: form.toUpdateJson(),
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '更新行程失败';
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.scheduleRemove, data: {'id': id});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '删除行程失败';
    }
  }

  Future<Schedule> clone(int id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.scheduleClone,
        data: {'id': id},
      );
      return Schedule.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '克隆行程失败';
    }
  }
}
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/features/schedule/data/schedule_repository_test.dart -v
```

Expected: 5 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/features/schedule/data/schedule_repository.dart \
        test/features/schedule/data/schedule_repository_test.dart
git commit -m "feat: add ScheduleRepository with list/add/update/remove/clone"
```

---

## Task 3: TravelDetailProvider + travelPermProvider

**Files:**
- Create: `lib/features/travel/domain/travel_detail_provider.dart`
- Create: `test/features/travel/domain/travel_detail_provider_test.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/test/features/travel/domain
```

- [ ] **Step 2: 写测试（先写）**

```dart
// test/features/travel/domain/travel_detail_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_detail_provider.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/shared/models/user_travel.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';

class MockTravelRepository extends Mock implements TravelRepository {}

class _FakeAuthNotifier extends AsyncNotifier<AuthState> {
  _FakeAuthNotifier(this._userId);
  final int _userId;

  @override
  Future<AuthState> build() async => AuthState(
        token: 'tok',
        user: User(id: _userId, username: 'user$_userId', name: 'User'),
      );
}

Travel _makeTravel({List<UserWithRole> collaborators = const []}) => Travel(
      id: 1,
      name: 'Trip',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 5),
      isPublic: false,
      cities: [],
      collaborators: collaborators,
      schedules: [],
    );

void main() {
  group('TravelDetailNotifier', () {
    late MockTravelRepository mockRepo;

    setUp(() {
      mockRepo = MockTravelRepository();
    });

    ProviderContainer makeContainer({int userId = 1}) => ProviderContainer(
          overrides: [
            travelRepositoryProvider.overrideWithValue(mockRepo),
            authStateProvider.overrideWith(() => _FakeAuthNotifier(userId)),
          ],
        );

    test('build loads travel detail', () async {
      final travel = _makeTravel();
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(travelDetailProvider(1).future);
      expect(result.id, 1);
      expect(result.name, 'Trip');
    });

    test('travelPermProvider returns manage when user has manage role', () async {
      final travel = _makeTravel(collaborators: [
        UserWithRole(
          user: User(id: 1, username: 'alice', name: 'Alice'),
          role: RoleType.manage,
        ),
      ]);
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer(userId: 1);
      addTearDown(container.dispose);

      await container.read(travelDetailProvider(1).future);
      final perm = container.read(travelPermProvider(1));
      expect(perm, RoleType.manage);
    });

    test('travelPermProvider returns view when user not in collaborators', () async {
      final travel = _makeTravel(collaborators: []);
      when(() => mockRepo.detail(1)).thenAnswer((_) async => travel);

      final container = makeContainer(userId: 99);
      addTearDown(container.dispose);

      await container.read(travelDetailProvider(1).future);
      final perm = container.read(travelPermProvider(1));
      expect(perm, RoleType.view);
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/features/travel/domain/travel_detail_provider_test.dart -v
```

Expected: FAIL — `travelDetailProvider` not found

- [ ] **Step 4: 实现 travel_detail_provider.dart**

```dart
// lib/features/travel/domain/travel_detail_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/travel_repository.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/user_travel.dart';
import '../../../shared/providers/auth_state_provider.dart';

// ─── Detail Provider ──────────────────────────────────────────────────────────

final travelDetailProvider = AsyncNotifierProvider.autoDispose
    .family<TravelDetailNotifier, Travel, int>(TravelDetailNotifier.new);

class TravelDetailNotifier extends AutoDisposeFamilyAsyncNotifier<Travel, int> {
  @override
  Future<Travel> build(int arg) async {
    return ref.read(travelRepositoryProvider).detail(arg);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(travelRepositoryProvider).detail(arg));
  }

  Future<void> updateCollab(int userId, String role) async {
    await ref.read(travelRepositoryProvider).setRole(arg, userId: userId, role: role);
    await reload();
  }

  Future<void> removeCollab(int userId) async {
    await ref.read(travelRepositoryProvider).setRole(arg, userId: userId, role: 'delete');
    await reload();
  }
}

// ─── Permission Provider ──────────────────────────────────────────────────────

/// 当前登录用户对指定旅程的权限（manage / edit / view）
final travelPermProvider = Provider.autoDispose.family<RoleType, int>((ref, travelId) {
  final authUser = ref.watch(authStateProvider).valueOrNull?.user;
  final travel = ref.watch(travelDetailProvider(travelId)).valueOrNull;
  if (authUser == null || travel == null) return RoleType.view;
  final match = travel.collaborators.where((c) => c.user.id == authUser.id);
  return match.isEmpty ? RoleType.view : match.first.role;
});
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/features/travel/domain/travel_detail_provider_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/features/travel/domain/travel_detail_provider.dart \
        test/features/travel/domain/travel_detail_provider_test.dart
git commit -m "feat: add TravelDetailProvider and travelPermProvider"
```

---

## Task 4: ScheduleProvider + selectedDayProvider

管理行程列表状态；`selectedDayProvider` 跟踪当前天（0 = 待规划，1-N = 第 N 天）。

**Files:**
- Create: `lib/features/schedule/domain/schedule_provider.dart`
- Create: `test/features/schedule/domain/schedule_provider_test.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/lib/features/schedule/domain
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/test/features/schedule/domain
```

- [ ] **Step 2: 写测试（先写）**

```dart
// test/features/schedule/domain/schedule_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/schedule/data/schedule_repository.dart';
import 'package:roadbook_flutter/features/schedule/domain/schedule_provider.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

class MockScheduleRepository extends Mock implements ScheduleRepository {}

Schedule _make(int id) => Schedule(
      id: id,
      tId: 10,
      name: 'Place $id',
      coordinate: '116.4,39.9',
      address: '北京',
      isHotel: false,
    );

void main() {
  group('ScheduleNotifier', () {
    late MockScheduleRepository mockRepo;

    setUp(() {
      mockRepo = MockScheduleRepository();
      registerFallbackValue(ScheduleFormData(
        tId: 10,
        name: 'x',
        coordinate: '0,0',
        address: '',
        isHotel: false,
      ));
    });

    ProviderContainer makeContainer() => ProviderContainer(overrides: [
          scheduleRepositoryProvider.overrideWithValue(mockRepo),
        ]);

    test('build loads schedule list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);

      final container = makeContainer();
      addTearDown(container.dispose);

      final items = await container.read(scheduleProvider(10).future);
      expect(items.length, 2);
    });

    test('add appends schedule to list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1)]);
      when(() => mockRepo.add(any())).thenAnswer((_) async => _make(99));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).add(ScheduleFormData(
            tId: 10, name: 'New', coordinate: '0,0', address: '', isHotel: false));

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.last.id, 99);
    });

    test('update replaces schedule in list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);
      final updated = Schedule(
          id: 1, tId: 10, name: 'Updated', coordinate: '0,0', address: '', isHotel: false);
      when(() => mockRepo.update(any())).thenAnswer((_) async => updated);

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).update(ScheduleFormData(
            id: 1, tId: 10, name: 'Updated', coordinate: '0,0', address: '', isHotel: false));

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.first.name, 'Updated');
    });

    test('remove removes schedule from list', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1), _make(2)]);
      when(() => mockRepo.remove(1)).thenAnswer((_) async {});

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).remove(1);

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 1);
      expect(items.first.id, 2);
    });

    test('clone appends cloned schedule', () async {
      when(() => mockRepo.list(10)).thenAnswer((_) async => [_make(1)]);
      when(() => mockRepo.clone(1)).thenAnswer((_) async => _make(55));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(scheduleProvider(10).future);
      await container.read(scheduleProvider(10).notifier).clone(1);

      final items = container.read(scheduleProvider(10)).value!;
      expect(items.length, 2);
      expect(items.last.id, 55);
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/features/schedule/domain/schedule_provider_test.dart -v
```

Expected: FAIL — `scheduleProvider` not found

- [ ] **Step 4: 实现 schedule_provider.dart**

```dart
// lib/features/schedule/domain/schedule_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/providers/dio_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(dioProvider));
});

// ─── Schedule List Provider (family by travelId) ─────────────────────────────

final scheduleProvider = AsyncNotifierProvider.autoDispose
    .family<ScheduleNotifier, List<Schedule>, int>(ScheduleNotifier.new);

class ScheduleNotifier extends AutoDisposeFamilyAsyncNotifier<List<Schedule>, int> {
  @override
  Future<List<Schedule>> build(int arg) async {
    return ref.read(scheduleRepositoryProvider).list(arg);
  }

  Future<void> add(ScheduleFormData form) async {
    final newSchedule = await ref.read(scheduleRepositoryProvider).add(form);
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, newSchedule]);
  }

  Future<void> update(ScheduleFormData form) async {
    final updated = await ref.read(scheduleRepositoryProvider).update(form);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((s) => s.id == updated.id ? updated : s).toList());
  }

  Future<void> remove(int id) async {
    await ref.read(scheduleRepositoryProvider).remove(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.where((s) => s.id != id).toList());
  }

  Future<void> clone(int id) async {
    final cloned = await ref.read(scheduleRepositoryProvider).clone(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData([...current, cloned]);
  }
}

// ─── Selected Day Provider (family by travelId) ───────────────────────────────

/// 0 = 待规划，1-N = 第 N 天
final selectedDayProvider =
    StateProvider.autoDispose.family<int, int>((ref, travelId) => 1);
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/features/schedule/domain/schedule_provider_test.dart -v
```

Expected: 5 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/features/schedule/domain/schedule_provider.dart \
        test/features/schedule/domain/schedule_provider_test.dart
git commit -m "feat: add ScheduleProvider and selectedDayProvider"
```

---

## Task 5: DaySidebar + ScheduleItem widgets

纯展示组件，无需测试，analyze 验证即可。

**Files:**
- Create: `lib/features/schedule/presentation/widgets/day_sidebar.dart`
- Create: `lib/features/schedule/presentation/widgets/schedule_item.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/lib/features/schedule/presentation/widgets
```

- [ ] **Step 2: 实现 day_sidebar.dart**

```dart
// lib/features/schedule/presentation/widgets/day_sidebar.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';

class DaySidebar extends StatelessWidget {
  const DaySidebar({
    super.key,
    required this.totalDays,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final int totalDays;        // 旅行总天数
  final int selectedDay;      // 0 = 待规划，1-N = 第 N 天
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    // 1..totalDays + 0（待规划）
    final days = [for (int d = 1; d <= totalDays; d++) d, 0];

    return SizedBox(
      width: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day == selectedDay;
          return GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.input),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBorder : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  day == 0 ? '?' : '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
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

- [ ] **Step 3: 实现 schedule_item.dart**

```dart
// lib/features/schedule/presentation/widgets/schedule_item.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/schedule.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.schedule,
    required this.onTap,
    this.onClone,
    this.onDelete,
    this.canEdit = true,
  });

  final Schedule schedule;
  final VoidCallback onTap;
  final VoidCallback? onClone;
  final VoidCallback? onDelete;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final timeLabel = schedule.startTime != null
        ? timeFmt.format(schedule.startTime!.toLocal())
        : schedule.isHotel
            ? _hotelLabel()
            : '待规划';

    final shadowColor = schedule.isHotel
        ? const Color(0x148B5CF6)
        : const Color(0x14F97316);
    final borderColor = schedule.isHotel ? AppColors.hotel : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [BoxShadow(color: shadowColor, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 左侧色条
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.card),
                    bottomLeft: Radius.circular(AppRadius.card),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 时间标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: schedule.isHotel ? AppColors.hotelLight : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppRadius.timeCell),
                            ),
                            child: Text(
                              timeLabel,
                              style: AppTextStyles.micro.copyWith(
                                color: schedule.isHotel ? AppColors.hotel : AppColors.primary,
                              ),
                            ),
                          ),
                          if (schedule.isHotel) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.hotelLight,
                                borderRadius: BorderRadius.circular(AppRadius.timeCell),
                                border: Border.all(color: AppColors.hotelBorder),
                              ),
                              child: Text('住宿',
                                  style: AppTextStyles.micro.copyWith(color: AppColors.hotel)),
                            ),
                          ],
                          const Spacer(),
                          if (canEdit)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_horiz,
                                  size: 18, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                                if (onClone != null)
                                  const PopupMenuItem(value: 'clone', child: Text('克隆')),
                                if (onDelete != null)
                                  const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') onTap();
                                if (v == 'clone') onClone?.call();
                                if (v == 'delete') onDelete?.call();
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(schedule.name,
                          style: AppTextStyles.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (schedule.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(schedule.address,
                            style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(schedule.notes!,
                            style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      // 截图数量（Plan 6 实现上传，此处仅展示数量）
                      if (schedule.screenshotList.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('${schedule.screenshotList.length} 张截图',
                            style: AppTextStyles.micro),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hotelLabel() {
    if (schedule.startTime == null) return '待规划';
    if (schedule.endTime == null) return '入住';
    final checkIn = schedule.startTime!;
    final checkOut = schedule.endTime!;
    final nights = checkOut.difference(checkIn).inDays;
    return '${DateFormat('MM/dd').format(checkIn)}–${DateFormat('MM/dd').format(checkOut)} · $nights 晚';
  }
}
```

- [ ] **Step 4: 验证编译**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter
flutter analyze lib/features/schedule/presentation/widgets/
```

Expected: No issues found!

- [ ] **Step 5: Commit**

```bash
git add lib/features/schedule/presentation/widgets/
git commit -m "feat: add DaySidebar and ScheduleItem widgets"
```

---

## Task 6: ScheduleEditSheet

新建/编辑行程的底部面板。包含：名称、备注、天宫格（普通/酒店两种模式）、小时宫格（普通模式）。

**设计：**
- `schedule == null` → 新建模式（tId 由参数传入）
- `schedule != null` → 编辑模式
- `isHotel` 在构造时确定（从 schedule.isHotel 取 or 默认 false）
- 坐标新建时默认 `"0,0"`（Plan 5 地图搜索后会替换为真实坐标）

**天 ↔ startTime/endTime 转换：**
- 普通地点，选中 day D，hour H → `startTime = travelStart + (D-1) days + H hours`
- 普通地点，选中 day D，未选时间 → `startTime = DateTime(year,month,day+D-1)` (只含日期，时分秒=0)
- 普通地点，待规划（D=0）→ `startTime = null`
- 酒店：`startTime = travelStart + (checkIn-1) days + 12h`，`endTime = travelStart + (checkOut-1) days + 12h`

**Files:**
- Create: `lib/features/schedule/presentation/schedule_edit_sheet.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/lib/features/schedule/presentation
```

- [ ] **Step 2: 实现 schedule_edit_sheet.dart**

```dart
// lib/features/schedule/presentation/schedule_edit_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../data/schedule_repository.dart';
import '../domain/schedule_provider.dart';

class ScheduleEditSheet extends ConsumerStatefulWidget {
  const ScheduleEditSheet({
    super.key,
    required this.travel,
    this.schedule,
    this.initialDay,
  });

  final Travel travel;
  final Schedule? schedule;  // null = 新建
  final int? initialDay;     // 打开时预选天

  static Future<void> show(
    BuildContext context, {
    required Travel travel,
    Schedule? schedule,
    int? initialDay,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ScheduleEditSheet(
        travel: travel,
        schedule: schedule,
        initialDay: initialDay,
      ),
    );
  }

  @override
  ConsumerState<ScheduleEditSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends ConsumerState<ScheduleEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _notesCtrl;
  late bool _isHotel;
  bool _saving = false;

  // 普通地点选择
  late int? _selectedDay;   // 0=待规划, 1-N=第N天, null=未选
  late int? _selectedHour;  // 0-23, null=不选时间

  // 酒店选择
  late int? _checkInDay;
  late int? _checkOutDay;
  bool _hotelTapIsCheckIn = true;

  int get _totalDays =>
      widget.travel.endDate.difference(widget.travel.startDate).inDays + 1;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _isHotel = s?.isHotel ?? false;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');

    if (s != null) {
      _initFromSchedule(s);
    } else {
      _selectedDay = widget.initialDay ?? 1;
      _selectedHour = null;
      _checkInDay = null;
      _checkOutDay = null;
      _hotelTapIsCheckIn = true;
    }
  }

  void _initFromSchedule(Schedule s) {
    // 统一转为 local time，避免服务端返回 UTC 与本地 travelStart 混用导致天数偏移
    final start = widget.travel.startDate;
    if (s.isHotel) {
      _checkInDay = s.startTime != null
          ? s.startTime!.toLocal().difference(start).inDays + 1
          : null;
      _checkOutDay = s.endTime != null
          ? s.endTime!.toLocal().difference(start).inDays + 1
          : null;
      _hotelTapIsCheckIn = false;
      _selectedDay = null;
      _selectedHour = null;
    } else {
      if (s.startTime != null) {
        _selectedDay = s.startTime!.toLocal().difference(start).inDays + 1;
        _selectedHour = s.startTime!.toLocal().hour;
      } else {
        _selectedDay = 0; // 待规划
        _selectedHour = null;
      }
      _checkInDay = null;
      _checkOutDay = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Day grid tap ────────────────────────────────────────────────────────────

  void _onDayTap(int day) {
    if (!_isHotel) {
      setState(() => _selectedDay = day);
    } else {
      setState(() {
        if (_hotelTapIsCheckIn) {
          _checkInDay = day;
          _checkOutDay = null;
          _hotelTapIsCheckIn = false;
        } else {
          if (day <= (_checkInDay ?? 0)) {
            _checkInDay = day;
            _checkOutDay = null;
          } else {
            _checkOutDay = day;
            _hotelTapIsCheckIn = true;
          }
        }
      });
    }
  }

  // ── Build form data ─────────────────────────────────────────────────────────

  ScheduleFormData _buildFormData() {
    final travelStart = widget.travel.startDate;
    DateTime? startTime, endTime;

    if (!_isHotel) {
      if (_selectedDay != null && _selectedDay! > 0) {
        final base = travelStart.add(Duration(days: _selectedDay! - 1));
        final h = _selectedHour ?? 0;
        startTime = DateTime(base.year, base.month, base.day, h, 0, 0);
      }
      // day == 0 (待规划) → startTime = null
    } else {
      if (_checkInDay != null) {
        final ci = travelStart.add(Duration(days: _checkInDay! - 1));
        startTime = DateTime(ci.year, ci.month, ci.day, 12, 0, 0);
      }
      if (_checkOutDay != null) {
        final co = travelStart.add(Duration(days: _checkOutDay! - 1));
        endTime = DateTime(co.year, co.month, co.day, 12, 0, 0);
      }
    }

    return ScheduleFormData(
      id: widget.schedule?.id,
      tId: widget.travel.id!,
      name: _nameCtrl.text.trim(),
      coordinate: widget.schedule?.coordinate ?? '0,0',
      address: widget.schedule?.address ?? '',
      isHotel: _isHotel,
      startTime: startTime,
      endTime: endTime,
      cover: widget.schedule?.cover,
      dianpingUUID: widget.schedule?.dianpingUUID,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      screenshots: widget.schedule?.screenshots,
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final form = _buildFormData();
    try {
      final notifier = ref.read(scheduleProvider(widget.travel.id!).notifier);
      if (widget.schedule == null) {
        await notifier.add(form);
      } else {
        await notifier.update(form);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.schedule != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 标题栏
                  Row(
                    children: [
                      Text(isEdit ? '编辑行程' : '新建行程',
                          style: AppTextStyles.appBarTitle),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── 名称
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '名称'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 12),
                  // ── 备注
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: '备注（可选）'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  // ── 天选择宫格
                  Text('出行天', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 8),
                  _DayGrid(
                    totalDays: _totalDays,
                    travelStart: widget.travel.startDate,
                    isHotel: _isHotel,
                    selectedDay: _selectedDay,
                    checkInDay: _checkInDay,
                    checkOutDay: _checkOutDay,
                    onTap: _onDayTap,
                  ),
                  if (!_isHotel) ...[
                    const SizedBox(height: 16),
                    // ── 小时宫格
                    Text('出发时间（可选）', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 8),
                    _HourGrid(
                      selectedHour: _selectedHour,
                      onTap: (h) => setState(() => _selectedHour = h == _selectedHour ? null : h),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // ── 保存按钮
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.fab),
                    ),
                    child: TextButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? '保存修改' : '创建行程',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Day Grid ─────────────────────────────────────────────────────────────────

class _DayGrid extends StatelessWidget {
  const _DayGrid({
    required this.totalDays,
    required this.travelStart,
    required this.isHotel,
    required this.selectedDay,
    required this.checkInDay,
    required this.checkOutDay,
    required this.onTap,
  });

  final int totalDays;
  final DateTime travelStart;
  final bool isHotel;
  final int? selectedDay;
  final int? checkInDay;
  final int? checkOutDay;
  final ValueChanged<int> onTap;

  static const _weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

  @override
  Widget build(BuildContext context) {
    // Days 1..totalDays + 0 (待规划)
    final days = [for (int d = 1; d <= totalDays; d++) d, 0];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        bool isSelected = false;
        bool isRangeMiddle = false;
        String? tag;

        if (isHotel) {
          if (day > 0) {
            if (day == checkInDay) {
              isSelected = true;
              tag = '入住';
            } else if (day == checkOutDay) {
              isSelected = true;
              tag = '退房';
            } else if (checkInDay != null && checkOutDay != null &&
                day > checkInDay! && day < checkOutDay!) {
              isRangeMiddle = true;
            }
          }
        } else {
          isSelected = day == selectedDay;
        }

        Color bg;
        Color textColor;
        Color borderColor;
        if (isSelected) {
          bg = AppColors.primaryLight;
          textColor = AppColors.primary;
          borderColor = AppColors.primaryBorder;
        } else if (isRangeMiddle) {
          bg = const Color(0xFFFFF7ED);
          textColor = AppColors.textSecondary;
          borderColor = Colors.transparent;
        } else {
          bg = const Color(0xFFF5F5F4);
          textColor = AppColors.textSecondary;
          borderColor = Colors.transparent;
        }

        final weekday = day > 0
            ? _weekLabels[travelStart.add(Duration(days: day - 1)).weekday - 1]
            : null;

        return GestureDetector(
          onTap: () => onTap(day),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        day == 0 ? '待规划' : '第 $day 天',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor),
                      ),
                      if (weekday != null)
                        Text(
                          '周$weekday',
                          style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.7)),
                        ),
                    ],
                  ),
                ),
                if (tag != null)
                  Positioned(
                    right: 4, top: 3,
                    child: Text(tag,
                        style: const TextStyle(
                            fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Hour Grid ────────────────────────────────────────────────────────────────

class _HourGrid extends StatelessWidget {
  const _HourGrid({required this.selectedHour, required this.onTap});
  final int? selectedHour;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.4,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 24,
      itemBuilder: (context, h) {
        final isSelected = h == selectedHour;
        return GestureDetector(
          onTap: () => onTap(h),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : const Color(0xFFF5F5F4),
              borderRadius: BorderRadius.circular(AppRadius.timeCell),
              border: Border.all(
                  color: isSelected ? AppColors.primaryBorder : Colors.transparent),
            ),
            child: Center(
              child: Text(
                '$h',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 3: 验证编译**

```bash
flutter analyze lib/features/schedule/presentation/schedule_edit_sheet.dart
```

Expected: No issues found!

- [ ] **Step 4: Commit**

```bash
git add lib/features/schedule/presentation/schedule_edit_sheet.dart
git commit -m "feat: add ScheduleEditSheet with day/time grid pickers"
```

---

## Task 7: ScheduleListPanel

行程 Tab 主面板：左侧 DaySidebar + 右侧当天行程列表 + FAB 新建。

**酒店跨天逻辑：** `isHotel && endTime != null` 时，在 checkIn 到 checkOut 的每天都显示。

**Files:**
- Create: `lib/features/schedule/presentation/schedule_list_panel.dart`

- [ ] **Step 1: 实现 schedule_list_panel.dart**

```dart
// lib/features/schedule/presentation/schedule_list_panel.dart
// NOTE: 不含 Scaffold — FAB 由父级 TravelDetailScreen 管理，避免嵌套 Scaffold 问题
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/user_travel.dart';
import '../domain/schedule_provider.dart';
import 'widgets/day_sidebar.dart';
import 'widgets/schedule_item.dart';
import 'schedule_edit_sheet.dart';

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

  List<Schedule> _schedulesForDay(int day, List<Schedule> all) {
    if (day == 0) {
      return all.where((s) => s.startTime == null).toList();
    }
    return all.where((s) {
      if (s.startTime == null) return false;
      final startDay = s.startTime!.toLocal().difference(travel.startDate).inDays + 1;
      if (s.isHotel && s.endTime != null) {
        final endDay = s.endTime!.toLocal().difference(travel.startDate).inDays + 1;
        return day >= startDay && day <= endDay;
      }
      return startDay == day;
    }).toList()
      ..sort((a, b) =>
          (a.startTime ?? DateTime(0)).compareTo(b.startTime ?? DateTime(0)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(scheduleProvider(travel.id!));
    final selectedDay = ref.watch(selectedDayProvider(travel.id!));

    return Row(
      children: [
        // ── 左侧天数栏
        Container(
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppColors.border)),
          ),
          child: DaySidebar(
            totalDays: _totalDays,
            selectedDay: selectedDay,
            onDaySelected: (d) =>
                ref.read(selectedDayProvider(travel.id!).notifier).state = d,
          ),
        ),
        // ── 右侧行程列表
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
                    onPressed: () => ref.invalidate(scheduleProvider(travel.id!)),
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
                onRefresh: () async => ref.invalidate(scheduleProvider(travel.id!)),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ScheduleItem(
                      schedule: s,
                      canEdit: _canEdit,
                      onTap: _canEdit
                          ? () => ScheduleEditSheet.show(
                                context,
                                travel: travel,
                                schedule: s,
                                initialDay: selectedDay,
                              )
                          : () {},
                      onClone: _canEdit
                          ? () => ref
                              .read(scheduleProvider(travel.id!).notifier)
                              .clone(s.id!)
                          : null,
                      onDelete: _canEdit
                          ? () => _confirmDelete(context, ref, s)
                          : null,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
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
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(scheduleProvider(travel.id!).notifier).remove(s.id!);
    }
  }
}
```

- [ ] **Step 2: 验证编译**

```bash
flutter analyze lib/features/schedule/presentation/schedule_list_panel.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/features/schedule/presentation/schedule_list_panel.dart
git commit -m "feat: add ScheduleListPanel with day sidebar and schedule list"
```

---

## Task 8: CollaboratorSheet

协作者管理底部面板：展示邀请链接 + 协作者列表（角色下拉/移除）。

**Files:**
- Create: `lib/features/travel/presentation/widgets/collaborator_sheet.dart`

- [ ] **Step 1: 实现 collaborator_sheet.dart**

```dart
// lib/features/travel/presentation/widgets/collaborator_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/user_travel.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../data/travel_repository.dart';
import '../../domain/travel_detail_provider.dart';
import '../../domain/travel_list_provider.dart';

class CollaboratorSheet extends ConsumerStatefulWidget {
  const CollaboratorSheet({super.key, required this.travelId});
  final int travelId;

  static Future<void> show(BuildContext context, int travelId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollaboratorSheet(travelId: travelId),
    );
  }

  @override
  ConsumerState<CollaboratorSheet> createState() => _CollaboratorSheetState();
}

class _CollaboratorSheetState extends ConsumerState<CollaboratorSheet> {
  String? _inviteToken;
  bool _loadingInvite = false;

  Future<void> _loadInvite() async {
    setState(() => _loadingInvite = true);
    try {
      final token =
          await ref.read(travelRepositoryProvider).invite(widget.travelId);
      setState(() => _inviteToken = token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loadingInvite = false);
    }
  }

  Future<void> _copyInvite() async {
    if (_inviteToken == null) {
      await _loadInvite();
      if (_inviteToken == null) return;
    }
    await Clipboard.setData(
        ClipboardData(text: 'roadbook://accept?inviteToken=$_inviteToken'));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('邀请链接已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final currentUserId =
        ref.watch(authStateProvider).valueOrNull?.user?.id;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 标题栏
              Row(
                children: [
                  const Text('协作者管理', style: AppTextStyles.appBarTitle),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // ── 邀请链接
              OutlinedButton.icon(
                onPressed: _loadingInvite ? null : _copyInvite,
                icon: _loadingInvite
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.link, size: 16),
                label:
                    const Text('复制邀请链接', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(height: 16),
              // ── 协作者列表
              travelAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString(),
                    style: AppTextStyles.caption),
                data: (travel) {
                  final collabs = travel.collaborators;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: collabs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, i) {
                        final c = collabs[i];
                        final isSelf = c.user.id == currentUserId;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                (c.user.username).substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          title: Text(c.user.name ?? c.user.username,
                              style: AppTextStyles.body),
                          subtitle: Text('@${c.user.username}',
                              style: AppTextStyles.micro),
                          trailing: isSelf
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _roleLabel(c.role),
                                    style: AppTextStyles.micro.copyWith(
                                        color: AppColors.primary),
                                  ),
                                )
                              : PopupMenuButton<String>(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_roleLabel(c.role),
                                            style: AppTextStyles.micro),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 14,
                                            color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'manage', child: Text('管理者')),
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('编辑者')),
                                    const PopupMenuItem(
                                        value: 'view', child: Text('查看者')),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('移除',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                  onSelected: (role) async {
                                    try {
                                      if (role == 'delete') {
                                        await ref
                                            .read(travelDetailProvider(
                                                    widget.travelId)
                                                .notifier)
                                            .removeCollab(c.user.id!);
                                      } else {
                                        await ref
                                            .read(travelDetailProvider(
                                                    widget.travelId)
                                                .notifier)
                                            .updateCollab(c.user.id!, role);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(e.toString())));
                                      }
                                    }
                                  },
                                ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(RoleType role) {
    switch (role) {
      case RoleType.manage:
        return '管理者';
      case RoleType.edit:
        return '编辑者';
      case RoleType.view:
        return '查看者';
    }
  }
}
```

- [ ] **Step 2: 验证编译**

```bash
flutter analyze lib/features/travel/presentation/widgets/collaborator_sheet.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/features/travel/presentation/widgets/collaborator_sheet.dart
git commit -m "feat: add CollaboratorSheet for managing travel collaborators"
```

---

## Task 9: TravelDetailScreen

AppBar + TabBar 主框架（地图 Tab 为占位符，行程 Tab 接入 ScheduleListPanel）。

**Files:**
- Create: `lib/features/travel/presentation/travel_detail_screen.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter/lib/features/travel/presentation
```

- [ ] **Step 2: 实现 travel_detail_screen.dart**

```dart
// lib/features/travel/presentation/travel_detail_screen.dart
// ConsumerStatefulWidget with TabController — FAB 托管在此 Scaffold，避免嵌套 Scaffold 问题
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/models/user_travel.dart';
import '../domain/travel_detail_provider.dart';
import '../presentation/widgets/travel_form_sheet.dart';
import '../presentation/widgets/collaborator_sheet.dart';
import '../../../features/schedule/presentation/schedule_list_panel.dart';
import '../../../features/schedule/presentation/schedule_edit_sheet.dart';
import '../../../features/schedule/domain/schedule_provider.dart';

class TravelDetailScreen extends ConsumerStatefulWidget {
  const TravelDetailScreen({super.key, required this.travelId});
  final int travelId;

  @override
  ConsumerState<TravelDetailScreen> createState() => _TravelDetailScreenState();
}

class _TravelDetailScreenState extends ConsumerState<TravelDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging && mounted) {
        setState(() => _currentTab = _tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final perm = ref.watch(travelPermProvider(widget.travelId));
    final canEdit = perm == RoleType.manage || perm == RoleType.edit;
    final canManage = perm == RoleType.manage;

    return travelAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(e.toString(), style: AppTextStyles.caption)),
      ),
      data: (travel) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(travel.name, style: AppTextStyles.appBarTitle),
              if (travel.cities.isNotEmpty)
                Text(
                  travel.cities.join(' · '),
                  style: AppTextStyles.micro.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
          actions: [
            if (canManage)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: '编辑旅程信息',
                onPressed: () => TravelFormSheet.show(context, travel: travel),
              ),
            if (canManage)
              IconButton(
                icon: const Icon(Icons.group_outlined, size: 20),
                tooltip: '协作者管理',
                onPressed: () => CollaboratorSheet.show(context, widget.travelId),
              ),
            if (canEdit)
              IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                tooltip: '批量导入',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('批量导入 — Plan 5 实现'))),
              ),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            tabs: const [
              Tab(icon: Icon(Icons.map_outlined), text: '地图'),
              Tab(icon: Icon(Icons.format_list_bulleted), text: '行程'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        // FAB 仅在行程 Tab（index=1）且有编辑权限时显示
        floatingActionButton: (_currentTab == 1 && canEdit)
            ? _buildFab(context, travel)
            : null,
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── 地图 Tab（占位符，Plan 5 实现）
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.map, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('地图功能将在 Plan 5 实现', style: AppTextStyles.caption),
                ],
              ),
            ),
            // ── 行程 Tab（无 Scaffold）
            ScheduleListPanel(travel: travel, perm: perm),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context, Travel travel) {
    final selectedDay = ref.watch(selectedDayProvider(widget.travelId));
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.fab),
      ),
      child: FloatingActionButton(
        onPressed: () => ScheduleEditSheet.show(
          context,
          travel: travel,
          initialDay: selectedDay == 0 ? null : selectedDay,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
```

- [ ] **Step 3: 验证编译**

```bash
flutter analyze lib/features/travel/presentation/travel_detail_screen.dart
```

Expected: No issues found!

- [ ] **Step 4: Commit**

```bash
git add lib/features/travel/presentation/travel_detail_screen.dart
git commit -m "feat: add TravelDetailScreen with Schedule tab and Collaborator sheet"
```

---

## Task 10: 路由更新 — 连接 /travel/:id 到 TravelDetailScreen

**Files:**
- Modify: `lib/core/router.dart`

- [ ] **Step 1: 更新 router.dart**

将文件内容替换为：

```dart
// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_state_provider.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/travel/presentation/travel_list_screen.dart';
import '../features/travel/presentation/travel_detail_screen.dart';

const _publicRoutes = {'/signin', '/signup', '/accept'};

abstract class RouterGuard {
  static String? computeRedirect({
    required String? token,
    required String location,
  }) {
    final isPublic = _publicRoutes.any((r) => location.startsWith(r));
    if (token == null && !isPublic) return '/signin';
    if (token != null && (location == '/signin' || location == '/signup')) {
      return '/travel';
    }
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier<int>(0);
  ref.listen(authStateProvider, (_, __) => refreshNotifier.value++);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/travel',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final token = ref.read(authStateProvider).valueOrNull?.token;
      return RouterGuard.computeRedirect(
        token: token,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(
          path: '/accept',
          builder: (_, __) => const _PlaceholderScreen(label: 'Accept')),
      GoRoute(
        path: '/travel',
        builder: (_, __) => const TravelListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final id = int.parse(state.pathParameters['id']!);
              return TravelDetailScreen(travelId: id);
            },
          ),
        ],
      ),
    ],
  );
});

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
            child: Text(label, style: const TextStyle(fontSize: 18))),
      );
}
```

- [ ] **Step 2: 运行路由测试**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter
flutter test test/core/router_test.dart -v
```

Expected: All 5 tests passed

- [ ] **Step 3: Commit**

```bash
git add lib/core/router.dart
git commit -m "feat: wire TravelDetailScreen into GoRouter /travel/:id route"
```

---

## Task 11: 全量验证

- [ ] **Step 1: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/.worktrees/flutter-travel-list/packages/roadbook-flutter
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: flutter test**

```bash
flutter test -v
```

Expected: All tests passed（≥ 61 tests）

---

## 完成标准

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — All tests pass（≥ 61 tests）
- [ ] 旅程列表点击卡片跳转至旅程详情页
- [ ] 详情页 AppBar 显示旅程名称 + 城市
- [ ] 有 manage 权限时显示编辑、协作者、批量导入按钮
- [ ] 行程 Tab 左侧天数栏可切换
- [ ] 右侧展示当天行程列表（支持酒店跨天）
- [ ] 点击行程卡片或编辑菜单打开编辑面板
- [ ] 编辑面板保存后列表更新
- [ ] 克隆行程追加到列表
- [ ] 删除行程从列表移除
- [ ] 协作者管理面板可复制邀请链接、修改角色、移除协作者

## 下一个 Plan

`docs/superpowers/plans/2026-03-23-flutter-05-map-tab.md` — 地图 Tab（高德地图、POI 搜索、标记渲染、fitBounds）
