# Roadbook Flutter — Plan 2: Auth Screens + Auth Repository

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现登录/注册界面和 Auth Repository，用户可通过登录/注册进入 App，token 和用户信息持久化到 SharedPreferences，GoRouter 自动守卫跳转。

**Architecture:** Feature-first。`features/auth/data/` 封装 Dio API 调用，密码在客户端 MD5 哈希后提交（与 Vue 版一致）；`features/auth/domain/` 提供 Riverpod Provider 管理提交状态；`features/auth/presentation/` 实现 SignIn/SignUp 两个屏幕。认证成功后调用 `authStateProvider.notifier.login()` 写入 token，GoRouter redirect 自动跳转到 `/travel`。共享 `dioProvider` 将 Dio 实例 wired 到 authState（lazy token 注入 + 401 回调）。

**Tech Stack:** Flutter (stable), flutter_riverpod ^2.5, go_router ^14, dio ^5.4, crypto ^3.0 (MD5), mocktail ^1.0

**Spec:** `docs/superpowers/specs/2026-03-20-roadbook-flutter-design.md` §5.1

> **注意：** 规范 §5.1 提到"有 `inviteToken` query param 时，登录/注册成功后转入 accept 流程"。此功能刻意推迟到实现 `/accept` 屏幕的 Plan（计划中的 flutter-04-accept）中处理，届时在 SignIn/SignUp 成功后读取 `GoRouterState` query param 并跳转。本 Plan 不处理 inviteToken。

---

## File Map

### 修改文件
- `lib/shared/models/user.dart` — 新增 `name` 字段（后端 login/register 响应含 name）
- `test/shared/models/user_test.dart` — 补充 name 字段测试
- `lib/core/router.dart` — 将 `/signin`、`/signup` 的占位屏幕替换为真实屏幕

### 新建文件
```
lib/
├── shared/providers/
│   └── dio_provider.dart                       # Dio 单例，注入 token + 401 回调
└── features/auth/
    ├── data/
    │   └── auth_repository.dart                # login/register API + MD5 哈希
    ├── domain/
    │   └── auth_provider.dart                  # authRepositoryProvider + SignIn/SignUp notifiers
    └── presentation/
        ├── sign_in_screen.dart                 # 登录 UI（表单 + 错误 SnackBar）
        └── sign_up_screen.dart                 # 注册 UI（含确认密码校验）
test/
└── features/auth/
    ├── data/
    │   └── auth_repository_test.dart           # MD5、解析、错误处理
    └── domain/
        └── auth_provider_test.dart             # provider 覆盖 + authState 验证
```

---

## Task 1: 更新 User 模型（添加 name 字段）

后端 `login`/`register` 响应的 `user` 对象含 `name` 字段，Plan 1 的 User 模型缺少此字段。

**Files:**
- Modify: `lib/shared/models/user.dart`
- Modify: `test/shared/models/user_test.dart`

- [ ] **Step 1: 在 user_test.dart 中修改现有测试 + 追加两个新测试**

**1a. 修改现有 `toJson round-trips` 测试**（`toJson` 加入 `name` 后原 expected map 不再匹配）：

将 `test('toJson round-trips', ...)` 替换为：

```dart
test('toJson round-trips', () {
  final user = User.fromJson(json);
  expect(user.toJson(), equals({...json, 'name': null}));
});
```

**1b. 在 group 末尾追加两个新测试：**

```dart
test('fromJson parses name field', () {
  final user = User.fromJson({
    'id': 1,
    'username': 'testuser',
    'avatar': null,
    'name': 'Test User',
  });
  expect(user.name, 'Test User');
});

test('fromJson handles null name', () {
  final user = User.fromJson({'id': 2, 'username': 'x', 'avatar': null});
  expect(user.name, isNull);
});
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter test test/shared/models/user_test.dart -v
```

Expected: FAIL — `name` not in User

- [ ] **Step 3: 更新 user.dart**

