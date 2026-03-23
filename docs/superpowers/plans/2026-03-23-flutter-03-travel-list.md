# Roadbook Flutter — Plan 3: Travel List Screen

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现旅程列表页，包括分页加载、搜索防抖、旅程卡片、新建/编辑旅程面板、用户菜单（退出登录），并将路由 `/travel` 从占位屏幕切换为真实实现。

**Architecture:** Feature-first。`features/travel/data/` 封装 Dio API 调用；`features/travel/domain/` 提供 Riverpod Notifier 管理分页状态和搜索防抖；`features/travel/presentation/` 实现列表屏幕、旅程卡片、表单底部面板。同时修复两处 `fromJson` Bug：`Travel.fromJson` 字段名与后端 API 不符（`public`/`city`/`Users`/`Schedules`），以及 `UserWithRole.fromJson` 结构与 Sequelize 联表返回格式不符（用户字段在顶层，role 在 `UserTravel.role`）。

**Tech Stack:** Flutter (stable), flutter_riverpod ^2.5, go_router ^14, dio ^5.4, mocktail ^1.0

**Spec:** `docs/superpowers/specs/2026-03-20-roadbook-flutter-design.md` §5.2, §10.8

> **注意：** 旅程列表的 `/api/travel/page` 接口每条记录的 `Users` 字段只包含当前用户（服务端 `where: { id: uid }` 过滤），**不包含所有协作者**。因此旅程卡片不展示协作者头像，将在 Travel Detail Plan 中由详情接口提供完整协作者列表后补全。

---

## File Map

### 修改文件
- `lib/shared/models/travel.dart` — 修正 `fromJson` 字段名匹配后端 API
- `lib/shared/models/user_travel.dart` — 修正 `UserWithRole.fromJson` 匹配 Sequelize 联表格式
- `test/shared/models/travel_test.dart` — 同步更新测试 JSON key
- `test/shared/models/user_travel_test.dart` — 新增 UserWithRole 测试
- `lib/core/router.dart` — 将 `/travel` 路由绑定到 `TravelListScreen`

### 新建文件
```
lib/
└── features/travel/
    ├── data/
    │   └── travel_repository.dart          # page / save / remove Dio 调用
    ├── domain/
    │   └── travel_list_provider.dart       # 分页状态 + 搜索防抖 Notifier
    └── presentation/
        ├── widgets/
        │   ├── travel_card.dart            # 旅程卡片（名称、状态徽章、日期、天数、城市）
        │   └── travel_form_sheet.dart      # 新建/编辑旅程底部面板
        └── travel_list_screen.dart         # 列表页（搜索栏、进行中横幅、列表、FAB、用户菜单）
test/
└── features/travel/
    ├── data/
    │   └── travel_repository_test.dart
    └── domain/
        └── travel_list_provider_test.dart
```

---

## Task 1: 修复 fromJson — Travel + UserWithRole 字段名对齐后端 API

### 后端实际字段（Sequelize 返回）

**Travel：**
- `public`（而非 `isPublic`）
- `city`（而非 `cities`，逗号分隔字符串）
- `Users`（而非 `collaborators`）
- `Schedules`（而非 `schedules`）

**Users 数组中每个元素（Sequelize 联表）：**
```json
{ "id": 1, "username": "alice", "avatar": null, "name": "Alice",
  "UserTravel": { "role": "manage" } }
```
用户字段在顶层（而非嵌套在 `user`），role 在 `UserTravel.role`（而非顶层 `role`）。

**Files:**
- Modify: `lib/shared/models/travel.dart`
- Modify: `lib/shared/models/user_travel.dart`
- Modify: `test/shared/models/travel_test.dart`
- Create: `test/shared/models/user_travel_test.dart`

- [ ] **Step 1: 更新 travel_test.dart — JSON key 改为后端实际字段名**

