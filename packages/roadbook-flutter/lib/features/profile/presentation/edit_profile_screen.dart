// lib/features/profile/presentation/edit_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/auth_state_provider.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/api/upload_repository.dart';
import '../../../shared/models/user.dart';
import '../data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).valueOrNull?.user;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  ProfileRepository get _repo =>
      ProfileRepository(ref.read(dioProvider), ref.read(uploadRepositoryProvider));

  bool get _isDirty {
    final user = ref.read(authStateProvider).valueOrNull?.user;
    return _nameCtrl.text.trim() != (user?.name ?? '');
  }

  Future<void> _save() async {
    if (!_isDirty || _saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _repo.updateName(_nameCtrl.text.trim());
      await ref.read(authStateProvider.notifier).updateUser(updated);
      if (mounted) {
        AppToast.success(context, '保存成功');
      }
    } catch (e) {
      // Fallback: patch user locally with new name
      final current = ref.read(authStateProvider).valueOrNull?.user;
      if (current != null) {
        final patched = User(
          id: current.id,
          username: current.username,
          name: _nameCtrl.text.trim(),
          avatar: current.avatar,
        );
        await ref.read(authStateProvider.notifier).updateUser(patched);
      }
      if (mounted) {
        AppToast.error(context, '$e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xfile == null) return;

    setState(() => _saving = true);
    try {
      final avatarUrl = await _repo.uploadAvatar(File(xfile.path));
      final current = ref.read(authStateProvider).valueOrNull?.user;
      if (current != null) {
        final patched = User(
          id: current.id,
          username: current.username,
          name: current.name,
          avatar: avatarUrl,
        );
        await ref.read(authStateProvider.notifier).updateUser(patched);
      }
      if (mounted) {
        AppToast.success(context, '头像已更新');
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, '$e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull?.user;

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
        title: const Text('编辑资料', style: AppTextStyles.appBarTitle),
        actions: [
          TextButton(
            onPressed: _isDirty && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isDirty
                          ? AppColors.primary
                          : AppColors.inkTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 头像区
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: GestureDetector(
                onTap: _saving ? null : _pickAvatar,
                child: Stack(
                  children: [
                    _Avatar(avatarUrl: user?.avatar),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.darkPill,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.warmCanvas, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 表单
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.cover),
            ),
            child: Column(
              children: [
                // 用户名（只读）
                _FormRow(
                  label: '用户名',
                  child: Text(
                    user?.username ?? '',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56),
                // 昵称（可编辑）
                _FormRow(
                  label: '昵称',
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '设置昵称',
                      hintStyle:
                          TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ),
                const Divider(height: 0.5, thickness: 0.5, indent: 56),
                // 密码（跳转占位）
                _FormRow(
                  label: '密码',
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密码修改功能即将推出'))),
                    child: const Row(
                      children: [
                        Text('修改密码',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textSecondary)),
                        Spacer(),
                        Icon(Icons.chevron_right,
                            color: AppColors.textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            child: Text(
              '用户名仅用于登录，昵称显示在旅程中',
              style:
                  TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox(
          width: 70,
          height: 70,
          child: avatarUrl != null
              ? Image.network(avatarUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder())
              : _placeholder(),
        ),
      );

  Widget _placeholder() => Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      );
}

class _FormRow extends StatelessWidget {
  const _FormRow({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 8),
              Expanded(child: child),
            ],
          ),
        ),
      );
}
