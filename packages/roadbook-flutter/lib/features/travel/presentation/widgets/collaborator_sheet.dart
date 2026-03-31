// lib/features/travel/presentation/widgets/collaborator_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/user_travel.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../domain/travel_list_provider.dart';
import '../../domain/travel_detail_provider.dart';

class CollaboratorSheet extends ConsumerStatefulWidget {
  const CollaboratorSheet({super.key, required this.travelId});
  final int travelId;

  static Future<void> show(BuildContext context, int travelId) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CollaboratorSheet(travelId: travelId),
    );
  }

  @override
  ConsumerState<CollaboratorSheet> createState() => _CollaboratorSheetState();
}

class _CollaboratorSheetState extends ConsumerState<CollaboratorSheet> {
  String? _inviteToken;
  bool _loadingInvite = false;

  Future<void> _loadInvite() async {
    setState(() => _loadingInvite = true);
    try {
      final token =
          await ref.read(travelRepositoryProvider).invite(widget.travelId);
      setState(() => _inviteToken = token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loadingInvite = false);
    }
  }

  Future<void> _copyInvite() async {
    if (_inviteToken == null) {
      await _loadInvite();
      if (_inviteToken == null) return;
    }
    await Clipboard.setData(
        ClipboardData(text: 'roadbook://accept?inviteToken=$_inviteToken'));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('邀请链接已复制')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final currentUserId =
        ref.watch(authStateProvider).valueOrNull?.user?.id;

    return Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 标题栏
              Row(
                children: [
                  const Text('协作者管理', style: AppTextStyles.appBarTitle),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 12),
              // ── 邀请链接
              OutlinedButton.icon(
                onPressed: _loadingInvite ? null : _copyInvite,
                icon: _loadingInvite
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.link, size: 16),
                label:
                    const Text('复制邀请链接', style: TextStyle(fontSize: 17)),
              ),
              const SizedBox(height: 16),
              // ── 协作者列表
              travelAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString(),
                    style: AppTextStyles.caption),
                data: (travel) {
                  final collabs = travel.collaborators;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 320),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: collabs.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, i) {
                        final c = collabs[i];
                        final isSelf = c.user.id == currentUserId;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.input),
                            ),
                            child: Center(
                              child: Text(
                                (c.user.username).substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          title: Text(c.user.name ?? c.user.username,
                              style: AppTextStyles.body),
                          subtitle: Text('@${c.user.username}',
                              style: AppTextStyles.micro),
                          trailing: isSelf
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(AppRadius.input),
                                  ),
                                  child: Text(
                                    _roleLabel(c.role),
                                    style: AppTextStyles.micro.copyWith(
                                        color: AppColors.primary),
                                  ),
                                )
                              : PopupMenuButton<String>(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F4),
                                      borderRadius: BorderRadius.circular(AppRadius.input),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_roleLabel(c.role),
                                            style: AppTextStyles.micro),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.arrow_drop_down,
                                            size: 14,
                                            color: AppColors.textSecondary),
                                      ],
                                    ),
                                  ),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'manage', child: Text('管理者')),
                                    PopupMenuItem(
                                        value: 'edit', child: Text('编辑者')),
                                    PopupMenuItem(
                                        value: 'view', child: Text('查看者')),
                                    PopupMenuDivider(),
                                    PopupMenuItem(
                                        value: 'delete',
                                        child: Text('移除',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                  onSelected: (role) async {
                                    try {
                                      if (role == 'delete') {
                                        await ref
                                            .read(travelDetailProvider(
                                                    widget.travelId)
                                                .notifier)
                                            .removeCollab(c.user.id);
                                      } else {
                                        await ref
                                            .read(travelDetailProvider(
                                                    widget.travelId)
                                                .notifier)
                                            .updateCollab(c.user.id, role);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text(e.toString())));
                                      }
                                    }
                                  },
                                ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roleLabel(RoleType role) {
    switch (role) {
      case RoleType.manage:
        return '管理者';
      case RoleType.edit:
        return '编辑者';
      case RoleType.view:
        return '查看者';
    }
  }
}