```dart
// test/shared/models/travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

void main() {
  group('Travel', () {
    test('fromJson parses cities string to list', () {
      final travel = Travel.fromJson({
        'id': 1,
        'name': 'Trip A',
        'startDate': '2024-06-01',
        'endDate': '2024-06-05',
        'public': false,
        'city': '北京',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, ['北京']);
    });

    test('fromJson parses multi-city string', () {
      final travel = Travel.fromJson({
        'id': 2,
        'name': 'Trip B',
        'startDate': '2024-07-01',
        'endDate': '2024-07-10',
        'public': true,
        'city': '北京,上海,成都',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, ['北京', '上海', '成都']);
    });

    test('fromJson handles empty cities', () {
      final travel = Travel.fromJson({
        'id': 3,
        'name': 'Trip C',
        'startDate': '2024-08-01',
        'endDate': '2024-08-03',
        'public': false,
        'city': '',
        'Users': [],
        'Schedules': [],
      });
      expect(travel.cities, isEmpty);
    });
  });
}
```

- [ ] **Step 2: 新建 user_travel_test.dart**

```dart
// test/shared/models/user_travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/user_travel.dart';

void main() {
  group('UserWithRole', () {
    // Sequelize 联表返回格式：用户字段在顶层，role 在 UserTravel.role
    final json = {
      'id': 1,
      'username': 'alice',
      'avatar': null,
      'name': 'Alice',
      'UserTravel': {'role': 'manage'},
    };

    test('fromJson parses user fields from top level', () {
      final uwr = UserWithRole.fromJson(json);
      expect(uwr.user.id, 1);
      expect(uwr.user.username, 'alice');
      expect(uwr.user.name, 'Alice');
    });

    test('fromJson parses role from UserTravel', () {
      final uwr = UserWithRole.fromJson(json);
      expect(uwr.role, RoleType.manage);
    });

    test('fromJson parses edit role', () {
      final j = Map<String, dynamic>.from(json)
        ..['UserTravel'] = {'role': 'edit'};
      expect(UserWithRole.fromJson(j).role, RoleType.edit);
    });

    test('fromJson falls back to view for unknown role', () {
      final j = Map<String, dynamic>.from(json)
        ..['UserTravel'] = {'role': 'unknown'};
      expect(UserWithRole.fromJson(j).role, RoleType.view);
    });
  });
}
```

- [ ] **Step 3: 运行模型测试（预期失败）**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter
flutter test test/shared/models/ -v
```

Expected: travel_test FAIL（key 不匹配）+ user_travel_test FAIL（fromJson 结构不对）

- [ ] **Step 4: 修改 travel.dart**

```dart
// lib/shared/models/travel.dart
import 'schedule.dart';
import 'user_travel.dart';

class Travel {
  const Travel({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isPublic,
    required this.cities,
    required this.collaborators,
    required this.schedules,
    this.equip,
  });

  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  final List<String> cities;
  final List<UserWithRole> collaborators;
  final List<Schedule> schedules;
  final String? equip;

  factory Travel.fromJson(Map<String, dynamic> json) {
    // 后端字段 city（逗号分隔字符串）
    final cityRaw = json['city'] as String? ?? '';
    final cities = cityRaw.isEmpty
        ? <String>[]
        : cityRaw.split(',').where((s) => s.isNotEmpty).toList();

    return Travel(
      id: json['id'] as int?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isPublic: json['public'] as bool? ?? false,          // 后端字段 public
      cities: cities,
      collaborators: (json['Users'] as List<dynamic>? ?? [])    // 后端字段 Users
          .map((e) => UserWithRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['Schedules'] as List<dynamic>? ?? [])    // 后端字段 Schedules
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      equip: json['equip'] as String?,
    );
  }
}
```

- [ ] **Step 5: 修改 user_travel.dart**

```dart
// lib/shared/models/user_travel.dart
import 'user.dart';

enum RoleType { manage, edit, view }

RoleType roleTypeFromString(String s) =>
    RoleType.values.firstWhere((e) => e.name == s,
        orElse: () => RoleType.view);

class UserWithRole {
  const UserWithRole({required this.user, required this.role});

  final User user;
  final RoleType role;

  /// Sequelize 联表格式：用户字段在顶层，role 在 UserTravel.role
  factory UserWithRole.fromJson(Map<String, dynamic> json) => UserWithRole(
        user: User.fromJson(json),
        role: roleTypeFromString(
          (json['UserTravel'] as Map<String, dynamic>)['role'] as String,
        ),
      );
}
```

- [ ] **Step 6: 运行全部模型测试（预期通过）**

```bash
flutter test test/shared/models/ -v
```

Expected: All model tests pass（User + Schedule + Travel + UserWithRole）

- [ ] **Step 7: Commit**

```bash
git add lib/shared/models/travel.dart lib/shared/models/user_travel.dart \
        test/shared/models/travel_test.dart test/shared/models/user_travel_test.dart
