# Discover & Profile Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Discover tab (public travel feed with city filter + search) and the Profile tab (user card + Edit Profile + Settings) with real API data.

**Architecture:** Backend gets one new endpoint (`/api/travel/discover`) and a minor fix to `UserService.update()`. Flutter adds `DiscoverNotifier` + `DiscoverScreen` following the same `AutoDisposeAsyncNotifier` pattern as `TravelListNotifier`; Profile screens use existing `authStateProvider` with a new `updateUser()` method. No new top-level providers for Profile — state lives in `authStateProvider` and local widget state.

**Tech Stack:** Flutter 3 · Riverpod (AutoDisposeAsyncNotifier) · go_router · Koa 2 · Sequelize · mocktail · package_info_plus

---

## 文件清单

| 操作 | 路径 |
|------|------|
| 新增迁移 | `packages/roadbook-api/migrations/20260328000001-travel-add-viewcount.js` |
| 修改 | `packages/roadbook-api/models/travel.js` |
| 修改 | `packages/roadbook-api/service/travel.js` |
| 修改 | `packages/roadbook-api/service/user.js` |
| 修改 | `packages/roadbook-api/controller/travel.js` |
| 修改 | `packages/roadbook-api/app.js` |
| 修改 | `packages/roadbook-flutter/lib/shared/api/api_endpoints.dart` |
| 新增 | `packages/roadbook-flutter/lib/shared/models/public_travel.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/discover/data/discover_repository.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/discover/domain/discover_provider.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/discover/presentation/widgets/public_travel_card.dart` |
| 修改 | `packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart` |
| 修改 | `packages/roadbook-flutter/lib/shared/providers/auth_state_provider.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/data/profile_repository.dart` |
| 修改 | `packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/presentation/edit_profile_screen.dart` |
| 新增 | `packages/roadbook-flutter/lib/features/profile/presentation/settings_screen.dart` |
| 修改 | `packages/roadbook-flutter/lib/core/router.dart` |
| 修改 | `packages/roadbook-flutter/pubspec.yaml` |
| 新增测试 | `packages/roadbook-flutter/test/shared/models/public_travel_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/features/discover/data/discover_repository_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/features/discover/domain/discover_provider_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/widget/features/discover/public_travel_card_test.dart` |
| 新增测试 | `packages/roadbook-flutter/test/widget/features/profile/profile_screen_test.dart` |

---

## Task 1: 后端 — Travel.viewCount 字段 + Discover 接口

**Files:**
- Create: `packages/roadbook-api/migrations/20260328000001-travel-add-viewcount.js`
- Modify: `packages/roadbook-api/models/travel.js`
- Modify: `packages/roadbook-api/service/travel.js`
- Modify: `packages/roadbook-api/controller/travel.js`
- Modify: `packages/roadbook-api/app.js`

- [ ] **Step 1: 新建迁移文件**

创建 `packages/roadbook-api/migrations/20260328000001-travel-add-viewcount.js`：

```javascript
'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Travels', 'viewCount', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });
  },
  async down(queryInterface) {
    await queryInterface.removeColumn('Travels', 'viewCount');
  },
};
```

- [ ] **Step 2: 运行迁移**

```bash
cd packages/roadbook-api && npm run db:migrate
```

预期：输出 `== 20260328000001-travel-add-viewcount: migrating =======` 后 `migrated (0.XXXs)`

- [ ] **Step 3: 在 Travel 模型中添加 viewCount 字段**

打开 `packages/roadbook-api/models/travel.js`，在 `public: DataTypes.BOOLEAN,` 后添加：

```javascript
    viewCount: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
```

- [ ] **Step 4: 在 TravelService 中添加 discover() 方法**

打开 `packages/roadbook-api/service/travel.js`，在 `page()` 方法前添加：

```javascript
  async discover(data) {
    try {
      const where = { public: true };
      if (data.keyword) {
        where.name = { [Op.like]: `%${data.keyword}%` };
      } else if (data.city) {
        where.city = { [Op.like]: `%${data.city}%` };
      }
      const pageSize = data.pageSize || 20;
      const page = data.page || 1;
      const result = await db.Travel.findAndCountAll({
        where,
        include: [
          {
            model: db.User,
            attributes: ['id', 'username', 'name', 'avatar'],
            through: { where: { role: 'manage' }, attributes: [] },
            required: true,
          },
        ],
        order: [['id', 'DESC']],
        limit: pageSize,
        offset: (page - 1) * pageSize,
      });
      return {
        total: result.count,
        list: result.rows.map((t) => ({
          id: t.id,
          name: t.name,
          city: t.city,
          startDate: t.startDate,
          endDate: t.endDate,
          viewCount: t.viewCount,
          owner: t.Users && t.Users[0]
            ? { id: t.Users[0].id, username: t.Users[0].username, name: t.Users[0].name, avatar: t.Users[0].avatar }
            : null,
        })),
      };
    } catch (e) {
      console.error('[travel.discover]', e);
      throw '获取失败';
    }
  }
```

- [ ] **Step 5: 在 detail() 中对匿名访问公开旅程时递增 viewCount**

找到 `service/travel.js` 中 `async detail(uid, id)` 方法，在 `if (travel && (travel.public || ...)) return travel` 这一行前插入：

```javascript
      if (travel && travel.public && !uid) {
        travel.increment('viewCount').catch(() => {}); // fire-and-forget
      }
```

完整修改后的 detail() 方法：

```javascript
  async detail(uid, id) {
    try {
      const travel = await db.Travel.findByPk(id, {
        include: [
          {
            model: db.User,
            attributes: ['id', 'username', 'name', 'avatar'],
          },
        ],
      });
      if (travel && travel.public && !uid) {
        travel.increment('viewCount').catch(() => {});
      }
      if (travel && (travel.public || (uid && travel.hasUser(uid)))) return travel;
      else throw '旅程不存在';
    } catch (e) {
      console.error(e);
      throw '获取失败';
    }
  }
```

