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
              const _MenuItem(
                icon: Icons.mail_outline,
                iconBg: AppColors.primary,
                label: '消息中心',
                trailing: _ComingSoonBadge(),
                onTap: null,
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
              _MenuItem(
                icon: Icons.key_outlined,
                iconBg: AppColors.hotel,
                label: 'API Key 管理',
                onTap: () => context.push('/profile/api-keys'),
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
  const _ComingSoonBadge();
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
