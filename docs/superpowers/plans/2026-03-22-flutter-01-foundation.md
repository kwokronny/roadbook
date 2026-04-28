# Roadbook Flutter — Plan 1: Foundation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建 Flutter 项目骨架，包含主题系统、数据模型、网络层、路由、Auth 状态管理，为后续所有功能模块提供基础。

**Architecture:** Feature-first 目录结构。`core/` 存放主题/路由/常量，`shared/` 存放跨功能的 API 客户端、数据模型、全局 Provider，`features/` 各功能自包含。所有网络请求经过 Dio 拦截器统一处理 token 注入和 401 重定向。

**Tech Stack:** Flutter (stable), flutter_riverpod ^2.5, riverpod_annotation ^2.3, go_router ^14, dio ^5.4, shared_preferences ^2.3, crypto ^3.0, google_fonts ^6.2, flutter_lints ^4.0, mocktail ^1.0, build_runner ^2.4

**Spec:** `docs/superpowers/specs/2026-03-20-roadbook-flutter-design.md`

---

## File Map

### 新建文件
```
roadbook-flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme.dart          # AppTheme: 所有颜色 token、TextStyle、ThemeData
│   │   ├── router.dart         # GoRouter: 路由定义 + redirect 守卫
│   │   └── constants.dart      # API base URL 等常量
│   ├── shared/
│   │   ├── api/
│   │   │   ├── dio_client.dart         # Dio 单例 + 拦截器
│   │   │   └── api_endpoints.dart      # 所有接口路径常量
│   │   ├── models/
│   │   │   ├── user.dart               # User model + fromJson/toJson
│   │   │   ├── travel.dart             # Travel model + fromJson/toJson
│   │   │   ├── schedule.dart           # Schedule model + fromJson/toJson
│   │   │   └── user_travel.dart        # UserWithRole + RoleType enum
│   │   └── providers/
│   │       └── auth_state_provider.dart  # token + userInfo 全局状态
│   └── features/
│       └── auth/
│           └── presentation/
│               └── auth_screen.dart    # 未登录占位屏幕（Task 7 前暂用）
└── test/
    ├── shared/
    │   ├── models/
    │   │   ├── user_test.dart
    │   │   ├── travel_test.dart
    │   │   └── schedule_test.dart
    │   ├── api/
    │   │   └── dio_client_test.dart
    │   └── providers/
    │       └── auth_state_provider_test.dart
    └── core/
        └── router_test.dart
```

---

## Task 1: 创建 Flutter 项目

**Files:**
- Create: `roadbook-flutter/` (项目根目录，与 `roadbook/` 同级)

- [ ] **Step 1: 创建项目**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook
flutter create --org com.roadbook --platforms ios,android roadbook-flutter
```

Expected: 生成项目骨架，`roadbook-flutter/lib/main.dart` 存在

- [ ] **Step 2: 验证项目可运行**

```bash
cd roadbook-flutter
flutter analyze
```

Expected: `No issues found!`（初始模板无问题）

- [ ] **Step 3: 删除默认内容**

删除 `lib/main.dart` 全部内容（后续 Task 写入），删除 `test/widget_test.dart`

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "chore: init flutter project skeleton"
```

---

## Task 2: 配置 pubspec.yaml

**Files:**
- Modify: `roadbook-flutter/pubspec.yaml`

- [ ] **Step 1: 替换 pubspec.yaml**

```yaml
name: roadbook_flutter
description: 小肥路书 Flutter App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # 路由
  go_router: ^14.2.0

  # 网络
  dio: ^5.4.3+1

  # 本地持久化
  shared_preferences: ^2.3.1

  # 图片
  image_picker: ^1.1.2
  flutter_image_compress: ^2.2.0

  # 工具
  intl: ^0.19.0
  crypto: ^3.0.3

  # 字体
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.3
  build_runner: ^2.4.11
  flutter_lints: ^4.0.0
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
```

- [ ] **Step 2: 安装依赖**

```bash
cd roadbook-flutter && flutter pub get
```

Expected: `Resolving dependencies... Got dependencies!`