```dart
// lib/shared/models/user.dart
class User {
  const User({required this.id, required this.username, this.avatar, this.name});

  final int id;
  final String username;
  final String? avatar;
  final String? name;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        username: json['username'] as String,
        avatar: json['avatar'] as String?,
        name: json['name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'name': name,
      };
}
```

- [ ] **Step 4: 运行全部模型测试**

```bash
flutter test test/shared/models/ -v
```

Expected: All tests passed（5 tests — 原 3 + 2 新增）

- [ ] **Step 5: Commit**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
git add lib/shared/models/user.dart test/shared/models/user_test.dart
git commit -m "feat: add name field to User model"
```

---

## Task 2: Dio Provider

Dio 需要全局共享一个实例，`tokenProvider` 闭包在每次请求时 lazy 读取最新 token，`onUnauthorized` 触发 logout。

**Files:**
- Create: `lib/shared/providers/dio_provider.dart`

- [ ] **Step 1: 创建 dio_provider.dart**

```dart
// lib/shared/providers/dio_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../api/dio_client.dart';
import 'auth_state_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final authNotifier = ref.read(authStateProvider.notifier);

  return DioClientFactory.create(
    baseUrl: AppConstants.apiBaseUrl,
    // 每次请求时 lazy 读取当前 token，不需要 rebuild Dio
    tokenProvider: () => ref.read(authStateProvider).valueOrNull?.token,
    onUnauthorized: () => authNotifier.logout(),
  );
});
```

- [ ] **Step 2: 验证编译**

```bash
flutter analyze lib/shared/providers/dio_provider.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/shared/providers/dio_provider.dart
git commit -m "feat: add shared Dio provider wired to auth state"
```

---

## Task 3: Auth Repository

**Files:**
- Create: `lib/features/auth/data/auth_repository.dart`
- Create: `test/features/auth/data/auth_repository_test.dart`

- [ ] **Step 1: 写 auth_repository_test.dart（先写测试）**

```dart
// test/features/auth/data/auth_repository_test.dart
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/auth/data/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late Dio dio;
    late AuthRepository repo;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      repo = AuthRepository(dio);
    });

    test('login sends MD5 password and parses AuthResult', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          // 密码不是明文
          expect(body['password'], isNot('pass123'));
          // MD5 始终为 32 位十六进制
          expect((body['password'] as String).length, 32);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token': 'tok-abc',
              'user': {
                'id': 1,
                'username': 'alice',
                'avatar': null,
                'name': 'Alice'
              },
            },
          ));
        },
      ));

      final result = await repo.login('alice', 'pass123');
      expect(result.token, 'tok-abc');
      expect(result.user.username, 'alice');
      expect(result.user.name, 'Alice');
    });

    test('register sends MD5 password and parses AuthResult', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          final body = options.data as Map<String, dynamic>;
          expect((body['password'] as String).length, 32);
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'token': 'tok-xyz',
              'user': {
                'id': 2,
                'username': 'bob',
                'avatar': null,
                'name': null
              },
            },
          ));
        },
      ));

      final result = await repo.register('bob', 'secret99');
      expect(result.token, 'tok-xyz');
      expect(result.user.id, 2);
    });

    test('login throws String on DioException', () async {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 500,
              data: {'message': '用户不存在或密码错误'},
            ),
          ));
        },
      ));

      expect(() => repo.login('x', 'y'), throwsA(isA<String>()));
    });
  });
}
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
flutter test test/features/auth/data/auth_repository_test.dart -v
```

Expected: FAIL — `AuthRepository` not found

- [ ] **Step 3: 创建目录 + 实现 auth_repository.dart**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/lib/features/auth/data
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/test/features/auth/data
```