- [ ] **Step 6: 在 TravelController 中添加 discover() action**

打开 `packages/roadbook-api/controller/travel.js`，在现有 controller class 的末尾（`}` 前）添加：

```javascript
  async discover(ctx, next) {
    try {
      await ctx.verifyParams({
        page:     { type: 'int', required: false },
        pageSize: { type: 'int', required: false },
        city:     { type: 'string', required: false, allowEmpty: true },
        keyword:  { type: 'string', required: false, allowEmpty: true },
      });
      ctx.body = ajaxReturn(await TravelService.discover(ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }
```

然后在同文件 `module.exports` 的路由注册部分，在 `route.post('/page', controller.page)` 前添加：

```javascript
  route.post('/discover', controller.discover);
```

- [ ] **Step 7: 将 /api/travel/discover 加入 JWT 白名单**

打开 `packages/roadbook-api/app.js`，找到：

```javascript
if (ctx.url.match(/^\/api\/(user\/(login|register)|travel\/(detail|schedule\/list))$/)) {
```

改为：

```javascript
if (ctx.url.match(/^\/api\/(user\/(login|register)|travel\/(detail|discover|schedule\/list))$/)) {
```

- [ ] **Step 8: 重启后端并手动验证**

```bash
cd packages/roadbook-api && node app.js &
curl -s -X POST http://localhost:3000/api/travel/discover \
  -H 'Content-Type: application/json' \
  -d '{"page":1,"pageSize":5}' | python3 -m json.tool
```

预期：返回 `{"code":200,"data":{"total":N,"list":[...]}}` （N 可为 0 如果没有公开旅程）

- [ ] **Step 9: Commit**

```bash
cd /path/to/repo  # roadbook root
git add packages/roadbook-api/migrations/20260328000001-travel-add-viewcount.js \
        packages/roadbook-api/models/travel.js \
        packages/roadbook-api/service/travel.js \
        packages/roadbook-api/controller/travel.js \
        packages/roadbook-api/app.js
git commit -m "feat(api): add Travel.viewCount, discover endpoint, and viewCount increment"
```

---

## Task 2: 后端 — UserService.update() 返回更新后的用户数据

**Files:**
- Modify: `packages/roadbook-api/service/user.js`

目前 `update()` 调用 `user.update(data)` 但不返回结果；前端需要拿到更新后的 user 对象。

- [ ] **Step 1: 修改 UserService.update()**

找到 `packages/roadbook-api/service/user.js` 中 `async update(uid, data)` 方法，替换为：

```javascript
  async update(uid, data) {
    try {
      const user = await db.User.findByPk(uid);
      if (!user) throw '未找到用户';
      // 只允许修改 name 和 avatar，不允许改 username/password
      const allowed = {};
      if (data.name  !== undefined) allowed.name  = data.name;
      if (data.avatar !== undefined) allowed.avatar = data.avatar;
      await user.update(allowed);
      return { id: user.id, username: user.username, name: user.name, avatar: user.avatar };
    } catch (e) {
      throw e || '更新失败';
    }
  }
```

- [ ] **Step 2: 手动验证**

```bash
# 需要先登录获取 token
TOKEN=$(curl -s -X POST http://localhost:3000/api/user/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"testuser","password":"testpass"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['token'])")

curl -s -X POST http://localhost:3000/api/user/update \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"新昵称"}' | python3 -m json.tool
```

预期：`{"code":200,"data":{"id":N,"username":"...","name":"新昵称","avatar":...}}`

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-api/service/user.js
git commit -m "fix(api): user update returns updated user object, restrict to name/avatar only"
```

---

## Task 3: Flutter — ApiEndpoints + PublicTravel 模型

**Files:**
- Modify: `packages/roadbook-flutter/lib/shared/api/api_endpoints.dart`
- Create: `packages/roadbook-flutter/lib/shared/models/public_travel.dart`
- Create: `packages/roadbook-flutter/test/shared/models/public_travel_test.dart`

- [ ] **Step 1: 写失败的测试**

创建 `packages/roadbook-flutter/test/shared/models/public_travel_test.dart`：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

void main() {
  group('PublicTravelOwner.fromJson', () {
    test('parses all fields', () {
      final json = {'id': 5, 'username': 'xiaoli', 'name': '旅行达人小李', 'avatar': 'https://a.com/img.jpg'};
      final owner = PublicTravelOwner.fromJson(json);
      expect(owner.id, 5);
      expect(owner.username, 'xiaoli');
      expect(owner.name, '旅行达人小李');
      expect(owner.avatar, 'https://a.com/img.jpg');
    });

    test('avatar can be null', () {
      final json = {'id': 1, 'username': 'u', 'name': 'U', 'avatar': null};
      expect(PublicTravelOwner.fromJson(json).avatar, isNull);
    });
  });

  group('PublicTravel.fromJson', () {
    final baseJson = {
      'id': 10,
      'name': '东京7日游',
      'city': '东京,大阪',
      'startDate': '2026-04-01',
      'endDate': '2026-04-07',
      'viewCount': 1200,
      'owner': {'id': 5, 'username': 'xiaoli', 'name': '达人小李', 'avatar': null},
    };

    test('parses id, name, viewCount', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.id, 10);
      expect(t.name, '东京7日游');
      expect(t.viewCount, 1200);
    });

    test('splits city string into list', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.cities, ['东京', '大阪']);
    });

    test('parses startDate and endDate as DateTime', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.startDate, DateTime(2026, 4, 1));
      expect(t.endDate, DateTime(2026, 4, 7));
    });

    test('days returns correct count', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.days, 7); // endDate - startDate + 1
    });

    test('cityLabel joins cities with ·', () {
      final t = PublicTravel.fromJson(baseJson);
      expect(t.cityLabel, '东京 · 大阪');
    });

    test('gradientIndex cycles by id % 4', () {
      final t = PublicTravel.fromJson(baseJson); // id=10, 10%4=2
      expect(t.gradientIndex, 2);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd packages/roadbook-flutter && flutter test test/shared/models/public_travel_test.dart 2>&1 | tail -5
```

