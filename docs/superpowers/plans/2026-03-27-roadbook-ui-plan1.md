# Plan 1: Core Design System + Navigation + Travel UI + Auth Redesign

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace design tokens with the iOS+Klook spec, wire up 3-tab MainShell navigation (旅程·发现·我的), rewrite TravelCard with 4-status gradient cards, rewrite TravelListScreen with iOS Large Title, add luggage menu entry to TravelDetailScreen, and redesign the auth screens.

**Architecture:** `theme.dart` is the single source of truth for all visual tokens. `MainShell` wraps go_router's `StatefulShellRoute.indexedStack` with three branches; placeholder screens for 发现 and 我的 are wired up now and replaced in Plans 2 & 3. All rewritten screens retain their existing Riverpod provider logic — only the widget tree changes.

**Tech Stack:** Flutter · Riverpod (ConsumerStatefulWidget) · go_router (StatefulShellRoute) · intl (DateFormat)

---

### Task 1: Update Design Tokens

**Files:**
- Modify: `packages/roadbook-flutter/lib/core/theme.dart`

- [ ] **Step 1: Establish baseline — run existing tests**

```bash
cd packages/roadbook-flutter
flutter test test/core/router_test.dart
```
Expected: all 5 tests PASS.

- [ ] **Step 2: Replace `theme.dart` entirely**

```dart
// lib/core/theme.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFFFF5B2E); // coral orange
  static const Color primaryLight = Color(0xFFFFEFEB); // light tint for bg/selections
  static const Color primaryBorder = Color(0xFFFFCBBD); // matching border

  // ─── Backgrounds ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF2F2F7); // iOS system gray
  static const Color surface    = Color(0xFFFFFFFF);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFFC7C7CC);
  static const Color textDisabled  = Color(0xFFC7C7CC); // alias

  // ─── Borders & Separators ────────────────────────────────────────────────
  static const Color border    = Color(0xFFE5E5EA); // iOS gray5 — used by preserved sheets
  static const Color separator = Color(0x1A3C3C43); // rgba(60,60,67,0.1) for 0.5px dividers

  // ─── Semantic ────────────────────────────────────────────────────────────
  static const Color destructive  = Color(0xFFFF3B30);
  static const Color success      = Color(0xFF34C759);
  static const Color successLight = Color(0xFFEAFFF0);
  static const Color neutral      = Color(0xFF8E8E93);

  // ─── Hotel (preserved) ───────────────────────────────────────────────────
  static const Color hotel       = Color(0xFF8B5CF6);
  static const Color hotelLight  = Color(0xFFF5F3FF);
  static const Color hotelBorder = Color(0xFFDDD6FE);

  // ─── Schedule "unplanned" dot (preserved) ────────────────────────────────
  static const Color unplanned      = Color(0xFFD4C8BF);
  static const Color unplannedLight = Color(0xFFEDE8E3);

  // ─── Travel status gradients (cards only) ────────────────────────────────
  static const LinearGradient ongoingGradient = LinearGradient(
    colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient upcomingGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient planningGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient endedGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Primary gradient (main buttons / FABs) ──────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF5B2E), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

abstract class AppTextStyles {
  // iOS-spec sizes
  static const TextStyle largeTitle = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const TextStyle appBarTitle = TextStyle(
      fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get subheadline => const TextStyle(
      fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get caption => const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get micro => const TextStyle(
      fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  // Aliases kept for preserved components
  static TextStyle get pageHeroTitle => largeTitle;
  static TextStyle get cardTitle => const TextStyle(
      fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

abstract class AppRadius {
  static const double card        = 14; // status gradient cards
  static const double contentCard = 12; // white content cards (discover, profile menus)
  static const double sheet       = 24;
  static const double input       = 10;
  static const double badge       =  6;
  static const double iconBox     =  6;
  static const double fab         = 14; // kept for preserved sheets that use gradient FAB containers
  static const double timeCell    =  6; // kept for schedule_timeline_item
}

abstract class AppSpacing {
  static const double pageHorizontal = 16;
  static const double cardPadding    = 12;
  static const double cardGap        =  8;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'PingFang SC',
        dividerColor: AppColors.separator,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: AppTextStyles.appBarTitle,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
      );
}
```

