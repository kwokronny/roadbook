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
  // GoRouter 保持单实例；auth 变化时通过 refreshListenable 触发 redirect 重新评估
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