- [ ] **Step 3: 验证无冲突**

```bash
flutter pub outdated
```

Expected: 无 breaking change 警告

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock && git commit -m "chore: add project dependencies"
```

---

## Task 3: 主题系统 (core/theme.dart)

**Files:**
- Create: `roadbook-flutter/lib/core/theme.dart`
- Create: `roadbook-flutter/lib/core/constants.dart`

- [ ] **Step 1: 创建 constants.dart**

```dart
// lib/core/constants.dart
class AppConstants {
  AppConstants._();

  /// 替换为实际后端地址，也可通过 --dart-define=API_BASE_URL=xxx 注入
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
```

- [ ] **Step 2: 创建 theme.dart**

```dart
// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppColors {
  // 背景 & 表面
  static const Color background    = Color(0xFFFDFAF6);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFF0EBE3);

  // 主色（暖橙）
  static const Color primary       = Color(0xFFF97316);
  static const Color primaryLight  = Color(0xFFFFF7ED);
  static const Color primaryBorder = Color(0xFFFED7AA);

  // 住宿色（紫）
  static const Color hotel         = Color(0xFF8B5CF6);
  static const Color hotelLight    = Color(0xFFF5F3FF);
  static const Color hotelBorder   = Color(0xFFDDD6FE);

  // 状态色
  static const Color success       = Color(0xFF16A34A);
  static const Color successLight  = Color(0xFFF0FDF4);
  static const Color neutral       = Color(0xFFA8A29E);

  // 文字
  static const Color textPrimary   = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFFA8A29E);
  static const Color textDisabled  = Color(0xFFC4B8B0);

  // 渐变（FAB、保存按钮、旅行中横幅）
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class AppTextStyles {
  static TextStyle get pageHeroTitle => GoogleFonts.dmSans(
        fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3);
  // AppBar 标题混排中英文，使用 DM Sans 保持数字/英文一致性
  static TextStyle get appBarTitle => GoogleFonts.dmSans(
        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get cardTitle => const TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get caption => const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get micro => const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
}

abstract class AppRadius {
  static const double card        = 14;
  static const double sheet       = 24;
  static const double input       = 8;
  static const double timeCell    = 6;
  static const double badge       = 20;
  static const double fab         = 14;
}

abstract class AppSpacing {
  static const double pageHorizontal = 16;
  static const double cardPadding    = 14;
  static const double cardGap        = 10;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          // background 在 Flutter 3.18+ 已废弃，统一用 surface
        ),
        fontFamily: 'PingFang SC',
        dividerColor: AppColors.border,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
      );
}
```

- [ ] **Step 3: 验证编译无错**

```bash
flutter analyze lib/core/
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/core/ && git commit -m "feat: add AppTheme color system and text styles"
```

---

## Task 4: 数据模型 (shared/models/)

**Files:**
- Create: `lib/shared/models/user.dart`
- Create: `lib/shared/models/travel.dart`
- Create: `lib/shared/models/schedule.dart`
- Create: `lib/shared/models/user_travel.dart`
- Create: `test/shared/models/user_test.dart`
- Create: `test/shared/models/travel_test.dart`
- Create: `test/shared/models/schedule_test.dart`

- [ ] **Step 1: 写 user_test.dart（先写测试）**

```dart
// test/shared/models/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/user.dart';

void main() {
  group('User', () {
    final json = {
      'id': 1,
      'username': 'testuser',
      'avatar': 'https://example.com/avatar.png',
    };

    test('fromJson parses all fields', () {
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.avatar, 'https://example.com/avatar.png');
    });

    test('fromJson handles null avatar', () {
      final user = User.fromJson({'id': 2, 'username': 'x', 'avatar': null});
      expect(user.avatar, isNull);
    });

    test('toJson round-trips', () {
      final user = User.fromJson(json);
      expect(user.toJson(), equals(json));
    });
  });
}
```

- [ ] **Step 2: 实现 user.dart**

```dart
// lib/shared/models/user.dart
class User {
  const User({required this.id, required this.username, this.avatar});