预期：FAIL — `PublicTravel` 未定义。

- [ ] **Step 3: 实现 PublicTravel 模型**

创建 `packages/roadbook-flutter/lib/shared/models/public_travel.dart`：

```dart
// lib/shared/models/public_travel.dart

class PublicTravelOwner {
  const PublicTravelOwner({
    required this.id,
    required this.username,
    required this.name,
    this.avatar,
  });

  final int id;
  final String username;
  final String name;
  final String? avatar;

  factory PublicTravelOwner.fromJson(Map<String, dynamic> json) =>
      PublicTravelOwner(
        id: json['id'] as int,
        username: json['username'] as String,
        name: (json['name'] as String?) ?? (json['username'] as String),
        avatar: json['avatar'] as String?,
      );
}

class PublicTravel {
  const PublicTravel({
    required this.id,
    required this.name,
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.viewCount,
    required this.owner,
  });

  final int id;
  final String name;
  final List<String> cities;
  final DateTime startDate;
  final DateTime endDate;
  final int viewCount;
  final PublicTravelOwner owner;

  int get days => endDate.difference(startDate).inDays + 1;

  String get cityLabel => cities.join(' · ');

  int get gradientIndex => id % 4;

  factory PublicTravel.fromJson(Map<String, dynamic> json) {
    final cityStr = (json['city'] as String?) ?? '';
    final cities = cityStr.isEmpty
        ? <String>[]
        : cityStr.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return PublicTravel(
      id: json['id'] as int,
      name: json['name'] as String,
      cities: cities,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      viewCount: (json['viewCount'] as int?) ?? 0,
      owner: PublicTravelOwner.fromJson(json['owner'] as Map<String, dynamic>),
    );
  }
}
```

- [ ] **Step 4: 在 ApiEndpoints 中添加 travelDiscover**

打开 `packages/roadbook-flutter/lib/shared/api/api_endpoints.dart`，在 `travelSetRole` 后添加：

```dart
  static const String travelDiscover = '/api/travel/discover';
```

- [ ] **Step 5: 运行测试确认通过**

```bash
cd packages/roadbook-flutter && flutter test test/shared/models/public_travel_test.dart 2>&1 | tail -5
```

预期：All tests pass。

- [ ] **Step 6: Commit**

```bash
git add packages/roadbook-flutter/lib/shared/models/public_travel.dart \
        packages/roadbook-flutter/lib/shared/api/api_endpoints.dart \
        packages/roadbook-flutter/test/shared/models/public_travel_test.dart
git commit -m "feat(discover): add PublicTravel model and travelDiscover endpoint constant"
```

---

## Task 4: Flutter — DiscoverRepository

**Files:**
- Create: `packages/roadbook-flutter/lib/features/discover/data/discover_repository.dart`
- Create: `packages/roadbook-flutter/test/features/discover/data/discover_repository_test.dart`

- [ ] **Step 1: 写失败的测试**

创建 `packages/roadbook-flutter/test/features/discover/data/discover_repository_test.dart`：

```dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/discover/data/discover_repository.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late DiscoverRepository repo;

  setUp(() {
    mockDio = MockDio();
    repo = DiscoverRepository(mockDio);
  });

  final ownerJson = {'id': 1, 'username': 'u', 'name': 'U', 'avatar': null};
  final travelJson = {
    'id': 1,
    'name': 'Trip',
    'city': '东京',
    'startDate': '2026-04-01',
    'endDate': '2026-04-03',
    'viewCount': 10,
    'owner': ownerJson,
  };

  test('discover returns DiscoverPage with hasMore=true when more exist', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          data: {'total': 50, 'list': [travelJson]},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final page = await repo.discover(page: 1);
    expect(page.travels.length, 1);
    expect(page.travels.first, isA<PublicTravel>());
    expect(page.hasMore, isTrue); // 1 loaded < 50 total
  });

  test('discover returns hasMore=false when all loaded', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          data: {'total': 1, 'list': [travelJson]},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final page = await repo.discover(page: 1);
    expect(page.hasMore, isFalse);
  });

  test('discover throws String on DioException', () async {
    when(() => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'message': '获取失败'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ''),
          ),
        ));

    expect(() => repo.discover(page: 1), throwsA(isA<String>()));
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd packages/roadbook-flutter && flutter test test/features/discover/data/discover_repository_test.dart 2>&1 | tail -5
```

预期：FAIL — `DiscoverRepository` 未定义。

- [ ] **Step 3: 实现 DiscoverRepository**

创建 `packages/roadbook-flutter/lib/features/discover/data/discover_repository.dart`：

