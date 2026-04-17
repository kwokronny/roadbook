// lib/features/travel/presentation/widgets/collaborator_sheet.dart
import 'dart:ui';
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

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      child: BackdropFilter(
        filter: GlassSpec.sheetBlur,
        child: Container(
          decoration: const BoxDecoration(
            color: GlassSpec.sheetBg,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
            border: Border(
              top: BorderSide(color: GlassSpec.sheetBorder, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Drag handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 14),
                      decoration: BoxDecoration(
                        color: GlassSpec.dragHandle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // ── Title bar
                  Row(
                    children: [
                      Text('协作者管理',
                          style: AppTextStyles.title.copyWith(fontSize: 20)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0x1A1C1C1E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 14,
                              color: AppColors.inkSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── Invite link pill
                  GestureDetector(
                    onTap: _loadingInvite ? null : _copyInvite,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: const [
                          BoxShadow(color: AppColors.coralGlow, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_loadingInvite)
                            const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                          else
                            const Icon(Icons.link, size: 18,
                                color: Colors.white),
                          const SizedBox(width: 6),
                          const Text('复制邀请链接',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              // ── 协作者列表 (白色圆角卡片)
              travelAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString(),
                    style: AppTextStyles.caption),
                data: (travel) {
                  final collabs = travel.collaborators;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: collabs.length,
                        separatorBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.only(left: 64),
                          child: Divider(height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
                        ),
                        itemBuilder: (context, i) {
                          final c = collabs[i];
                          final isSelf = c.user.id == currentUserId;
                          final avatarColor = isSelf ? AppColors.primary : AppColors.lavender;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: avatarColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      (c.user.username).substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name
                                Expanded(
                                  child: Text(
                                    c.user.name ?? c.user.username,
                                    style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                      color: AppColors.inkPrimary),
                                  ),
                                ),
                                // Role badge
                                if (isSelf)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.coralTint,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(_roleLabel(c.role),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                        color: Color(0xFFD4410A))),
                                  )
                                else
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.lavenderTint,
                                        borderRadius: BorderRadius.circular(AppRadius.pill),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(_roleLabel(c.role),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                              color: AppColors.lavenderText)),
                                          const SizedBox(width: 2),
                                          const Text('▾', style: TextStyle(
                                            fontSize: 10, color: AppColors.lavenderText)),
                                        ],
                                      ),
                                    ),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(value: 'manage', child: Text('管理者')),
                                      PopupMenuItem(value: 'edit', child: Text('编辑者')),
                                      PopupMenuItem(value: 'view', child: Text('查看者')),
                                      PopupMenuDivider(),
                                      PopupMenuItem(value: 'delete',
                                        child: Text('移除', style: TextStyle(color: Colors.red))),
                                    ],
                                    onSelected: (role) async {
                                      try {
                                        if (role == 'delete') {
                                          await ref.read(travelDetailProvider(widget.travelId).notifier)
                                              .removeCollab(c.user.id);
                                        } else {
                                          await ref.read(travelDetailProvider(widget.travelId).notifier)
                                              .updateCollab(c.user.id, role);
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      }
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
