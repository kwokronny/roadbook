// lib/features/profile/presentation/api_keys_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/models/api_key.dart';
import '../domain/api_key_provider.dart';

class ApiKeysScreen extends ConsumerStatefulWidget {
  const ApiKeysScreen({super.key});

  @override
  ConsumerState<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends ConsumerState<ApiKeysScreen> {
  Future<void> _createKey() async {
    final name = await _showNameDialog();
    if (name == null || name.trim().isEmpty) return;

    try {
      final newKey =
          await ref.read(apiKeyListProvider.notifier).create(name.trim());
      if (mounted) _showKeyCreatedDialog(newKey);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<String?> _showNameDialog() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建 API Key'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入名称（如"我的 Claude"）',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showKeyCreatedDialog(ApiKey apiKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('API Key 已创建'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请立即复制并保存，此 Key 仅显示一次：',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      apiKey.key,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: apiKey.key));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已复制到剪贴板')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('我已保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(ApiKey key) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除 API Key'),
        content: Text('确定删除「${key.name}」？使用此 Key 的连接将立即失效。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除',
                style: TextStyle(color: AppColors.destructive)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(apiKeyListProvider.notifier).remove(key.id);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keysAsync = ref.watch(apiKeyListProvider);

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
        title: const Text('API Key 管理', style: AppTextStyles.appBarTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _createKey,
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.darkPill, shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: keysAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e', style: AppTextStyles.caption),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(apiKeyListProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (keys) {
          if (keys.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.key_off_outlined,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text('暂无 API Key', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  const Text(
                    '创建 API Key 后可让 AI 助手\n通过 MCP 协议管理你的行程',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _createKey,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('创建 API Key'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
            itemCount: keys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _ApiKeyCard(
              apiKey: keys[i],
              onDelete: () => _confirmDelete(keys[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ApiKeyCard extends StatelessWidget {
  const _ApiKeyCard({required this.apiKey, required this.onDelete});

  final ApiKey apiKey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.key, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apiKey.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  apiKey.key,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: AppColors.textSecondary,
                  ),
                ),
                if (apiKey.lastUsedAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '最后使用: ${_formatDate(apiKey.lastUsedAt!)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textTertiary),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                size: 20, color: AppColors.textTertiary),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
