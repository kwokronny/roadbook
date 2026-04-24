// lib/features/profile/presentation/settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/glass_card.dart';


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
        if (e is File) {
          try {
            total += e.lengthSync();
          } catch (_) {
            // file may have been deleted between listing and sizing
          }
        }
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
      if (dir.existsSync()) {
        for (final entity in dir.listSync()) {
          entity.deleteSync(recursive: true);
        }
      }
      await _calcCacheSize();
      if (mounted) AppToast.success(context, '缓存已清除');
    } catch (e) {
      if (mounted) AppToast.error(context, '清除失败: $e');
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    setState(() => _darkMode = value);
    // 主题切换留待后续迭代
    if (mounted) AppToast.success(context, '深色模式将在下次启动时生效');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.darkPill, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text('设置', style: AppTextStyles.appBarTitle),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _SectionTitle('通用'),
          _MenuGroup(items: [
            _SwitchItem(
              icon: Icons.dark_mode_outlined,
              iconBg: const Color(0xFF1C1C1E),
              label: '深色模式',
              value: _darkMode,
              onChanged: _toggleDarkMode,
            ),
            const _RowItem(
              icon: Icons.language_outlined,
              iconBg: Color(0xFF007AFF),
              label: '语言',
              trailing: Text('简体中文',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              onTap: null,
            ),
          ]),
          const _SectionTitle('存储'),
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
          const _SectionTitle('关于'),
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
        padding: EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal + 4, 14, AppSpacing.pageHorizontal, 6),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.inkTertiary,
              letterSpacing: 1.1),
        ),
      );
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) => GlassCard(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal),
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.cardSm,
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1)
                Divider(
                    height: 0.5,
                    thickness: 0.5,
                    indent: 48,
                    color: AppColors.inkPrimary.withValues(alpha: 0.05)),
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
                      size: 18, color: AppColors.textTertiary),
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
                activeThumbColor: AppColors.success,
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
        child: Center(child: Icon(icon, size: 14, color: Colors.white)),
      );
}