git commit -m "fix: align Travel and UserWithRole fromJson with actual backend API shape"
```

---

## Task 2: TravelRepository

封装 `/api/travel/page`、`/api/travel/save`、`/api/travel/remove`。

**API 约定：**
- `page` 请求：`{ page, pageSize, name }` → 响应：`{ record: [...], total, page, pageSize }`
- `save` 请求：`{ id?, name, startDate (ISO string), endDate (ISO string), public, city (逗号分隔) }`
- `remove` 请求：`{ id }`

**Files:**
- Create: `lib/features/travel/data/travel_repository.dart`
- Create: `test/features/travel/data/travel_repository_test.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/lib/features/travel/data
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/test/features/travel/data
```

- [ ] **Step 2: 写 travel_repository_test.dart（先写测试）**

```dart
// test/features/travel/data/travel_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';

// 后端字段名：public, city, Users, Schedules
Map<String, dynamic> _travelJson({int id = 1, String name = 'Trip A'}) => {
  'id': id,
  'name': name,
  'startDate': '2024-06-01',
  'endDate': '2024-06-05',
  'public': false,
  'city': '北京',
  'Users': [],
  'Schedules': [],
};

void main() {
  group('TravelRepository', () {
    late Dio dio;
    late TravelRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = TravelRepository(dio);
    });

    test('page returns TravelPage with parsed travels and hasMore', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect(body['page'], 1);
          expect(body['pageSize'], 15);
          expect(body['name'], '');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'record': [_travelJson(id: 1), _travelJson(id: 2)],
              'total': 20,
              'page': 1,
              'pageSize': 15,
            },
          ));
        },
      ));

      final result = await repo.page(page: 1, keyword: '');
      expect(result.travels.length, 2);
      expect(result.travels.first.name, 'Trip A');
      expect(result.hasMore, isTrue); // 2 < 20
    });

    test('page hasMore is false when all loaded', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'record': [_travelJson()],
              'total': 1,
              'page': 1,
              'pageSize': 15,
            },
          ));
        },
      ));

      final result = await repo.page(page: 1, keyword: '');
      expect(result.hasMore, isFalse);
    });

    test('page passes keyword as name param', () async {
      String? capturedName;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedName = (options.data as Map)['name'] as String;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'record': [], 'total': 0, 'page': 1, 'pageSize': 15},
          ));
        },
      ));

      await repo.page(page: 1, keyword: '上海');
      expect(capturedName, '上海');
    });

    test('save sends correct payload and returns Travel', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect(body['name'], 'New Trip');
          expect(body['public'], false);
          expect(body['city'], '深圳,广州');
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _travelJson(id: 99, name: 'New Trip'),
          ));
        },
      ));

      final travel = await repo.save(TravelFormData(
        name: 'New Trip',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 9, 5),
        isPublic: false,
        cities: ['深圳', '广州'],
      ));
      expect(travel.id, 99);
    });

    test('save includes id when editing existing travel', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _travelJson(id: 5),
          ));
        },
      ));

      await repo.save(TravelFormData(
        id: 5,
        name: 'Edit Trip',
        startDate: DateTime(2024, 9, 1),
        endDate: DateTime(2024, 9, 3),
        isPublic: false,
        cities: [],
      ));
      expect(capturedId, 5);
    });

    test('remove sends id and completes', () async {
      int? capturedId;
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedId = (options.data as Map)['id'] as int?;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: null,
          ));
        },
      ));

      await repo.remove(42);
      expect(capturedId, 42);
    });

    test('page throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '获取失败'},
            ),
          ));
        },
      ));

      expect(() => repo.page(page: 1, keyword: ''), throwsA(isA<String>()));
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/features/travel/data/travel_repository_test.dart -v
```

Expected: FAIL — `TravelRepository` not found

- [ ] **Step 4: 实现 travel_repository.dart**

```dart
// lib/features/travel/data/travel_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/travel.dart';

