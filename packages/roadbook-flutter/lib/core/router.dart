// lib/core/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/providers/auth_state_provider.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/travel/presentation/travel_list_screen.dart';
import '../features/travel/presentation/travel_detail_screen.dart';
import '../features/main/presentation/main_shell.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/profile/presentation/api_keys_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/luggage/presentation/luggage_screen.dart';

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

/// Slide + fade transition matching Frosted Warmth spec:
/// Push: new page slides in from right + fades in; old page slides left + fades out
/// Pop: reverse
CustomTransitionPage<void> _fadeSlide({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Incoming page: slide from right + fade in
      final slideIn = Tween<Offset>(
        begin: const Offset(0.25, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: const Cubic(0.22, 0.0, 0.36, 1), // ease-out
      ));

      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      );

      // Outgoing page (when this page is being covered): slide left + fade out
      final slideOut = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-0.15, 0),
      ).animate(CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Cubic(0.22, 0.0, 0.36, 1),
      ));

      final fadeOut = Tween<double>(begin: 1.0, end: 0.6).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut),
      );

      return SlideTransition(
        position: slideOut,
        child: FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(
              opacity: fadeIn,
              child: child,
            ),
          ),
        ),
      );
    },
  );
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
      GoRoute(
        path: '/signin',
        pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const SignInScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const SignUpScreen()),
      ),
      GoRoute(
        path: '/accept',
        pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const _PlaceholderScreen(label: 'Accept')),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/travel',
              builder: (_, __) => const TravelListScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (_, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return _fadeSlide(key: state.pageKey, child: TravelDetailScreen(travelId: id));
                  },
                  routes: [
                    GoRoute(
                      path: 'luggage',
                      pageBuilder: (_, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return _fadeSlide(key: state.pageKey, child: LuggageScreen(travelId: id));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/discover',
              builder: (_, __) => const DiscoverScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const EditProfileScreen()),
                ),
                GoRoute(
                  path: 'settings',
                  pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const SettingsScreen()),
                ),
                GoRoute(
                  path: 'api-keys',
                  pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const ApiKeysScreen()),
                ),
                GoRoute(
                  path: 'change-password',
                  pageBuilder: (_, state) => _fadeSlide(key: state.pageKey, child: const ChangePasswordScreen()),
                ),
              ],
            ),
          ]),
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
        body: Center(child: Text(label, style: const TextStyle(fontSize: 20))),
      );
}