```dart
// lib/features/auth/data/auth_repository.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/models/user.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});
  final String token;
  final User user;
}

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;

  String _md5(String input) {
    final bytes = utf8.encode(input);
    return md5.convert(bytes).toString();
  }

  Future<AuthResult> login(String username, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: {'username': username, 'password': _md5(password)},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = res.data!;
      return AuthResult(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '登录失败';
    }
  }

  Future<AuthResult> register(String username, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.register,
        data: {'username': username, 'password': _md5(password)},
        options: Options(extra: {'skipAuth': true}),
      );
      final data = res.data!;
      return AuthResult(
        token: data['token'] as String,
        user: User.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String?;
      throw msg ?? '注册失败';
    }
  }
}
```

- [ ] **Step 4: 运行测试（预期通过）**

```bash
flutter test test/features/auth/data/auth_repository_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/data/auth_repository.dart test/features/auth/data/auth_repository_test.dart
git commit -m "feat: add AuthRepository with MD5 password hashing"
```

---

## Task 4: Auth Providers

**Files:**
- Create: `lib/features/auth/domain/auth_provider.dart`
- Create: `test/features/auth/domain/auth_provider_test.dart`

- [ ] **Step 1: 写 auth_provider_test.dart**

```dart
// test/features/auth/domain/auth_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadbook_flutter/features/auth/data/auth_repository.dart';
import 'package:roadbook_flutter/features/auth/domain/auth_provider.dart';
import 'package:roadbook_flutter/shared/models/user.dart';
import 'package:roadbook_flutter/shared/providers/auth_state_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {
  MockAuthRepository();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Providers', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('signIn success updates authStateProvider', () async {
      final mockRepo = MockAuthRepository();
      const result = AuthResult(
        token: 'tok-test',
        user: User(id: 1, username: 'alice', name: 'Alice'),
      );
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => result);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signInProvider.notifier).signIn('alice', 'pass');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, 'tok-test');
      expect(authState.user?.username, 'alice');
    });

    test('signIn failure leaves authState unauthenticated', () async {
      final mockRepo = MockAuthRepository();
      when(() => mockRepo.login(any(), any())).thenThrow('登录失败');

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signInProvider.notifier).signIn('bad', 'wrong');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, isNull);
    });

    test('signUp success updates authStateProvider', () async {
      final mockRepo = MockAuthRepository();
      const result = AuthResult(
        token: 'tok-new',
        user: User(id: 2, username: 'bob'),
      );
      when(() => mockRepo.register(any(), any()))
          .thenAnswer((_) async => result);

      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      addTearDown(container.dispose);

      await container.read(signUpProvider.notifier).signUp('bob', 'secret');

      final authState = await container.read(authStateProvider.future);
      expect(authState.token, 'tok-new');
    });
  });
}
```

- [ ] **Step 2: 运行测试（预期失败）**

```bash
flutter test test/features/auth/domain/auth_provider_test.dart -v
```

Expected: FAIL — `authRepositoryProvider` not found

- [ ] **Step 3: 创建目录 + 实现 auth_provider.dart**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/lib/features/auth/domain
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/test/features/auth/domain
```

```dart
// lib/features/auth/domain/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/providers/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(dioProvider));
});

// ─────────────────────────── Sign In ───────────────────────────

class SignInNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn(String username, String password) async {
    state = const AsyncLoading();
    try {
      final result =
          await ref.read(authRepositoryProvider).login(username, password);
      await ref.read(authStateProvider.notifier).login(result.token, result.user);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final signInProvider =
    AsyncNotifierProvider.autoDispose<SignInNotifier, void>(SignInNotifier.new);

// ─────────────────────────── Sign Up ───────────────────────────

class SignUpNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signUp(String username, String password) async {
    state = const AsyncLoading();
    try {
      final result =
          await ref.read(authRepositoryProvider).register(username, password);
      await ref.read(authStateProvider.notifier).login(result.token, result.user);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final signUpProvider =
    AsyncNotifierProvider.autoDispose<SignUpNotifier, void>(SignUpNotifier.new);
```

- [ ] **Step 4: 运行测试（预期通过）**

```bash
flutter test test/features/auth/domain/auth_provider_test.dart -v
```

Expected: 3 tests passed

- [ ] **Step 5: Commit**

```bash
git add lib/features/auth/domain/auth_provider.dart test/features/auth/domain/auth_provider_test.dart
git commit -m "feat: add sign-in and sign-up providers"
```

---

## Task 5: SignInScreen

**Files:**
- Create: `lib/features/auth/presentation/sign_in_screen.dart`

- [ ] **Step 1: 创建目录 + sign_in_screen.dart**

```bash
mkdir -p /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter/lib/features/auth/presentation
```

```dart
// lib/features/auth/presentation/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../domain/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(signInProvider.notifier)
        .signIn(_usernameCtrl.text.trim(), _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signInProvider);

    // 登录成功后 GoRouter redirect 自动跳转 /travel
    ref.listen(signInProvider, (_, next) {
      if (next is AsyncError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: '用户名'),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入用户名' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('登录'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('还没有账号？去注册'),
                ),
              ],
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
flutter analyze lib/features/auth/presentation/sign_in_screen.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/sign_in_screen.dart
git commit -m "feat: add SignIn screen with form validation"
```

---

## Task 6: SignUpScreen

**Files:**
- Create: `lib/features/auth/presentation/sign_up_screen.dart`

- [ ] **Step 1: 创建 sign_up_screen.dart**

```dart
// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../domain/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(signUpProvider.notifier)
        .signUp(_usernameCtrl.text.trim(), _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);

    ref.listen(signUpProvider, (_, next) {
      if (next is AsyncError && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('注册')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: '用户名'),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入用户名';
                    if (v.trim().length > 16) return '用户名最多 16 位';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(labelText: '确认密码'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _passwordCtrl.text ? '两次密码不一致' : null,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('注册'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/signin'),
                  child: const Text('已有账号？去登录'),
                ),
              ],
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
flutter analyze lib/features/auth/presentation/sign_up_screen.dart
```

Expected: No issues found!

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/presentation/sign_up_screen.dart
git commit -m "feat: add SignUp screen with password confirmation validation"
```

---

## Task 7: 连接路由到真实 Auth 屏幕

**Files:**
- Modify: `lib/core/router.dart`

- [ ] **Step 1: 替换路由中 /signin 和 /signup 的占位屏幕**

将整个 `lib/core/router.dart` 内容替换为（唯一变化：新增两个 import + 两个 GoRoute builder）：

```dart
// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_state_provider.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';

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
      GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/accept', builder: (_, __) => const _PlaceholderScreen(label: 'Accept')),
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

- [ ] **Step 2: 运行路由单元测试**

```bash
flutter test test/core/router_test.dart -v
```

Expected: 5 tests passed（守卫逻辑不受影响）

- [ ] **Step 3: Commit**

```bash
git add lib/core/router.dart
git commit -m "feat: wire real auth screens into GoRouter"
```

---

## Task 8: 全量验证

- [ ] **Step 1: flutter analyze**

```bash
cd /Users/ronny.kwok/Documents/workSpace/roadbook/roadbook_flutter
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 2: flutter test**

```bash
flutter test -v
```

Expected: All tests passed（≥ 30 tests）

---

## 完成标准

- [ ] `flutter analyze` — No issues
- [ ] `flutter test` — All tests pass（≥ 30 tests）
- [ ] `flutter run` 在模拟器启动，未登录时显示登录页，填写用户名/密码后登录成功跳转 Travel List 占位页
- [ ] 注册成功后自动登录，跳转 Travel List 占位页
- [ ] token 持久化：杀进程重启后，已登录用户直接进入 Travel List

## 下一个 Plan

`docs/superpowers/plans/2026-03-22-flutter-03-travel-list.md` — 旅程列表页（分页、搜索、旅程卡片、用户菜单）