const _pageSize = 15;

class TravelPage {
  const TravelPage({required this.travels, required this.hasMore});
  final List<Travel> travels;
  final bool hasMore;
}

class TravelFormData {
  const TravelFormData({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isPublic,
    required this.cities,
  });

  final int? id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isPublic;
  final List<String> cities;
}

class TravelRepository {
  TravelRepository(this._dio);
  final Dio _dio;

  Future<TravelPage> page({required int page, required String keyword}) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelPage,
        data: {'page': page, 'pageSize': _pageSize, 'name': keyword},
      );
      final data = res.data!;
      final records = (data['record'] as List<dynamic>)
          .map((e) => Travel.fromJson(e as Map<String, dynamic>))
          .toList();
      final total = data['total'] as int;
      final loadedCount = (page - 1) * _pageSize + records.length;
      return TravelPage(travels: records, hasMore: loadedCount < total);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取旅程失败';
    }
  }

  Future<Travel> save(TravelFormData form) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelSave,
        data: {
          if (form.id != null) 'id': form.id,
          'name': form.name,
          'startDate': form.startDate.toIso8601String(),
          'endDate': form.endDate.toIso8601String(),
          'public': form.isPublic,
          'city': form.cities.join(','),
        },
      );
      return Travel.fromJson(res.data!);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '保存旅程失败';
    }
  }

  Future<void> remove(int id) async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.travelRemove, data: {'id': id});
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '删除旅程失败';
    }
  }
}
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/features/travel/data/travel_repository_test.dart -v
```

Expected: 6 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/features/travel/data/travel_repository.dart test/features/travel/data/travel_repository_test.dart
git commit -m "feat: add TravelRepository with page/save/remove"
```

---

## Task 3: TravelListNotifier

管理分页状态和 500ms 搜索防抖。

**State：**
```
TravelListState {
  items: List<Travel>    // 已加载的所有旅程
  page: int              // 当前已加载到的页码
  hasMore: bool          // 是否还有下一页
  isLoadingMore: bool    // 是否正在追加加载（区别于初始 loading）
  keyword: String        // 当前搜索关键词
}
```

**Files:**
- Create: `lib/features/travel/domain/travel_list_provider.dart`
- Create: `test/features/travel/domain/travel_list_provider_test.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/lib/features/travel/domain
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/test/features/travel/domain
```

- [ ] **Step 2: 写 travel_list_provider_test.dart**

```dart
// test/features/travel/domain/travel_list_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/travel/data/travel_repository.dart';
import 'package:roadbook_flutter/features/travel/domain/travel_list_provider.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

class MockTravelRepository extends Mock implements TravelRepository {}

Travel _makeTravel(int id) => Travel(
      id: id,
      name: 'Trip $id',
      startDate: DateTime(2024, 6, 1),
      endDate: DateTime(2024, 6, 5),
      isPublic: false,
      cities: [],
      collaborators: [],
      schedules: [],
    );

TravelPage _makePage(List<Travel> travels, {bool hasMore = false}) =>
    TravelPage(travels: travels, hasMore: hasMore);

void main() {
  group('TravelListNotifier', () {
    late MockTravelRepository mockRepo;

    setUp(() {
      mockRepo = MockTravelRepository();
    });

    ProviderContainer makeContainer() => ProviderContainer(overrides: [
          travelRepositoryProvider.overrideWithValue(mockRepo),
        ]);

    test('initial build loads page 1', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1), _makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      final state = await container.read(travelListProvider.future);
      expect(state.items.length, 2);
      expect(state.page, 1);
      expect(state.hasMore, isFalse);
      expect(state.keyword, '');
    });

    test('loadMore appends travels and increments page', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)], hasMore: true));
      when(() => mockRepo.page(page: 2, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).loadMore();

      final state = container.read(travelListProvider).value!;
      expect(state.items.length, 2);
      expect(state.page, 2);
      expect(state.hasMore, isFalse);
    });

    test('loadMore is no-op when hasMore is false', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).loadMore();

      // page() called exactly once
      verify(() => mockRepo.page(page: 1, keyword: '')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('refresh resets to page 1 and replaces items', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1), _makeTravel(2)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).refresh();

      final state = container.read(travelListProvider).value!;
      expect(state.items.length, 2);
      expect(state.page, 1);
    });

    test('setKeyword resets to page 1 with new keyword', () async {
      when(() => mockRepo.page(page: 1, keyword: ''))
          .thenAnswer((_) async => _makePage([_makeTravel(1)]));
      when(() => mockRepo.page(page: 1, keyword: '上海'))
          .thenAnswer((_) async => _makePage([_makeTravel(99)]));

      final container = makeContainer();
      addTearDown(container.dispose);

      await container.read(travelListProvider.future);
      await container.read(travelListProvider.notifier).setKeyword('上海');

      final state = container.read(travelListProvider).value!;
      expect(state.items.first.id, 99);
      expect(state.keyword, '上海');
      expect(state.page, 1);
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/features/travel/domain/travel_list_provider_test.dart -v
```