- [ ] **Step 3: Verify no compilation errors**

```bash
cd packages/roadbook-flutter
flutter analyze lib/
```
Expected: 0 errors. Warnings about deprecated Flutter APIs are OK. Fix any `Undefined name` errors by checking which removed constant is referenced.

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/lib/core/theme.dart
git commit -m "feat(theme): replace design tokens — iOS #F2F2F7 bg, coral #FF5B2E primary, 4 status gradients"
```

---

### Task 2: Create MainShell + Placeholder Tab Screens

**Files:**
- Create: `packages/roadbook-flutter/lib/features/main/presentation/main_shell.dart`
- Create: `packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart`
- Create: `packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart`

- [ ] **Step 1: Create discover placeholder**

Create file `packages/roadbook-flutter/lib/features/discover/presentation/discover_screen.dart`:

```dart
// lib/features/discover/presentation/discover_screen.dart
//
// Placeholder — full implementation in Plan 2.
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('发现', style: AppTextStyles.largeTitle),
              const SizedBox(height: 24),
              Center(
                child: Text('发现页 — 即将推出',
                    style: AppTextStyles.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create profile placeholder**

Create file `packages/roadbook-flutter/lib/features/profile/presentation/profile_screen.dart`:

```dart
// lib/features/profile/presentation/profile_screen.dart
//
// Placeholder — full implementation in Plan 3.
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('我的', style: AppTextStyles.largeTitle),
              const SizedBox(height: 24),
              Center(
                child: Text('我的页 — 即将推出',
                    style: AppTextStyles.caption),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create MainShell**

Create file `packages/roadbook-flutter/lib/features/main/presentation/main_shell.dart`:

```dart
// lib/features/main/presentation/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

// ─── Bottom navigation bar ────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  static const _tabs = [
    _TabItem(outlinedIcon: Icons.map_outlined,     filledIcon: Icons.map,     label: '旅程'),
    _TabItem(outlinedIcon: Icons.explore_outlined,  filledIcon: Icons.explore,  label: '发现'),
    _TabItem(outlinedIcon: Icons.person_outline,    filledIcon: Icons.person,   label: '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xF0F9F9F9), // rgba(249,249,249,0.94) — frosted glass approximation
        border: Border(
          top: BorderSide(color: Color(0x1A000000), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.filledIcon : tab.outlinedIcon,
                        size: 24,
                        color: selected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tab.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
  });
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String label;
}
```

- [ ] **Step 4: Verify new files compile**

```bash
cd packages/roadbook-flutter
flutter analyze lib/features/main/ lib/features/discover/ lib/features/profile/
```
Expected: 0 errors.

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/main/ \
        packages/roadbook-flutter/lib/features/discover/ \
        packages/roadbook-flutter/lib/features/profile/
git commit -m "feat(nav): add MainShell 3-tab bottom nav + placeholder Discover/Profile screens"
```

---

### Task 3: Update router.dart — StatefulShellRoute + new route tests

**Files:**
- Modify: `packages/roadbook-flutter/lib/core/router.dart`
- Modify: `packages/roadbook-flutter/test/core/router_test.dart`

- [ ] **Step 1: Add failing tests for the two new protected routes**

In `packages/roadbook-flutter/test/core/router_test.dart`, append inside the existing `group`:

```dart
test('unauthenticated user going to /discover redirects to /signin', () {
  final result = RouterGuard.computeRedirect(token: null, location: '/discover');
  expect(result, '/signin');
});

test('unauthenticated user going to /profile redirects to /signin', () {
  final result = RouterGuard.computeRedirect(token: null, location: '/profile');
  expect(result, '/signin');
});

test('authenticated user going to /discover is allowed', () {
  final result = RouterGuard.computeRedirect(token: 'tok', location: '/discover');
  expect(result, isNull);
});

test('authenticated user going to /profile is allowed', () {
  final result = RouterGuard.computeRedirect(token: 'tok', location: '/profile');
  expect(result, isNull);
});
```

- [ ] **Step 2: Run tests — new 4 should PASS (logic unchanged, /discover and /profile are already protected)**

```bash
cd packages/roadbook-flutter
flutter test test/core/router_test.dart
```
Expected: all 9 tests PASS. `RouterGuard.computeRedirect` needs no change — /discover and /profile are not in `_publicRoutes`, so they redirect to /signin when unauthenticated. The tests should pass immediately.

- [ ] **Step 3: Rewrite `router.dart` to use StatefulShellRoute**

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
import '../features/main/presentation/main_shell.dart';
import '../features/discover/presentation/discover_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

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
                  builder: (_, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return TravelDetailScreen(travelId: id);
                  },
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
```

- [ ] **Step 4: Run all tests**

```bash
cd packages/roadbook-flutter
flutter test test/core/router_test.dart
```
Expected: all 9 tests PASS.

- [ ] **Step 5: Run the app and verify 3 tabs appear**

```bash
cd packages/roadbook-flutter
flutter run
```
Expected: bottom nav shows 旅程 / 发现 / 我的. Tapping 发现 and 我的 shows placeholder text. Sign-in redirect still works when token is absent.

- [ ] **Step 6: Commit**

```bash
git add packages/roadbook-flutter/lib/core/router.dart \
        packages/roadbook-flutter/test/core/router_test.dart
git commit -m "feat(router): migrate to StatefulShellRoute — 3-tab shell with /travel /discover /profile"
```

---

### Task 4: Rewrite TravelCard — 4-status gradient cards

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/travel/presentation/widgets/travel_card.dart`
- Create: `packages/roadbook-flutter/test/features/travel/presentation/widgets/travel_card_test.dart`

- [ ] **Step 1: Write failing tests for the new `computeTravelStatus` logic**

Create file `packages/roadbook-flutter/test/features/travel/presentation/widgets/travel_card_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:roadbook_flutter/features/travel/presentation/widgets/travel_card.dart';

void main() {
  // Helper: build a DateTime that is N days from today (floor to day boundary)
  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  DateTime daysFromNow(int n) => today().add(Duration(days: n));

  group('computeTravelStatus', () {
    test('today equals startDate → ongoing', () {
      final start = today();
      final end = daysFromNow(3);
      expect(computeTravelStatus(start, end), TravelStatus.ongoing);
    });

    test('today equals endDate → ongoing', () {
      final start = daysFromNow(-3);
      final end = today();
      expect(computeTravelStatus(start, end), TravelStatus.ongoing);
    });

    test('today is between start and end → ongoing', () {
      final start = daysFromNow(-2);
      final end = daysFromNow(2);
      expect(computeTravelStatus(start, end), TravelStatus.ongoing);
    });

    test('endDate before today → ended', () {
      final start = daysFromNow(-5);
      final end = daysFromNow(-1);
      expect(computeTravelStatus(start, end), TravelStatus.ended);
    });

    test('startDate 3 days from now → upcoming', () {
      final start = daysFromNow(3);
      final end = daysFromNow(7);
      expect(computeTravelStatus(start, end), TravelStatus.upcoming);
    });

    test('startDate exactly 7 days from now → upcoming (boundary)', () {
      final start = daysFromNow(7);
      final end = daysFromNow(10);
      expect(computeTravelStatus(start, end), TravelStatus.upcoming);
    });

    test('startDate 8 days from now → planning', () {
      final start = daysFromNow(8);
      final end = daysFromNow(12);
      expect(computeTravelStatus(start, end), TravelStatus.planning);
    });

    test('startDate 30 days from now → planning', () {
      final start = daysFromNow(30);
      final end = daysFromNow(35);
      expect(computeTravelStatus(start, end), TravelStatus.planning);
    });
  });
}
```

- [ ] **Step 2: Run tests — expect FAIL**

```bash
cd packages/roadbook-flutter
flutter test test/features/travel/presentation/widgets/travel_card_test.dart
```
Expected: `planning` cases FAIL (enum value `planning` doesn't exist yet) and `upcoming`/`ended` boundary cases may fail.

- [ ] **Step 3: Rewrite `travel_card.dart`**

```dart
// lib/features/travel/presentation/widgets/travel_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/travel.dart';

// ─── Status enum (4 states) ──────────────────────────────────────────────────

enum TravelStatus { ongoing, upcoming, planning, ended }

TravelStatus computeTravelStatus(DateTime start, DateTime end) {
  final now = DateTime.now();
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay   = DateTime(end.year,   end.month,   end.day);
  final today    = DateTime(now.year,   now.month,   now.day);

  // startDay ≤ today ≤ endDay
  if (!today.isBefore(startDay) && !today.isAfter(endDay)) return TravelStatus.ongoing;
  if (today.isAfter(endDay))                                return TravelStatus.ended;
  // today < startDay
  final daysUntil = startDay.difference(today).inDays;
  return daysUntil <= 7 ? TravelStatus.upcoming : TravelStatus.planning;
}

// ─── TravelCard ──────────────────────────────────────────────────────────────

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
    final status   = computeTravelStatus(travel.startDate, travel.endDate);
    final gradient = _gradientFor(status);
    final days     = travel.endDate.difference(travel.startDate).inDays + 1;
    final fmt      = DateFormat('MM/dd');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // ── Left icon box ──────────────────────────────────────────
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_iconFor(status), color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),

              // ── Content ───────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      travel.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Cities
                    if (travel.cities.isNotEmpty)
                      Text(
                        travel.cities.join(' · '),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.75)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // Date + badge row
                    Row(
                      children: [
                        Text(
                          '${fmt.format(travel.startDate)} — ${fmt.format(travel.endDate)}  ·  $days 天',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius:
                                BorderRadius.circular(AppRadius.badge),
                          ),
                          child: Text(
                            _labelFor(status),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── More menu ─────────────────────────────────────────────
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      size: 18, color: Colors.white.withOpacity(0.8)),
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
        ),
      ),
    );
  }

  static LinearGradient _gradientFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => AppColors.ongoingGradient,
        TravelStatus.upcoming  => AppColors.upcomingGradient,
        TravelStatus.planning  => AppColors.planningGradient,
        TravelStatus.ended     => AppColors.endedGradient,
      };

  static IconData _iconFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => Icons.flight_takeoff_outlined,
        TravelStatus.upcoming  => Icons.access_time_outlined,
        TravelStatus.planning  => Icons.map_outlined,
        TravelStatus.ended     => Icons.check_circle_outline,
      };

  static String _labelFor(TravelStatus status) => switch (status) {
        TravelStatus.ongoing   => '旅行中',
        TravelStatus.upcoming  => '即将出发',
        TravelStatus.planning  => '规划中',
        TravelStatus.ended     => '已结束',
      };
}
```

- [ ] **Step 4: Run tests — expect all PASS**

```bash
cd packages/roadbook-flutter
flutter test test/features/travel/presentation/widgets/travel_card_test.dart
```
Expected: all 8 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add packages/roadbook-flutter/lib/features/travel/presentation/widgets/travel_card.dart \
        packages/roadbook-flutter/test/features/travel/presentation/widgets/travel_card_test.dart
git commit -m "feat(travel-card): 4-status gradient cards — add planning state, remove _StatusBadge"
```

---

### Task 5: Rewrite TravelListScreen

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/travel/presentation/travel_list_screen.dart`

- [ ] **Step 1: Replace `travel_list_screen.dart` entirely**

```dart
// lib/features/travel/presentation/travel_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/models/travel.dart';
import '../domain/travel_list_provider.dart';
import 'widgets/travel_card.dart';
import 'widgets/travel_form_sheet.dart';

class TravelListScreen extends ConsumerStatefulWidget {
  const TravelListScreen({super.key});

  @override
  ConsumerState<TravelListScreen> createState() => _TravelListScreenState();
}

class _TravelListScreenState extends ConsumerState<TravelListScreen> {
  final _scrollCtrl  = ScrollController();
  final _searchCtrl  = TextEditingController();
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
    final state = ref.read(travelListProvider).valueOrNull;
    if (state == null || !state.hasMore || state.isLoadingMore) return;
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
              child: const Text('删除',
                  style: TextStyle(color: AppColors.destructive))),
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
    final listAsync = ref.watch(travelListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Large Title ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 20, AppSpacing.pageHorizontal, 0),
              child: Text('我的旅程', style: AppTextStyles.largeTitle),
            ),
            const SizedBox(height: 12),

            // ── iOS-style search bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageHorizontal),
              child: _IosSearchBar(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 12),

            // ── Travel list ───────────────────────────────────────────────
            Expanded(
              child: listAsync.when(
                loading: () => const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.toString(), style: AppTextStyles.caption),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary),
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
                          Icon(Icons.map_outlined,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('暂无旅程，点击 ＋ 开始规划',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(travelListProvider.notifier).refresh(),
                    child: ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal, vertical: 4),
                      itemCount: state.items.length +
                          (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.primary)),
                          );
                        }
                        final travel = state.items[index];
                        return TravelCard(
                          travel: travel,
                          onTap: () => context.go('/travel/${travel.id}'),
                          onEdit: () =>
                              TravelFormSheet.show(context, travel: travel),
                          onDelete: travel.id != null
                              ? () => _confirmDelete(travel.id!, travel.name)
                              : null,
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

      // ── Circle FAB ─────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () => TravelFormSheet.show(context),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─── iOS-style capsule search bar ────────────────────────────────────────────

class _IosSearchBar extends StatelessWidget {
  const _IosSearchBar({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0x1E767680), // rgba(118,118,128,0.12)
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.search,
                size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '搜索',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary, fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: controller.text.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.cancel,
                    size: 16, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run the app and verify**

```bash
cd packages/roadbook-flutter
flutter run
```
Expected: 旅程 tab shows large "我的旅程" title (34px), iOS capsule search bar, gradient status cards, no _OngoingBanner, circle orange FAB at bottom-right.

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-flutter/lib/features/travel/presentation/travel_list_screen.dart
git commit -m "feat(travel-list): iOS Large Title, capsule search bar, circle FAB, remove OngoingBanner"
```

---

### Task 6: Update TravelDetailScreen — circle FAB + 行李清单 menu entry

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/travel/presentation/travel_detail_screen.dart`

The AppBar background updates automatically from the theme change (Task 1). Only two widget-level changes are needed: (1) replace the gradient Container+FAB with a simple circular FAB, (2) add 行李清单 to the more menu.

- [ ] **Step 1: Replace `_buildFab` and add 行李清单 to `_buildMoreMenu`**

In `travel_detail_screen.dart`, make the following targeted edits:

**Replace `_buildMoreMenu`** (the whole method, starting at the `itemBuilder:` line for the menu items):

```dart
  Widget _buildMoreMenu(BuildContext context,
      {required Travel travel, required bool canManage}) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 22),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      color: AppColors.surface,
      elevation: 4,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            TravelFormSheet.show(context, travel: travel);
          case 'collaborator':
            CollaboratorSheet.show(context, widget.travelId);
          case 'import':
            CollectImportSheet.show(context, widget.travelId);
          case 'luggage':
            // Luggage screen implemented in Plan 4
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('行李清单 — 即将推出')),
            );
        }
      },
      itemBuilder: (_) => [
        if (canManage)
          const PopupMenuItem(
            value: 'edit',
            height: 44,
            child: Row(children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('编辑旅程'),
            ]),
          ),
        if (canManage)
          const PopupMenuItem(
            value: 'collaborator',
            height: 44,
            child: Row(children: [
              Icon(Icons.group_outlined,
                  size: 18, color: AppColors.textPrimary),
              SizedBox(width: 10),
              Text('协作者管理'),
            ]),
          ),
        const PopupMenuItem(
          value: 'import',
          height: 44,
          child: Row(children: [
            Icon(Icons.download_outlined,
                size: 18, color: AppColors.textPrimary),
            SizedBox(width: 10),
            Text('批量导入'),
          ]),
        ),
        const PopupMenuItem(
          value: 'luggage',
          height: 44,
          child: Row(children: [
            Icon(Icons.luggage_outlined,
                size: 18, color: AppColors.textPrimary),
            SizedBox(width: 10),
            Text('行李清单'),
          ]),
        ),
      ],
    );
  }