```dart
// lib/features/discover/data/discover_repository.dart
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/public_travel.dart';

const _pageSize = 20;

class DiscoverPage {
  const DiscoverPage({required this.travels, required this.hasMore});
  final List<PublicTravel> travels;
  final bool hasMore;
}

class DiscoverRepository {
  DiscoverRepository(this._dio);
  final Dio _dio;

  Future<DiscoverPage> discover({
    required int page,
    String? city,
    String? keyword,
  }) async {
    try {
      final data = <String, dynamic>{'page': page, 'pageSize': _pageSize};
      if (keyword != null && keyword.isNotEmpty) {
        data['keyword'] = keyword;
      } else if (city != null && city.isNotEmpty) {
        data['city'] = city;
      }
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.travelDiscover,
        data: data,
      );
      final body = res.data!;
      final total = body['total'] as int;
      final list = (body['list'] as List<dynamic>)
          .map((e) => PublicTravel.fromJson(e as Map<String, dynamic>))
          .toList();
      final loaded = (page - 1) * _pageSize + list.length;
      return DiscoverPage(travels: list, hasMore: loaded < total);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '获取失败';
    }
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd packages/roadbook-flutter && flutter test test/features/discover/data/discover_repository_test.dart 2>&1 | tail -5
```

预期：All tests pass。

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/discover/data/discover_repository.dart \
        packages/roadbook-flutter/test/features/discover/data/discover_repository_test.dart
git commit -m "feat(discover): add DiscoverRepository with pagination and city/keyword filter"
```

---

## Task 5: Flutter — DiscoverNotifier

**Files:**
- Create: `packages/roadbook-flutter/lib/features/discover/domain/discover_provider.dart`
- Create: `packages/roadbook-flutter/test/features/discover/domain/discover_provider_test.dart`

- [ ] **Step 1: 写失败的测试**

创建 `packages/roadbook-flutter/test/features/discover/domain/discover_provider_test.dart`：

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/features/discover/data/discover_repository.dart';
import 'package:roadbook_flutter/features/discover/domain/discover_provider.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

class MockDiscoverRepository extends Mock implements DiscoverRepository {}

final _owner = PublicTravelOwner(id: 1, username: 'u', name: 'U', avatar: null);
PublicTravel _makeTravel(int id) => PublicTravel(
      id: id,
      name: 'Trip $id',
      cities: ['城市'],
      startDate: DateTime(2026, 4, 1),
      endDate: DateTime(2026, 4, 3),
      viewCount: 0,
      owner: _owner,
    );

void main() {
  late MockDiscoverRepository mockRepo;

  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          discoverRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

  setUp(() {
    mockRepo = MockDiscoverRepository();
  });

  test('initial load populates state', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    final state = await container.read(discoverProvider.future);

    expect(state.travels.length, 1);
    expect(state.hasMore, isFalse);
    expect(state.selectedCity, isNull);
  });

  test('selectCity resets page and reloads', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));
    when(() => mockRepo.discover(page: 1, city: '东京', keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(2)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);

    await container.read(discoverProvider.notifier).selectCity('东京');
    final state = container.read(discoverProvider).value!;

    expect(state.travels.first.id, 2);
    expect(state.selectedCity, '东京');
  });

  test('loadMore appends to existing list', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: true));
    when(() => mockRepo.discover(page: 2, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(2)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);
    await container.read(discoverProvider.notifier).loadMore();

    final state = container.read(discoverProvider).value!;
    expect(state.travels.length, 2);
    expect(state.hasMore, isFalse);
  });

  test('search by keyword resets and reloads', () async {
    when(() => mockRepo.discover(page: 1, city: null, keyword: null))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(1)], hasMore: false));
    when(() => mockRepo.discover(page: 1, city: null, keyword: '东京'))
        .thenAnswer((_) async => DiscoverPage(travels: [_makeTravel(3)], hasMore: false));

    final container = makeContainer();
    addTearDown(container.dispose);
    await container.read(discoverProvider.future);
    await container.read(discoverProvider.notifier).search('东京');

    final state = container.read(discoverProvider).value!;
    expect(state.travels.first.id, 3);
    expect(state.keyword, '东京');
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd packages/roadbook-flutter && flutter test test/features/discover/domain/discover_provider_test.dart 2>&1 | tail -5
```

预期：FAIL — `discoverProvider` 未定义。

- [ ] **Step 3: 实现 DiscoverNotifier**

创建 `packages/roadbook-flutter/lib/features/discover/domain/discover_provider.dart`：

```dart
// lib/features/discover/domain/discover_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/models/public_travel.dart';
import '../data/discover_repository.dart';

// ─── Repository Provider ────────────────────────────────────────────────────

final discoverRepositoryProvider = Provider.autoDispose<DiscoverRepository>((ref) {
  return DiscoverRepository(ref.watch(dioProvider));
});

// ─── State ──────────────────────────────────────────────────────────────────

class DiscoverState {
  const DiscoverState({
    required this.travels,
    required this.hasMore,
    required this.isLoadingMore,
    this.selectedCity,
    this.keyword = '',
    this.page = 1,
  });

  final List<PublicTravel> travels;
  final bool hasMore;
  final bool isLoadingMore;
  final String? selectedCity;
  final String keyword;
  final int page;

  DiscoverState copyWith({
    List<PublicTravel>? travels,
    bool? hasMore,
    bool? isLoadingMore,
    Object? selectedCity = _sentinel,
    String? keyword,
    int? page,
  }) =>
      DiscoverState(
        travels: travels ?? this.travels,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        selectedCity: selectedCity == _sentinel
            ? this.selectedCity
            : selectedCity as String?,
        keyword: keyword ?? this.keyword,
        page: page ?? this.page,
      );
}

const _sentinel = Object();

// ─── Notifier ────────────────────────────────────────────────────────────────

class DiscoverNotifier extends AutoDisposeAsyncNotifier<DiscoverState> {
  @override
  Future<DiscoverState> build() => _load(page: 1);

  Future<DiscoverState> _load({
    required int page,
    String? city,
    String? keyword,
  }) async {
    final repo = ref.read(discoverRepositoryProvider);
    final result = await repo.discover(page: page, city: city, keyword: keyword);
    return DiscoverState(
      travels: result.travels,
      hasMore: result.hasMore,
      isLoadingMore: false,
      selectedCity: city,
      keyword: keyword ?? '',
      page: page,
    );
  }

  Future<void> selectCity(String? city) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(page: 1, city: city));
  }

  Future<void> search(String keyword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(page: 1, keyword: keyword.isEmpty ? null : keyword));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final repo = ref.read(discoverRepositoryProvider);
      final nextPage = current.page + 1;
      final result = await repo.discover(
        page: nextPage,
        city: current.keyword.isEmpty ? current.selectedCity : null,
        keyword: current.keyword.isEmpty ? null : current.keyword,
      );
      state = AsyncData(current.copyWith(
        travels: [...current.travels, ...result.travels],
        hasMore: result.hasMore,
        isLoadingMore: false,
        page: nextPage,
      ));
    } catch (e) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}

final discoverProvider =
    AsyncNotifierProvider.autoDispose<DiscoverNotifier, DiscoverState>(
  DiscoverNotifier.new,
);
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd packages/roadbook-flutter && flutter test test/features/discover/domain/discover_provider_test.dart 2>&1 | tail -5
```