Expected: FAIL — `travelListProvider` not found

- [ ] **Step 4: 实现 travel_list_provider.dart**

> **注意：** `travelRepositoryProvider` 使用 `ref.watch`（而非 `ref.read`），与 `auth_provider.dart` 保持一致，避免 stale 依赖。

```dart
// lib/features/travel/domain/travel_list_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/travel_repository.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/providers/dio_provider.dart';

// ─── Repository Provider ─────────────────────────────────────────────────────

final travelRepositoryProvider = Provider<TravelRepository>((ref) {
  return TravelRepository(ref.watch(dioProvider)); // watch, not read
});

// ─── State ───────────────────────────────────────────────────────────────────

class TravelListState {
  const TravelListState({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.isLoadingMore,
    required this.keyword,
  });

  final List<Travel> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final String keyword;

  TravelListState copyWith({
    List<Travel>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    String? keyword,
  }) =>
      TravelListState(
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        keyword: keyword ?? this.keyword,
      );
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class TravelListNotifier extends AutoDisposeAsyncNotifier<TravelListState> {
  @override
  Future<TravelListState> build() => _fetch(page: 1, keyword: '', previous: null);

  Future<TravelListState> _fetch({
    required int page,
    required String keyword,
    required TravelListState? previous,
  }) async {
    final result = await ref
        .read(travelRepositoryProvider)
        .page(page: page, keyword: keyword);

    final newItems = page == 1
        ? result.travels
        : [...(previous?.items ?? []), ...result.travels];

    return TravelListState(
      items: newItems,
      page: page,
      hasMore: result.hasMore,
      isLoadingMore: false,
      keyword: keyword,
    );
  }

  Future<void> refresh() async {
    final keyword = state.valueOrNull?.keyword ?? '';
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(page: 1, keyword: keyword, previous: null),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    try {
      final next = await _fetch(page: nextPage, keyword: current.keyword, previous: current);
      state = AsyncData(next);
    } catch (e, st) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> setKeyword(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(page: 1, keyword: keyword, previous: null),
    );
  }

  /// 新建或编辑旅程后乐观更新列表（插入/替换头部）
  void upsert(Travel travel) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(
      items: [travel, ...current.items.where((t) => t.id != travel.id)],
    ));
  }

  /// 删除旅程后乐观移出列表
  void remove(int id) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(items: current.items.where((t) => t.id != id).toList()),
    );
  }
}

final travelListProvider =
    AsyncNotifierProvider.autoDispose<TravelListNotifier, TravelListState>(
  TravelListNotifier.new,
);
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/features/travel/domain/travel_list_provider_test.dart -v
```

Expected: 5 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/features/travel/domain/travel_list_provider.dart test/features/travel/domain/travel_list_provider_test.dart
git commit -m "feat: add TravelListNotifier with pagination and keyword search"
```

---

## Task 4: TravelCard 组件

纯展示组件，无需测试。

**状态逻辑：**
- `now < startDate` → 待出发（橙色）
- `startDate <= now <= endDate` → 旅行中（绿色）
- `now > endDate` → 已结束（灰色）

**Files:**
- Create: `lib/features/travel/presentation/widgets/travel_card.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/lib/features/travel/presentation/widgets
```

- [ ] **Step 2: 实现 travel_card.dart**

```dart
// lib/features/travel/presentation/widgets/travel_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