  final int id;
  final String username;
  final String? avatar;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        avatar: json['avatar'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
      };
}
```

- [ ] **Step 3: 运行 user 测试**

```bash
flutter test test/shared/models/user_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 4: 写 user_travel.dart（模型 + 枚举，无需单独测试文件）**

```dart
// lib/shared/models/user_travel.dart
import 'user.dart';

enum RoleType { manage, edit, view }

// 顶层函数，extension 不支持静态方法调用
RoleType roleTypeFromString(String s) =>
    RoleType.values.firstWhere((e) => e.name == s,
        orElse: () => RoleType.view);

class UserWithRole {
  const UserWithRole({required this.user, required this.role});

  final User user;
  final RoleType role;

  factory UserWithRole.fromJson(Map<String, dynamic> json) => UserWithRole(
        user: User.fromJson(json['user'] as Map<String, dynamic>),
        role: roleTypeFromString(json['role'] as String),
      );
}
```

- [ ] **Step 5: 写 travel_test.dart**

```dart
// test/shared/models/travel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/travel.dart';

void main() {
  group('Travel', () {
    final json = {
      'id': 10,
      'name': '上海之旅',
      'startDate': '2026-04-10',
      'endDate': '2026-04-14',
      'isPublic': false,
      'cities': '上海',
      'collaborators': [],
      'schedules': [],
      'equip': null,
    };

    test('fromJson parses cities string to list', () {
      final travel = Travel.fromJson(json);
      expect(travel.cities, ['上海']);
    });

    test('fromJson parses multi-city string', () {
      final j = Map<String, dynamic>.from(json)..['cities'] = '北京,上海';
      final travel = Travel.fromJson(j);
      expect(travel.cities, ['北京', '上海']);
    });

    test('fromJson handles empty cities', () {
      final j = Map<String, dynamic>.from(json)..['cities'] = '';
      final travel = Travel.fromJson(j);
      expect(travel.cities, isEmpty);
    });
  });
}
```

- [ ] **Step 6: 实现 travel.dart**

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
    final citiesRaw = json['cities'] as String? ?? '';
    final cities = citiesRaw.isEmpty
        ? <String>[]
        : citiesRaw.split(',').where((s) => s.isNotEmpty).toList();

    return Travel(
      id: json['id'] as int?,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      cities: cities,
      collaborators: (json['collaborators'] as List<dynamic>? ?? [])
          .map((e) => UserWithRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      schedules: (json['schedules'] as List<dynamic>? ?? [])
          .map((e) => Schedule.fromJson(e as Map<String, dynamic>))
          .toList(),
      equip: json['equip'] as String?,
    );
  }
}
```

- [ ] **Step 7: 运行 travel 测试**

```bash
flutter test test/shared/models/travel_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 8: 写 schedule_test.dart**

```dart
// test/shared/models/schedule_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/shared/models/schedule.dart';

void main() {
  group('Schedule', () {
    final json = {
      'id': 5,
      'tId': 10,
      'name': '外滩观光隧道',
      'coordinate': '121.489,31.233',
      'address': '上海市黄浦区中山东二路479号',
      'cover': 'https://img.example.com/cover.jpg',
      'dianpingUUID': null,
      'isHotel': false,
      'startTime': '2026-04-10 09:00:00',
      'endTime': null,
      'screenshots': 'url1,url2',
      'notes': null,
    };

    test('fromJson parses basic fields', () {
      final s = Schedule.fromJson(json);
      expect(s.name, '外滩观光隧道');
      expect(s.isHotel, isFalse);
    });

    test('screenshotList splits comma-separated string', () {
      final s = Schedule.fromJson(json);
      expect(s.screenshotList, ['url1', 'url2']);
    });

    test('screenshotList returns empty list when null', () {
      final j = Map<String, dynamic>.from(json)..['screenshots'] = null;
      final s = Schedule.fromJson(j);
      expect(s.screenshotList, isEmpty);
    });

    test('screenshotList ignores empty segments', () {
      final j = Map<String, dynamic>.from(json)..['screenshots'] = 'url1,,url2';
      final s = Schedule.fromJson(j);
      expect(s.screenshotList, ['url1', 'url2']);
    });
  });
}
```