预期：All tests pass。

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/discover/domain/discover_provider.dart \
        packages/roadbook-flutter/test/features/discover/domain/discover_provider_test.dart
git commit -m "feat(discover): add DiscoverNotifier with city filter, keyword search, load-more"
```

---

## Task 6: Flutter — PublicTravelCard 组件

**Files:**
- Create: `packages/roadbook-flutter/lib/features/discover/presentation/widgets/public_travel_card.dart`
- Create: `packages/roadbook-flutter/test/widget/features/discover/public_travel_card_test.dart`

- [ ] **Step 1: 写失败的 widget 测试**

创建 `packages/roadbook-flutter/test/widget/features/discover/public_travel_card_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/discover/presentation/widgets/public_travel_card.dart';
import 'package:roadbook_flutter/shared/models/public_travel.dart';

final _owner = PublicTravelOwner(id: 1, username: 'u', name: '达人小李', avatar: null);
final _travel = PublicTravel(
  id: 10,
  name: '东京7日游',
  cities: ['东京', '大阪'],
  startDate: DateTime(2026, 4, 1),
  endDate: DateTime(2026, 4, 7),
  viewCount: 1200,
  owner: _owner,
);

void main() {
  testWidgets('renders travel name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.text('东京7日游'), findsOneWidget);
  });

  testWidgets('renders city label', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.textContaining('东京'), findsWidgets);
  });

  testWidgets('renders owner name', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    expect(find.text('达人小李'), findsOneWidget);
  });

  testWidgets('renders formatted view count', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PublicTravelCard(travel: _travel)),
    ));
    // 1200 → "1.2k"
    expect(find.textContaining('1.2k'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd packages/roadbook-flutter && flutter test test/widget/features/discover/public_travel_card_test.dart 2>&1 | tail -5
```

预期：FAIL — `PublicTravelCard` 未定义。

- [ ] **Step 3: 实现 PublicTravelCard**

创建 `packages/roadbook-flutter/lib/features/discover/presentation/widgets/public_travel_card.dart`：

```dart
// lib/features/discover/presentation/widgets/public_travel_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/public_travel.dart';

/// 发现页旅程卡片：封面色块 + 旅程信息 + 作者信息
class PublicTravelCard extends StatelessWidget {
  const PublicTravelCard({super.key, required this.travel, this.onTap});

  final PublicTravel travel;
  final VoidCallback? onTap;

  static const _gradients = [
    LinearGradient(colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  String _formatViewCount(int count) {
    if (count >= 1000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[travel.gradientIndex];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面色块
              Container(
                height: 60,
                decoration: BoxDecoration(gradient: gradient),
              ),
              // 内容区
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travel.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${travel.cityLabel} · ${travel.days}天',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // 作者头像
                        _OwnerAvatar(owner: travel.owner),
                        const SizedBox(width: 5),
                        Text(
                          travel.owner.name,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatViewCount(travel.viewCount)} 浏览',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({required this.owner});
  final PublicTravelOwner owner;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 16,
        height: 16,
        child: owner.avatar != null
            ? Image.network(owner.avatar!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      );
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
cd packages/roadbook-flutter && flutter test test/widget/features/discover/public_travel_card_test.dart 2>&1 | tail -5
```

预期：All tests pass。

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/discover/presentation/widgets/public_travel_card.dart \
        packages/roadbook-flutter/test/widget/features/discover/public_travel_card_test.dart
git commit -m "feat(discover): add PublicTravelCard with gradient cover and owner info"
```

---

## Task 7: Flutter — DiscoverScreen 完整实现

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart`

- [ ] **Step 1: 完整替换 discover_screen.dart**

```dart
// lib/features/discover/presentation/discover_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../domain/discover_provider.dart';
import 'widgets/public_travel_card.dart';

const _cities = ['热门', '日本', '泰国', '韩国', '欧洲', '东南亚', '国内'];

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  Timer? _debounce;
  int _selectedCityIdx = 0; // 0 = 热门

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(discoverProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(discoverProvider.notifier).search(value);
    });
  }

  void _selectCity(int idx) {
    setState(() => _selectedCityIdx = idx);
    _searchCtrl.clear();
    final city = idx == 0 ? null : _cities[idx];
    ref.read(discoverProvider.notifier).selectCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(discoverProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Title
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 12,
                  AppSpacing.pageHorizontal, 0),
              child: Text('发现', style: AppTextStyles.largeTitle),
            ),
            // 搜索栏
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 8,
                  AppSpacing.pageHorizontal, 0),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '搜索旅程、目的地',
                  hintStyle: const TextStyle(
                      fontSize: 15, color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textSecondary, size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textSecondary, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref.read(discoverProvider.notifier).search('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0x1F767680),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.input),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            // 城市 Chip 横向滚动
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal, vertical: 4),
                itemCount: _cities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, idx) {
                  final active = idx == _selectedCityIdx;
                  return GestureDetector(
                    onTap: () => _selectCity(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _cities[idx],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 旅程列表
            Expanded(
              child: asyncState.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off,
                          size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 8),
                      Text('$e',
                          style: const TextStyle(
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(discoverProvider),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
                data: (state) {
                  if (state.travels.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.travel_explore,
                              size: 48,
                              color: AppColors.textTertiary),
                          SizedBox(height: 8),
                          Text('暂无公开旅程',
                              style: TextStyle(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(discoverProvider.notifier)
                            .selectCity(state.selectedCity),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      itemCount: state.travels.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, idx) {
                        if (idx == state.travels.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.primary),
                            ),
                          );
                        }
                        return PublicTravelCard(
                            travel: state.travels[idx]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 运行 flutter analyze 确认无错误**

```bash
cd packages/roadbook-flutter && flutter analyze lib/features/discover/ 2>&1 | tail -5
```

预期：`No issues found!` 或仅有 warning（无 error）。

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart
git commit -m "feat(discover): implement DiscoverScreen with city chips, search, infinite scroll"
```

---

## Task 8: Flutter — AuthStateNotifier.updateUser() + ProfileRepository

**Files:**
- Modify: `packages/roadbook-flutter/lib/shared/providers/auth_state_provider.dart`
- Create: `packages/roadbook-flutter/lib/features/profile/data/profile_repository.dart`

- [ ] **Step 1: 在 AuthStateNotifier 中添加 updateUser() 方法**

打开 `lib/shared/providers/auth_state_provider.dart`，在 `logout()` 方法后添加：

```dart
  /// 更新内存和持久化的 user 信息（头像、昵称更新后调用）
  Future<void> updateUser(User user) async {
    final current = state.valueOrNull;
    if (current == null || current.token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = AsyncData(AuthState(token: current.token, user: user));
  }
```

- [ ] **Step 2: 创建 ProfileRepository**

创建 `packages/roadbook-flutter/lib/features/profile/data/profile_repository.dart`：

```dart
// lib/features/profile/data/profile_repository.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/user.dart';

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  /// 更新昵称（name 字段）。返回更新后的 User。
  Future<User> updateName(String name) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userUpdate,
        data: {'name': name},
      );
      return User.fromJson(res.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '更新失败';
    }
  }

  /// 上传头像图片，返回头像 URL 后更新 user 记录。返回更新后的 User。
  Future<User> uploadAvatar(File imageFile) async {
    try {
      // Step 1: 上传图片，拿到 URL
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      final uploadRes = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.upload,
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final urls = uploadRes.data!['data'] as List<dynamic>;
      final avatarUrl = urls.first as String;

      // Step 2: 将 URL 写入 user 记录
      final updateRes = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.userUpdate,
        data: {'avatar': avatarUrl},
      );
      return User.fromJson(updateRes.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '上传失败';
    }
  }
}

```

- [ ] **Step 3: 运行 flutter analyze 确认无错误**

```bash
cd packages/roadbook-flutter && flutter analyze lib/shared/providers/auth_state_provider.dart \
  lib/features/profile/data/profile_repository.dart 2>&1 | tail -5
```

预期：No issues。

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/lib/shared/providers/auth_state_provider.dart \
        packages/roadbook-flutter/lib/features/profile/data/profile_repository.dart
git commit -m "feat(profile): add AuthStateNotifier.updateUser() and ProfileRepository"
```

---

## Task 9: Flutter — ProfileScreen

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart`
- Create: `packages/roadbook-flutter/test/widget/features/profile/profile_screen_test.dart`

- [ ] **Step 1: 写失败的 widget 测试**

创建 `packages/roadbook-flutter/test/widget/features/profile/profile_screen_test.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/features/profile/presentation/profile_screen.dart';
import 'package:go_router/go_router.dart';

GoRouter _router(Widget home) => GoRouter(
      initialLocation: '/',
      routes: [GoRoute(path: '/', builder: (_, __) => home)],
    );

AuthState _authState(String name) => AuthState(
      token: 'tok',
      user: User(id: 1, username: 'u', name: name, avatar: null),
    );

void main() {
  testWidgets('shows user name from authState', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() {
            final n = AuthStateNotifier();
            return n;
          }),
        ],
        child: MaterialApp.router(
          routerConfig: _router(const ProfileScreen()),
        ),
      ),
    );
    // 占位：ProfileScreen 会通过 authStateProvider 拿用户信息
    expect(find.byType(ProfileScreen), findsOneWidget);
  });

  testWidgets('shows Large Title 我的', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: const ProfileScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('我的'), findsOneWidget);
  });
}
```

- [ ] **Step 2: 完整替换 profile_screen.dart**

```dart
// lib/features/profile/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/user.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../features/travel/domain/travel_list_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.valueOrNull?.user;
    final travelAsync = ref.watch(travelListProvider);
    final travels = travelAsync.valueOrNull?.items ?? [];

    // 统计
    final travelCount = travels.length;
    final cityCount = travels
        .expand((t) => t.cities)
        .toSet()
        .length;
    final totalDays = travels.fold<int>(
      0,
      (sum, t) => sum + t.endDate.difference(t.startDate).inDays + 1,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Large Title
            const Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 12,
                  AppSpacing.pageHorizontal, 0),
              child: Text('我的', style: AppTextStyles.largeTitle),
            ),
            const SizedBox(height: 12),
            // 用户信息卡
            _UserCard(
              user: user,
              travelCount: travelCount,
              cityCount: cityCount,
              totalDays: totalDays,
              onTap: () => context.push('/profile/edit'),
            ),
            const SizedBox(height: 8),
            // 菜单组 1
            _MenuGroup(items: [
              _MenuItem(
                icon: Icons.mail_outline,
                iconBg: AppColors.primary,
                label: '消息中心',
                trailing: _ComingSoonBadge(),
                onTap: null, // 即将推出
              ),
              _MenuItem(
                icon: Icons.edit_outlined,
                iconBg: AppColors.success,
                label: '编辑资料',
                onTap: () => context.push('/profile/edit'),
              ),
              _MenuItem(
                icon: Icons.settings_outlined,
                iconBg: AppColors.textSecondary,
                label: '设置',
                onTap: () => context.push('/profile/settings'),
              ),
            ]),
            const SizedBox(height: 8),
            // 退出登录
            _MenuGroup(items: [
              _MenuItem(
                label: '退出登录',
                labelColor: AppColors.destructive,
                centerLabel: true,
                onTap: () => _confirmLogout(context, ref),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('退出后需重新登录'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('退出',
                  style: TextStyle(color: AppColors.destructive))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.travelCount,
    required this.cityCount,
    required this.totalDays,
    required this.onTap,
  });

  final User? user;
  final int travelCount;
  final int cityCount;
  final int totalDays;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Row(
          children: [
            // 头像
            _Avatar(avatarUrl: user?.avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? user?.username ?? '未登录',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _Stat(value: travelCount, label: '旅程'),
                      const SizedBox(width: 16),
                      _Stat(value: cityCount, label: '城市'),
                      const SizedBox(width: 16),
                      _Stat(value: totalDays, label: '天数'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 50,
        height: 50,
        child: avatarUrl != null
            ? Image.network(avatarUrl!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder())
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text('$value',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.contentCard),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 44,
                  color: AppColors.separator),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.label,
    this.icon,
    this.iconBg,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.centerLabel = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconBg;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? labelColor;
  final bool centerLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(AppRadius.iconBox),
                  ),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
                const SizedBox(width: 10),
              ],
              if (centerLabel) const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: labelColor ?? AppColors.textPrimary,
                  fontWeight: centerLabel ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (centerLabel) const Spacer(),
              if (!centerLabel) ...[
                const Spacer(),
                if (trailing != null) trailing!,
                if (onTap != null)
                  const Icon(Icons.chevron_right,
                      color: AppColors.textTertiary, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.destructive,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text('即将推出',
            style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
      );
}
```

- [ ] **Step 3: 运行 analyze 确认无错误**

```bash
cd packages/roadbook-flutter && flutter analyze lib/features/profile/presentation/profile_screen.dart 2>&1 | tail -5
```

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart \
        packages/roadbook-flutter/test/widget/features/profile/profile_screen_test.dart
git commit -m "feat(profile): implement ProfileScreen with user card, menu groups, logout"
```

---

## Task 10: Flutter — EditProfileScreen

**Files:**
- Create: `packages/roadbook-flutter/lib/features/profile/presentation/edit_profile_screen.dart`

- [ ] **Step 1: 实现 EditProfileScreen**

创建 `packages/roadbook-flutter/lib/features/profile/presentation/edit_profile_screen.dart`：

```dart
// lib/features/profile/presentation/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull?.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  ProfileRepository get _repo =>
      ProfileRepository(ref.read(dioProvider));

  bool get _isDirty {
    final user = ref.read(authStateProvider).valueOrNull?.user;
    return _nameCtrl.text.trim() != (user?.name ?? '');
  }

  Future<void> _save() async {
    if (!_isDirty || _saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _repo.updateName(_nameCtrl.text.trim());
      await ref.read(authStateProvider.notifier).updateUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('保存成功')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return;

    setState(() => _saving = true);
    try {
      final updated = await _repo.uploadAvatar(File(xfile.path));
      await ref.read(authStateProvider.notifier).updateUser(updated);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('头像已更新')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('编辑资料', style: AppTextStyles.appBarTitle),
        actions: [
          TextButton(
            onPressed: _isDirty && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : Text(
                    '保存',
                    style: TextStyle(
                      color: _isDirty
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 头像区
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: GestureDetector(
                onTap: _saving ? null : _pickAvatar,
                child: Stack(
                  children: [
                    _Avatar(avatarUrl: user?.avatar),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 表单
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.contentCard),
            ),
            child: Column(
              children: [
                // 用户名（只读）
                _FormRow(
                  label: '用户名',
                  child: Text(
                    user?.username ?? '',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56),
                // 昵称（可编辑）
                _FormRow(
                  label: '昵称',
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '设置昵称',
                      hintStyle:
                          TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56),
                // 密码（跳转占位）
                _FormRow(
                  label: '密码',
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密码修改功能即将推出'))),
                    child: const Row(
                      children: [
                        Text('修改密码',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary)),
                        Spacer(),
                        Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            child: const Text(
              '用户名仅用于登录，昵称显示在旅程中',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox(
          width: 70,
          height: 70,
          child: avatarUrl != null
              ? Image.network(avatarUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
      );

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      );
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
          ),
        ),
      );
}
```

- [ ] **Step 2: 确认 image_picker 已在 pubspec.yaml**

`image_picker` 已存在于依赖中，无需重复添加。直接继续。

- [ ] **Step 3: 运行 analyze 确认无错误**

```bash
cd packages/roadbook-flutter && flutter analyze lib/features/profile/presentation/edit_profile_screen.dart 2>&1 | tail -5
```

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/lib/features/profile/presentation/edit_profile_screen.dart \
        packages/roadbook-flutter/pubspec.yaml \
        packages/roadbook-flutter/pubspec.lock
git commit -m "feat(profile): implement EditProfileScreen with avatar upload and name edit"
```

---

## Task 11: Flutter — SettingsScreen + package_info_plus + Router

**Files:**
- Create: `packages/roadbook-flutter/lib/features/profile/presentation/settings_screen.dart`
- Modify: `packages/roadbook-flutter/pubspec.yaml`
- Modify: `packages/roadbook-flutter/lib/core/router.dart`

- [ ] **Step 1: 添加 package_info_plus + path_provider 依赖**

在 `packages/roadbook-flutter/pubspec.yaml` 的 `dependencies:` 中添加（`url_launcher` 附近）：

```yaml
  package_info_plus: ^8.3.0
  path_provider: ^2.1.5
```

```bash
cd packages/roadbook-flutter && flutter pub get
```

预期：`Got dependencies!`

- [ ] **Step 2: 实现 SettingsScreen**

创建 `packages/roadbook-flutter/lib/features/profile/presentation/settings_screen.dart`：

```dart
// lib/features/profile/presentation/settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _version = '';
  String _cacheSize = '计算中...';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadVersion();
    _calcCacheSize();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _darkMode = prefs.getBool('dark_mode') ?? false);
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
  }

  Future<void> _calcCacheSize() async {
    try {
      final dir = await getTemporaryDirectory();
      final size = _dirSize(dir);
      if (mounted) setState(() => _cacheSize = _formatSize(size));
    } catch (_) {
      if (mounted) setState(() => _cacheSize = '0 B');
    }
  }

  int _dirSize(Directory dir) {
    int total = 0;
    if (dir.existsSync()) {
      dir.listSync(recursive: true).forEach((e) {
        if (e is File) total += e.lengthSync();
      });
    }
    return total;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _clearCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      await _calcCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('缓存已清除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('清除失败: $e')));
      }
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _darkMode = value);
    // 主题切换留待后续迭代
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('深色模式将在下次启动时生效')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('设置', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _SectionTitle('通用'),
          _MenuGroup(items: [
            _SwitchItem(
              icon: Icons.dark_mode_outlined,
              iconBg: const Color(0xFF1C1C1E),
              label: '深色模式',
              value: _darkMode,
              onChanged: _toggleDarkMode,
            ),
            _RowItem(
              icon: Icons.language_outlined,
              iconBg: const Color(0xFF007AFF),
              label: '语言',
              trailing: const Text('简体中文',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              onTap: null,
            ),
          ]),
          _SectionTitle('存储'),
          _MenuGroup(items: [
            _RowItem(
              icon: Icons.delete_outline,
              iconBg: const Color(0xFFFF9500),
              label: '清除缓存',
              trailing: Text(_cacheSize,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              onTap: _clearCache,
            ),
          ]),
          _SectionTitle('关于'),
          _MenuGroup(items: [
            _RowItem(
              icon: Icons.info_outline,
              iconBg: AppColors.primary,
              label: '版本号',
              trailing: Text(_version,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
              onTap: null,
            ),
            _RowItem(
              icon: Icons.chat_bubble_outline,
              iconBg: AppColors.success,
              label: '意见反馈',
              onTap: () => launchUrl(
                  Uri.parse('https://github.com/kwokronny68/roadbook/issues'),
                  mode: LaunchMode.externalApplication),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal, 16, AppSpacing.pageHorizontal, 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5),
        ),
      );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.contentCard),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1)),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                const Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 44,
                    color: AppColors.separator),
            ],
          ],
        ),
      );
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _IconBox(icon: icon, bg: iconBg),
                const SizedBox(width: 10),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary)),
                const Spacer(),
                if (trailing != null) trailing!,
                if (onTap != null)
                  const Icon(Icons.chevron_right,
                      color: AppColors.textTertiary, size: 18),
              ],
            ),
          ),
        ),
      );
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _IconBox(icon: icon, bg: iconBg),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary)),
              const Spacer(),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.success,
              ),
            ],
          ),
        ),
      );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.bg});
  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.iconBox),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      );
}
```

- [ ] **Step 3: 添加路由 /profile/edit 和 /profile/settings**

打开 `packages/roadbook-flutter/lib/core/router.dart`，找到 profile branch：

```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/profile',
    builder: (_, __) => const ProfileScreen(),
  ),
]),
```

替换为：

```dart
StatefulShellBranch(routes: [
  GoRoute(
    path: '/profile',
    builder: (_, __) => const ProfileScreen(),
    routes: [
      GoRoute(
        path: 'edit',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  ),
]),
```

同时在文件顶部 imports 中添加：

```dart
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
```

- [ ] **Step 4: 运行 flutter analyze 确认整体无错误**

```bash
cd packages/roadbook-flutter && flutter analyze lib/ 2>&1 | grep -E "error|Error" | head -20
```

预期：无 error 输出。

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/profile/presentation/settings_screen.dart \
        packages/roadbook-flutter/lib/core/router.dart \
        packages/roadbook-flutter/pubspec.yaml \
        packages/roadbook-flutter/pubspec.lock
git commit -m "feat(profile): add SettingsScreen, EditProfile + Settings routes, package_info_plus"
```

---

## Task 12: 收尾验证

- [ ] **Step 1: 全量 analyze**

```bash
cd packages/roadbook-flutter && flutter analyze lib/ 2>&1 | tail -5
```

预期：`No issues found!` 或仅有 warning（无 error）。

- [ ] **Step 2: 检查 iOS 编译**

```bash
cd packages/roadbook-flutter && flutter build ios --no-codesign --simulator 2>&1 | tail -5
```

预期：`Build complete.`

- [ ] **Step 3: 最终 Commit**

```bash
git add -A
git commit -m "chore: final cleanup — discover & profile tabs complete" || echo "nothing to commit"
```