enum TravelStatus { upcoming, ongoing, ended }

TravelStatus computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  final today = DateTime(now.year, now.month, now.day);
  if (today.isBefore(startDay)) return TravelStatus.upcoming;
  if (today.isAfter(endDay)) return TravelStatus.ended;
  return TravelStatus.ongoing;
}

class TravelCard extends StatelessWidget {
  const TravelCard({
    super.key,
    required this.travel,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Travel travel;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = computeTravelStatus(travel.startDate, travel.endDate);
    final days = travel.endDate.difference(travel.startDate).inDays + 1;
    final fmt = DateFormat('MM/dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.cardGap / 2),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: const [
            BoxShadow(
              color: Color(0x081C1917),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部行：名称 + 操作菜单
              Row(
                children: [
                  Expanded(
                    child: Text(
                      travel.name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz,
                          size: 18, color: AppColors.textSecondary),
                      padding: EdgeInsets.zero,
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        if (onDelete != null)
                          const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除',
                                  style: TextStyle(color: Colors.red))),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') onEdit?.call();
                        if (value == 'delete') onDelete?.call();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 日期范围 + 天数
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${fmt.format(travel.startDate)} — ${fmt.format(travel.endDate)}  ·  $days 天',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              // 城市
              if (travel.cities.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        travel.cities.join(' · '),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              // 状态徽章
              _StatusBadge(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final TravelStatus status;

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color bg;
    late Color textColor;
    late Color borderColor;

    switch (status) {
      case TravelStatus.upcoming:
        label = '待出发';
        bg = AppColors.primaryLight;
        textColor = AppColors.primary;
        borderColor = AppColors.primaryBorder;
      case TravelStatus.ongoing:
        label = '旅行中';
        bg = AppColors.successLight;
        textColor = AppColors.success;
        borderColor = const Color(0xFFA7F3D0);
      case TravelStatus.ended:
        label = '已结束';
        bg = const Color(0xFFF5F5F4);
        textColor = AppColors.neutral;
        borderColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        border: Border.all(color: borderColor),
      ),
      child: Text(label, style: AppTextStyles.micro.copyWith(color: textColor)),
    );
  }
}
```

> **注意：** `computeTravelStatus` 声明为顶层函数（非私有），供 `TravelListScreen` 的进行中横幅直接复用。

- [ ] **Step 3: 验证编译**

```bash
flutter analyze lib/features/travel/presentation/widgets/travel_card.dart
```

Expected: No issues found!

- [ ] **Step 4: Commit**

```bash
git add lib/features/travel/presentation/widgets/travel_card.dart
git commit -m "feat: add TravelCard widget with status badge"
```

---

## Task 5: TravelFormSheet 组件

新建/编辑旅程的底部面板。

**Files:**
- Create: `lib/features/travel/presentation/widgets/travel_form_sheet.dart`

- [ ] **Step 1: 实现 travel_form_sheet.dart**

```dart
// lib/features/travel/presentation/widgets/travel_form_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../features/travel/data/travel_repository.dart';
import '../../../../features/travel/domain/travel_list_provider.dart';
import '../../../../shared/models/travel.dart';

class TravelFormSheet extends ConsumerStatefulWidget {
  const TravelFormSheet({super.key, this.travel});

  /// null → 新建；non-null → 编辑
  final Travel? travel;

  static Future<void> show(BuildContext context, {Travel? travel}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TravelFormSheet(travel: travel),
    );
  }

  @override
  ConsumerState<TravelFormSheet> createState() => _TravelFormSheetState();
}

class _TravelFormSheetState extends ConsumerState<TravelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _citiesCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isPublic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.travel;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _citiesCtrl = TextEditingController(text: t?.cities.join(',') ?? '');
    _startDate = t?.startDate ?? DateTime.now();
    _endDate = t?.endDate ?? DateTime.now().add(const Duration(days: 3));
    _isPublic = t?.isPublic ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _citiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final cities = _citiesCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final form = TravelFormData(
      id: widget.travel?.id,
      name: _nameCtrl.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      isPublic: _isPublic,
      cities: cities,
    );

    try {
      final repo = ref.read(travelRepositoryProvider);
      final saved = await repo.save(form);
      ref.read(travelListProvider.notifier).upsert(saved);
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

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy/MM/dd');
    final isEdit = widget.travel != null;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 标题栏
                  Row(
                    children: [
                      Text(isEdit ? '编辑旅程' : '新建旅程',
                          style: AppTextStyles.appBarTitle),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 名称
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '旅程名称'),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? '请输入旅程名称' : null,
                  ),
                  const SizedBox(height: 12),
                  // 城市
                  TextFormField(
                    controller: _citiesCtrl,
                    decoration: const InputDecoration(
                      labelText: '城市（逗号分隔）',
                      hintText: '北京,上海',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  // 日期范围
                  InkWell(
                    onTap: _pickDateRange,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '出行日期',
                        suffixIcon: Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Text(
                        '${fmt.format(_startDate)}  →  ${fmt.format(_endDate)}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 公开开关
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('公开旅程', style: AppTextStyles.body),
                    value: _isPublic,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isPublic = v),
                  ),
                  const SizedBox(height: 16),
                  // 保存按钮（渐变）
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(
                              isEdit ? '保存修改' : '创建旅程',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
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
```

- [ ] **Step 2: 验证编译**

```bash
flutter analyze lib/features/travel/presentation/widgets/travel_form_sheet.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/features/travel/presentation/widgets/travel_form_sheet.dart
git commit -m "feat: add TravelFormSheet for create/edit travel"
```

---

## Task 6: TravelListScreen

列表页主屏幕。包含：
- 顶部 Header（标题 + 用户头像菜单）
- 搜索框（500ms 防抖）
- **进行中横幅**（若有旅行中旅程则展示在列表顶部，§10.8）
- 旅程列表（下拉刷新 + 滚动加载更多）
- 右下角 FAB（新建旅程）
- 旅程卡片导航：点击跳转 `/travel/:id`（当前为占位屏幕，Task 7 后生效）

**Files:**
- Create: `lib/features/travel/presentation/travel_list_screen.dart`

- [ ] **Step 1: 创建目录**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter/lib/features/travel/presentation
```

- [ ] **Step 2: 实现 travel_list_screen.dart**

```dart
// lib/features/travel/presentation/travel_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../domain/travel_list_provider.dart';
import '../data/travel_repository.dart';
import 'widgets/travel_card.dart';
import 'widgets/travel_form_sheet.dart';

class TravelListScreen extends ConsumerStatefulWidget {
  const TravelListScreen({super.key});

  @override
  ConsumerState<TravelListScreen> createState() => _TravelListScreenState();
}

class _TravelListScreenState extends ConsumerState<TravelListScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(travelListProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(travelListProvider.notifier).setKeyword(value.trim());
    });
  }

  Future<void> _confirmDelete(int travelId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除旅程'),
        content: Text('确定删除「$name」？此操作无法撤销。'),
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
    if (confirmed != true) return;

    try {
      await ref.read(travelRepositoryProvider).remove(travelId);
      ref.read(travelListProvider.notifier).remove(travelId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    final listAsync = ref.watch(travelListProvider);

    final userInfo = authAsync.valueOrNull?.user;
    final avatar = userInfo?.avatar;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text('我的旅程', style: AppTextStyles.pageHeroTitle),
                  ),
                  // 用户头像菜单
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await ref.read(authStateProvider.notifier).logout();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('功能开发中')));
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'profile', child: Text('编辑资料')),
                      PopupMenuItem(value: 'password', child: Text('修改密码')),
                      PopupMenuDivider(),
                      PopupMenuItem(
                          value: 'logout',
                          child: Text('退出登录',
                              style: TextStyle(color: Colors.red))),
                    ],
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient:
                            avatar == null ? AppColors.primaryGradient : null,
                        borderRadius: BorderRadius.circular(12),
                        image: avatar != null
                            ? DecorationImage(
                                image: NetworkImage(avatar),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: avatar == null
                          ? Center(
                              child: Text(
                                (userInfo?.username ?? '?')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ─── 搜索框 ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '搜索旅程名称…',
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.textSecondary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchCtrl.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ─── 旅程列表 ─────────────────────────────────────────────
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
                            ref.read(travelListProvider.notifier).refresh(),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.map_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text('暂无旅程，点击 ＋ 开始规划',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }

                  // 判断是否有进行中的旅程
                  final ongoingTravels = state.items
                      .where((t) =>
                          computeTravelStatus(t.startDate, t.endDate) ==
                          TravelStatus.ongoing)
                      .toList();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(travelListProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal, vertical: 4),
                      // +1 for ongoing banner, +1 for loading indicator
                      itemCount: (ongoingTravels.isNotEmpty ? 1 : 0) +
                          state.items.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // 进行中横幅（始终在顶部）
                        if (ongoingTravels.isNotEmpty && index == 0) {
                          return _OngoingBanner(travels: ongoingTravels);
                        }
                        final adjustedIndex =
                            index - (ongoingTravels.isNotEmpty ? 1 : 0);

                        if (adjustedIndex == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary)),
                          );
                        }

                        final travel = state.items[adjustedIndex];
                        return TravelCard(
                          travel: travel,
                          onTap: () => context.go('/travel/${travel.id}'),
                          onEdit: () =>
                              TravelFormSheet.show(context, travel: travel),
                          onDelete: () =>
                              _confirmDelete(travel.id!, travel.name),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FAB（渐变背景）
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.fab),
        ),
        child: FloatingActionButton(
          onPressed: () => TravelFormSheet.show(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── 进行中横幅（§10.8）─────────────────────────────────────────────────────

class _OngoingBanner extends StatelessWidget {
  const _OngoingBanner({required this.travels});
  final List<Travel> travels;

  @override
  Widget build(BuildContext context) {
    final names = travels.map((t) => t.name).join('、');
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.flight_takeoff, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '旅行中：$names',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 验证编译**

```bash
flutter analyze lib/features/travel/presentation/travel_list_screen.dart
```

Expected: No issues found!

- [ ] **Step 4: Commit**

```bash
git add lib/features/travel/presentation/travel_list_screen.dart
git commit -m "feat: add TravelListScreen with search, pagination, ongoing banner, FAB, user menu"
```

---

## Task 7: 连接路由到真实 TravelListScreen

**Files:**
- Modify: `lib/core/router.dart`

- [ ] **Step 1: 更新 router.dart**

```dart
// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_state_provider.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/travel/presentation/travel_list_screen.dart';

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
      GoRoute(path: '/signin',  builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/signup',  builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/accept',  builder: (_, __) => const _PlaceholderScreen(label: 'Accept')),
      GoRoute(
        path: '/travel',
        builder: (_, __) => const TravelListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => _PlaceholderScreen(
                label: 'Travel Detail: ${state.pathParameters['id']}'),
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
        body: Center(child: Text(label, style: const TextStyle(fontSize: 18))),
      );
}
```

- [ ] **Step 2: 运行路由单元测试**

```bash
flutter test test/core/router_test.dart -v
```

Expected: All 5 tests passed

- [ ] **Step 3: Commit**

```bash
git add lib/core/router.dart
git commit -m "feat: wire TravelListScreen into GoRouter /travel route"
```

---

## Task 8: 全量验证

- [ ] **Step 1: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook/packages/roadbook-flutter
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: flutter test**

```bash
flutter test -v
```

Expected: All tests passed（≥ 46 tests）

---

## 完成标准

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — All tests pass（≥ 46 tests）
- [ ] `flutter run` 登录后进入旅程列表页（非占位屏幕）
- [ ] 搜索框输入后 500ms 触发过滤请求
- [ ] 下拉刷新可刷新列表
- [ ] 滚动到底部触发加载下一页
- [ ] FAB 打开新建旅程底部面板，填写后创建成功
- [ ] 旅程卡片「编辑」打开编辑面板，保存后列表更新
- [ ] 旅程卡片「删除」确认后从列表移除
- [ ] 旅程卡片点击跳转 `/travel/:id`（当前为占位页）
- [ ] 有旅行中旅程时列表顶部显示进行中横幅
- [ ] 右上角用户菜单「退出登录」清空 token 跳回登录页

## 下一个 Plan

`docs/superpowers/plans/2026-03-23-flutter-04-travel-detail.md` — 旅程详情页（地图 Tab + 行程 Tab）