- [ ] **Step 9: 实现 schedule.dart**

```dart
// lib/shared/models/schedule.dart
class Schedule {
  const Schedule({
    this.id,
    required this.tId,
    required this.name,
    required this.coordinate,
    required this.address,
    this.cover,
    this.dianpingUUID,
    required this.isHotel,
    this.startTime,
    this.endTime,
    this.screenshots,
    this.notes,
  });

  final int? id;
  final int tId;
  final String name;
  final String coordinate;
  final String address;
  final String? cover;
  final String? dianpingUUID;
  final bool isHotel;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? screenshots;
  final String? notes;

  List<String> get screenshotList {
    if (screenshots == null || screenshots!.isEmpty) return [];
    return screenshots!.split(',').where((s) => s.isNotEmpty).toList();
  }

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] as int?,
        tId: json['tId'] as int,
        name: json['name'] as String,
        coordinate: json['coordinate'] as String,
        address: json['address'] as String,
        cover: json['cover'] as String?,
        dianpingUUID: json['dianpingUUID'] as String?,
        isHotel: json['isHotel'] as bool? ?? false,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        screenshots: json['screenshots'] as String?,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'tId': tId,
        'name': name,
        'coordinate': coordinate,
        'address': address,
        'cover': cover,
        'dianpingUUID': dianpingUUID,
        'isHotel': isHotel,
        'startTime': startTime?.toString(),
        'endTime': endTime?.toString(),
        'screenshots': screenshots,
        'notes': notes,
      };
}
```

- [ ] **Step 10: 运行全部模型测试**

```bash
flutter test test/shared/models/ -v
```

Expected: 10 tests passed

- [ ] **Step 11: Commit**

```bash
git add lib/shared/models/ test/shared/models/ && git commit -m "feat: add data models with serialization"
```

---

## Task 5: 网络层 (shared/api/)

**Files:**
- Create: `lib/shared/api/api_endpoints.dart`
- Create: `lib/shared/api/dio_client.dart`
- Create: `test/shared/api/dio_client_test.dart`

- [ ] **Step 1: 创建 api_endpoints.dart**

```dart
// lib/shared/api/api_endpoints.dart
abstract class ApiEndpoints {
  // Auth
  static const String login          = '/api/user/login';
  static const String register       = '/api/user/register';
  static const String userDetail     = '/api/user/detail';
  static const String userUpdate     = '/api/user/update';
  static const String passwordModify = '/api/user/password/modify';

  // Travel
  static const String travelPage    = '/api/travel/page';
  static const String travelDetail  = '/api/travel/detail';
  static const String travelSave    = '/api/travel/save';
  static const String travelRemove  = '/api/travel/remove';
  static const String travelInvite  = '/api/travel/invite';
  static const String travelAccept  = '/api/travel/accept';
  static const String travelSetRole = '/api/travel/set_role';

  // Schedule
  static const String scheduleList   = '/api/travel/schedule/list';
  static const String scheduleAdd    = '/api/travel/schedule/add';
  static const String scheduleUpdate = '/api/travel/schedule/update';
  static const String scheduleRemove = '/api/travel/schedule/remove';
  static const String scheduleClone  = '/api/travel/schedule/clone';

  // Upload
  static const String upload = '/upload';
}
```

- [ ] **Step 2: 写 dio_client_test.dart（先写测试）**

