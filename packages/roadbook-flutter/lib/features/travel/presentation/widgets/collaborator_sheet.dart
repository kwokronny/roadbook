// lib/features/travel/presentation/widgets/collaborator_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme.dart';
import '../../../../shared/models/user_travel.dart';
import '../../../../shared/providers/auth_state_provider.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/glass_drawer.dart';
import '../../../../shared/widgets/glass_popover.dart';
import '../../data/invite_code_cache.dart';
import '../../domain/travel_list_provider.dart';
import '../../domain/travel_detail_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class CollaboratorSheet extends ConsumerStatefulWidget {
  const CollaboratorSheet({super.key, required this.travelId});
  final int travelId;

  static Future<void> show(BuildContext context, int travelId) {
    return showGlassDrawer<void>(
      context: context,
      title: '协作者管理',
      builder: (_) => CollaboratorSheet(travelId: travelId),
    );
  }

  @override
  ConsumerState<CollaboratorSheet> createState() => _CollaboratorSheetState();
}

class _CollaboratorSheetState extends ConsumerState<CollaboratorSheet> {
  String? _inviteToken;
  bool _loadingInvite = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInvite());
  }

  Future<void> _loadInvite() async {
    setState(() => _loadingInvite = true);
    try {
      final token =
          await ref.read(travelRepositoryProvider).invite(widget.travelId);
      InviteCodeCache.put(token);
      setState(() => _inviteToken = token);
    } catch (e) {
      if (mounted) AppToast.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _loadingInvite = false);
    }
  }

  void _showRolePopover(BuildContext triggerCtx, UserWithRole c) {
    final box = triggerCtx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(triggerCtx).size.width;

    Future<void> updateRole(String role) async {
      try {
        await ref
            .read(travelDetailProvider(widget.travelId).notifier)
            .updateCollab(c.user.id, role);
      } catch (e) {
        if (mounted) AppToast.error(context, e.toString());
      }
    }

    Future<void> removeCollab() async {
      try {
        await ref
            .read(travelDetailProvider(widget.travelId).notifier)
            .removeCollab(c.user.id);
      } catch (e) {
        if (mounted) AppToast.error(context, e.toString());
      }
    }

    showGlassPopover(
      context: triggerCtx,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy + box.size.height + 6,
        screenWidth - pos.dx - box.size.width,
        0,
      ),
      width: 160,
      items: [
        PopoverItem(
            icon: HugeIcons.strokeRoundedSettings01,
            label: '管理者',
            onTap: () => updateRole('manage')),
        PopoverItem(
            icon: HugeIcons.strokeRoundedEdit01,
            label: '编辑者',
            onTap: () => updateRole('edit')),
        PopoverItem(
            icon: HugeIcons.strokeRoundedView,
            label: '查看者',
            onTap: () => updateRole('view')),
        PopoverItem(
            icon: HugeIcons.strokeRoundedUserRemove01,
            label: '移除',
            isDestructive: true,
            onTap: removeCollab),
      ],
    );
  }

  Future<void> _copyCode() async {
    if (_inviteToken == null) return;
    final code = InviteCodeCache.deriveShortCode(_inviteToken!);
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) AppToast.success(context, '邀请码已复制');
  }

  @override
  Widget build(BuildContext context) {
    final travelAsync = ref.watch(travelDetailProvider(widget.travelId));
    final currentUserId =
        ref.watch(authStateProvider).valueOrNull?.user?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, 0, AppSpacing.pageHorizontal, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InviteCard(
            token: _inviteToken,
            loading: _loadingInvite,
            onCopy: _copyCode,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '参与者',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.inkSecondary,
              ),
            ),
          ),
          travelAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text(e.toString(), style: AppTextStyles.caption),
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
                      child: Divider(
                          height: 0.5,
                          thickness: 0.5,
                          color: Color(0x0F1C1C1E)),
                    ),
                    itemBuilder: (context, i) {
                      final c = collabs[i];
                      final isSelf = c.user.id == currentUserId;
                      final avatarColor =
                          isSelf ? AppColors.primary : AppColors.lavender;
                      final avatarUrl = c.user.avatar;
                      final hasAvatar =
                          avatarUrl != null && avatarUrl.isNotEmpty;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            ClipOval(
                              child: Container(
                                width: 40,
                                height: 40,
                                color: avatarColor,
                                child: hasAvatar
                                    ? Image.network(
                                        avatarUrl,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            c.user.username
                                                .substring(0, 1)
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          c.user.username
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                c.user.name ?? c.user.username,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.inkPrimary),
                              ),
                            ),
                            if (isSelf)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.coralTint,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Text(
                                  _roleLabel(c.role),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFD4410A)),
                                ),
                              )
                            else
                              Builder(builder: (triggerCtx) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      _showRolePopover(triggerCtx, c),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.lavenderTint,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.pill),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _roleLabel(c.role),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.lavenderText),
                                        ),
                                        const SizedBox(width: 2),
                                        const Text('▾',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.lavenderText)),
                                      ],
                                    ),
                                  ),
                                );
                              }),
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

class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.token,
    required this.loading,
    required this.onCopy,
  });

  final String? token;
  final bool loading;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final shortCode =
        token == null ? '----' : InviteCodeCache.deriveShortCode(token!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.separator, width: 0.5),
            ),
            padding: const EdgeInsets.all(8),
            child: token == null
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : QrImageView(
                    data: token!,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.inkPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.inkPrimary,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('邀请码',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.inkSecondary,
                    )),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      shortCode,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: AppColors.inkPrimary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: token == null ? null : onCopy,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: token == null
                              ? GlassSpec.inputOnGlassBg
                              : AppColors.darkPill,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '复制',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: token == null
                                ? AppColors.inkTertiary
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  loading ? '生成中...' : '有效期 7 天',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.inkTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