```

**Replace `_buildFab`**:

```dart
  Widget _buildFab(BuildContext context, Travel travel) {
    return FloatingActionButton(
      onPressed: () {
        setState(() => _currentTab = 1);
        ref
            .read(mapStateProvider(widget.travelId).notifier)
            .enterSearchMode();
      },
      backgroundColor: AppColors.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
```

- [ ] **Step 2: Run the app and verify**

```bash
cd packages/roadbook-flutter
flutter run
```
Expected: TravelDetailScreen AppBar has `#F2F2F7` background. FAB is a solid coral circle. More menu shows 行李清单 item; tapping it shows "即将推出" snackbar.

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-flutter/lib/features/travel/presentation/travel_detail_screen.dart
git commit -m "feat(travel-detail): circle FAB, add 行李清单 menu entry (placeholder)"
```

---

### Task 7: Rewrite SignInScreen

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/auth/presentation/sign_in_screen.dart`

- [ ] **Step 1: Replace `sign_in_screen.dart` entirely**

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
  final _formKey      = GlobalKey<FormState>();
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

    ref.listen(signInProvider, (_, next) {
      if (next is AsyncError && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface, // white for auth screens
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ── Brand logo ──────────────────────────────────────────
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 16),

                // ── App name ────────────────────────────────────────────
                Center(
                  child: Text(
                    '小肥路书',
                    style: AppTextStyles.largeTitle
                        .copyWith(letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('记录你的每一段旅程', style: AppTextStyles.caption),
                ),
                const SizedBox(height: 48),

                // ── Username field ──────────────────────────────────────
                AuthField(
                  controller: _usernameCtrl,
                  hintText: '用户名',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '请输入用户名' : null,
                ),
                const SizedBox(height: 10),

                // ── Password field ──────────────────────────────────────
                AuthField(
                  controller: _passwordCtrl,
                  hintText: '密码',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                ),
                const SizedBox(height: 24),

                // ── Login button ────────────────────────────────────────
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('登录',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Register link ───────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signup'),
                    child: Text(
                      '还没有账号？去注册',
                      style: AppTextStyles.subheadline
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shared auth input field ──────────────────────────────────────────────────

/// Shared auth input field — used by both SignInScreen and SignUpScreen.
class AuthField extends StatelessWidget {
  const AuthField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(prefixIcon,
            size: 20, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background, // #F2F2F7
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide:
              const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide:
              const BorderSide(color: AppColors.destructive, width: 1.5),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run the app and verify sign-in screen**

```bash
cd packages/roadbook-flutter
flutter run
```
Expected: pure white background, gradient logo square (52×52 rounded), large "小肥路书" title, gray rounded input fields, coral orange login button.

- [ ] **Step 3: Commit**

```bash
git add packages/roadbook-flutter/lib/features/auth/presentation/sign_in_screen.dart
git commit -m "feat(auth): redesign SignInScreen — brand logo, iOS-style inputs, coral button"
```

---

### Task 8: Rewrite SignUpScreen

**Files:**
- Modify: `packages/roadbook-flutter/lib/features/auth/presentation/sign_up_screen.dart`

- [ ] **Step 1: Replace `sign_up_screen.dart` entirely**

```dart
// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../domain/auth_provider.dart';
// AuthField is defined in sign_in_screen.dart and exported (public class)
import 'sign_in_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();

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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error.toString())));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ── Brand logo ──────────────────────────────────────────
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.map,
                        color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(height: 16),

                // ── App name ────────────────────────────────────────────
                Center(
                  child: Text(
                    '小肥路书',
                    style: AppTextStyles.largeTitle
                        .copyWith(letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child:
                      Text('创建你的账号', style: AppTextStyles.caption),
                ),
                const SizedBox(height: 48),

                // ── Username field ──────────────────────────────────────
                AuthField(
                  controller: _usernameCtrl,
                  hintText: '用户名',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入用户名';
                    if (v.trim().length > 16) return '用户名最多 16 位';
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // ── Password field ──────────────────────────────────────
                AuthField(
                  controller: _passwordCtrl,
                  hintText: '密码',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                ),
                const SizedBox(height: 10),

                // ── Confirm password field ──────────────────────────────
                AuthField(
                  controller: _confirmCtrl,
                  hintText: '确认密码',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _passwordCtrl.text ? '两次密码不一致' : null,
                ),
                const SizedBox(height: 24),

                // ── Register button ─────────────────────────────────────
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('注册',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Login link ──────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signin'),
                    child: Text(
                      '已有账号？去登录',
                      style: AppTextStyles.subheadline
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
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

- [ ] **Step 2: Run all tests to confirm nothing is broken**

```bash
cd packages/roadbook-flutter
flutter test
```
Expected: all tests PASS. (The `travel_card_test.dart` and `router_test.dart` should pass; other pre-existing tests should be unaffected.)

- [ ] **Step 3: Run the app and do a full smoke test**

```bash
cd packages/roadbook-flutter
flutter run
```
Manual checks:
1. Launch → redirected to sign-in (white bg, brand logo, coral button)
2. Tap 注册 link → sign-up screen matches sign-in style (3 fields)
3. Sign in → 旅程 tab with Large Title, gradient cards, circle FAB
4. Tap 发现 tab → "发现页 — 即将推出"
5. Tap 我的 tab → "我的页 — 即将推出"
6. Tap a travel card → TravelDetailScreen (gray AppBar, circle coral FAB)
7. More menu on detail → 行李清单 item visible, shows "即将推出" snackbar

- [ ] **Step 4: Commit**

```bash
git add packages/roadbook-flutter/lib/features/auth/presentation/sign_up_screen.dart
git commit -m "feat(auth): redesign SignUpScreen — matches sign-in style, reuses AuthField"
```

---

## Self-Review

### Spec coverage

| Spec requirement | Task |
|---|---|
| AppColors: #FF5B2E primary, #F2F2F7 background, all tokens | Task 1 |
| 4 status gradients: ongoing/upcoming/planning/ended | Task 1, 4 |
| 3-tab bottom nav (旅程·发现·我的), frosted appearance | Task 2 |
| Routing: /travel inside shell, /discover, /profile | Task 3 |
| TravelCard: gradient, white text, icon box, date+badge | Task 4 |
| TravelListScreen: Large Title 34px/800, iOS search bar, circle FAB | Task 5 |
| TravelDetailScreen: #F2F2F7 AppBar bg, circle FAB, 行李清单 menu | Task 6 |
| SignInScreen: brand logo, gray inputs, coral button | Task 7 |
| SignUpScreen: matching style | Task 8 |

**Not in Plan 1 (deferred):**
- 发现 full screen → Plan 2
- 我的 / 消息中心 / 编辑资料 / 设置 → Plan 3
- 行李清单 actual screen → Plan 4
- /share/:id public route → Plan 4

### Placeholder scan
No "TBD" or incomplete code blocks found. `AuthField` is defined in `sign_in_screen.dart` and imported by `sign_up_screen.dart` — both files are fully written in Tasks 7 and 8.

### Type consistency
- `TravelStatus.planning` introduced in Task 4 and referenced in `_gradientFor`, `_iconFor`, `_labelFor` — consistent.
- `AppColors.ongoingGradient` / `upcomingGradient` / `planningGradient` / `endedGradient` defined in Task 1, used in Task 4 — consistent.
- `AppTextStyles.largeTitle` defined in Task 1, used in Tasks 5, 7, 8 — consistent.
- `AppRadius.input = 10` defined in Task 1, used in `AuthField` in Tasks 7, 8 — consistent.
- `AppColors.textTertiary` defined in Task 1, used in Task 5 empty-state icon — consistent.