```dart
// test/shared/api/dio_client_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:roadbook_flutter/shared/api/dio_client.dart';

// 测试用假 token 提供器
String? _mockToken;

Dio buildTestDio(String baseUrl) =>
    DioClientFactory.create(baseUrl: baseUrl, tokenProvider: () => _mockToken);

void main() {
  group('DioClient interceptor', () {
    late Dio dio;

    setUp(() {
      _mockToken = null;
      dio = buildTestDio('http://localhost');
    });

    test('injects Authorization header when token is present', () async {
      _mockToken = 'test-token';
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options)); // 不真正发请求
        },
      ));

      try {
        await dio.post('/test');
      } catch (_) {}

      expect(captured?.headers['Authorization'], 'Bearer test-token');
    });

    test('does not inject Authorization when token is null', () async {
      _mockToken = null;
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options));
        },
      ));

      try {
        await dio.post('/test');
      } catch (_) {}

      expect(captured?.headers.containsKey('Authorization'), isFalse);
    });

    test('skipAuth extra skips token injection', () async {
      _mockToken = 'test-token';
      RequestOptions? captured;

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options;
          handler.reject(DioException(requestOptions: options));
        },
      ));

      try {
        await dio.post('/test', options: Options(extra: {'skipAuth': true}));
      } catch (_) {}

      expect(captured?.headers.containsKey('Authorization'), isFalse);
    });
  });
}
```

- [ ] **Step 3: 运行测试（预期失败）**

```bash
flutter test test/shared/api/dio_client_test.dart -v
```

Expected: FAIL — `DioClientFactory` not found

- [ ] **Step 4: 实现 dio_client.dart**

```dart
// lib/shared/api/dio_client.dart
import 'package:dio/dio.dart';

typedef TokenProvider = String? Function();
typedef OnUnauthorized = void Function();

abstract class DioClientFactory {
  /// [tokenProvider] 返回当前 token，null 时不注入 Authorization。
  /// [onUnauthorized] 收到 401 时调用（通常清空 token 并跳登录页）。
  static Dio create({
    required String baseUrl,
    required TokenProvider tokenProvider,
    OnUnauthorized? onUnauthorized,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    dio.interceptors.add(_AuthInterceptor(
      tokenProvider: tokenProvider,
      onUnauthorized: onUnauthorized,
    ));

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.tokenProvider, this.onUnauthorized});

  final TokenProvider tokenProvider;
  final OnUnauthorized? onUnauthorized;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = tokenProvider();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 解包 { code, data, message } 结构
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      response.data = data['data'];
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}
```

- [ ] **Step 5: 运行测试（预期通过）**

```bash
flutter test test/shared/api/dio_client_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 6: Commit**

```bash
git add lib/shared/api/ test/shared/api/ && git commit -m "feat: add Dio client with auth interceptor"
```

---

## Task 6: Auth 状态管理 (shared/providers/)

**Files:**
- Create: `lib/shared/providers/auth_state_provider.dart`
- Create: `test/shared/providers/auth_state_provider_test.dart`

- [ ] **Step 1: 写 auth_state_provider_test.dart**

```dart
// test/shared/providers/auth_state_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthStateNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is unauthenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = await container.read(authStateProvider.future);
      expect(state.token, isNull);
      expect(state.user, isNull);
    });

    test('login stores token and user', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const token = 'abc123';
      const user = User(id: 1, username: 'testuser');

      await container.read(authStateProvider.notifier).login(token, user);
      final state = await container.read(authStateProvider.future);

      expect(state.token, token);
      expect(state.user?.id, 1);
    });

    test('logout clears token and user', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authStateProvider.notifier).login(
            'tok', const User(id: 1, username: 'u'));
      await container.read(authStateProvider.notifier).logout();

      final state = await container.read(authStateProvider.future);
      expect(state.token, isNull);
      expect(state.user, isNull);
    });
  });
}
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
flutter test test/shared/providers/auth_state_provider_test.dart -v
```

Expected: FAIL — `authStateProvider` not found

- [ ] **Step 3: 实现 auth_state_provider.dart**

```dart
// lib/shared/providers/auth_state_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthState {
  const AuthState({this.token, this.user});
  final String? token;
  final User? user;
  bool get isAuthenticated => token != null;
}

class AuthStateNotifier extends AsyncNotifier<AuthState> {
  static const _tokenKey = 'auth_token';
  static const _userKey  = 'auth_user';

  @override
  Future<AuthState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return const AuthState();
    final user = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    return AuthState(token: token, user: user);
  }

  Future<void> login(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = AsyncData(AuthState(token: token, user: user));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    state = const AsyncData(AuthState());
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, AuthState>(AuthStateNotifier.new);
```

- [ ] **Step 4: 运行测试（预期通过）**

```bash
flutter test test/shared/providers/auth_state_provider_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 5: Commit**

```bash
git add lib/shared/providers/ test/shared/providers/ && git commit -m "feat: add auth state provider with SharedPreferences persistence"
```

---

## Task 7: 路由 (core/router.dart)

**Files:**
- Create: `lib/core/router.dart`
- Create: `test/core/router_test.dart`

- [ ] **Step 1: 写 router_test.dart**

```dart
// test/core/router_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/core/router.dart';

void main() {
  group('RouterGuard.redirect', () {
    test('unauthenticated user going to /travel redirects to /signin', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/travel',
      );
      expect(result, '/signin');
    });

    test('unauthenticated user going to /signin is allowed', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/signin',
      );
      expect(result, isNull);
    });

    test('authenticated user going to /signin redirects to /travel', () {
      final result = RouterGuard.computeRedirect(
        token: 'tok',
        location: '/signin',
      );
      expect(result, '/travel');
    });

    test('authenticated user going to /travel is allowed', () {
      final result = RouterGuard.computeRedirect(
        token: 'tok',
        location: '/travel',
      );
      expect(result, isNull);
    });

    test('/accept is public (no token required)', () {
      final result = RouterGuard.computeRedirect(
        token: null,
        location: '/accept',
      );
      expect(result, isNull);
    });
  });
}
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
flutter test test/core/router_test.dart -v
```

Expected: FAIL

- [ ] **Step 3: 实现 router.dart**

```dart
// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_state_provider.dart';

// 公开路由（无 token 也可访问）
const _publicRoutes = {'/signin', '/signup', '/accept'};

abstract class RouterGuard {
  /// 纯函数，方便单元测试
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
  final authAsync = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/travel',
    redirect: (context, state) {
      final token = authAsync.valueOrNull?.token;
      return RouterGuard.computeRedirect(
        token: token,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(path: '/signin',  builder: (_, __) => const _PlaceholderScreen(label: 'Sign In')),
      GoRoute(path: '/signup',  builder: (_, __) => const _PlaceholderScreen(label: 'Sign Up')),
      GoRoute(path: '/accept',  builder: (_, __) => const _PlaceholderScreen(label: 'Accept')),
      GoRoute(
        path: '/travel',
        builder: (_, __) => const _PlaceholderScreen(label: 'Travel List'),
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

/// 占位屏幕，在后续 Plan 中逐步替换为真实实现
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text(label, style: const TextStyle(fontSize: 18))),
      );
}
```

- [ ] **Step 4: 运行路由测试**

```bash
flutter test test/core/router_test.dart -v
```

Expected: 5 tests passed

- [ ] **Step 5: Commit**

```bash
git add lib/core/router.dart test/core/router_test.dart && git commit -m "feat: add GoRouter with auth redirect guard"
```

---

## Task 8: 组装 app.dart 和 main.dart

**Files:**
- Create: `lib/app.dart`
- Create: `lib/main.dart`

- [ ] **Step 1: 创建 app.dart**

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme.dart';

class RoadbookApp extends ConsumerWidget {
  const RoadbookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '小肥路书',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- [ ] **Step 2: 创建 main.dart**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runApp(const ProviderScope(child: RoadbookApp()));
}
```

- [ ] **Step 3: 全量分析**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: 运行所有测试**

```bash
flutter test -v
```

Expected: All tests passed（≥ 14 tests）

- [ ] **Step 5: Final commit**

```bash
git add lib/app.dart lib/main.dart && git commit -m "feat: wire up app entrypoint with ProviderScope and GoRouter"
```

---

## 完成标准

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — All tests pass
- [ ] `flutter run` 可在模拟器/真机启动，显示 `Travel List` 占位文字
- [ ] 修改 `constants.dart` 中 `apiBaseUrl` 为实际后端地址后，Dio 拦截器能正常注入 token

## 下一个 Plan

`docs/superpowers/plans/2026-03-22-flutter-02-auth.md` — 实现登录/注册界面和 Auth Repository
