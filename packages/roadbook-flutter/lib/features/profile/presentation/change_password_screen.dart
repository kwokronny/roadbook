// lib/features/profile/presentation/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/dio_provider.dart';
import '../../../shared/api/api_endpoints.dart';
import '../../../shared/widgets/app_toast.dart';
import 'package:dio/dio.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;
  bool _oldObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _oldCtrl.text.isNotEmpty &&
      _newCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty;

  Future<void> _save() async {
    if (!_canSave || _saving) return;
    if (_newCtrl.text != _confirmCtrl.text) {
      AppToast.error(context, '两次输入的新密码不一致');
      return;
    }
    if (_newCtrl.text.length < 6) {
      AppToast.error(context, '新密码至少 6 位');
      return;
    }
    setState(() => _saving = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiEndpoints.passwordModify, data: {
        'oldPassword': _oldCtrl.text,
        'password': _newCtrl.text,
      });
      if (mounted) {
        AppToast.success(context, '密码修改成功');
        Navigator.pop(context);
      }
    } on DioException catch (e) {
      if (mounted) {
        AppToast.error(context, e.message ?? '修改失败');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.darkPill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_left,
                    size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
        title: const Text('修改密码', style: AppTextStyles.appBarTitle),
        actions: [
          TextButton(
            onPressed: _canSave && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 14,
                      color: _canSave
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
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal),
            decoration: BoxDecoration(
              color: const Color(0xB0FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _PasswordRow(
                  label: '当前密码',
                  controller: _oldCtrl,
                  obscure: _oldObscure,
                  onToggle: () => setState(() => _oldObscure = !_oldObscure),
                  onChanged: () => setState(() {}),
                ),
                const _FormDivider(),
                _PasswordRow(
                  label: '新密码',
                  controller: _newCtrl,
                  obscure: _newObscure,
                  onToggle: () => setState(() => _newObscure = !_newObscure),
                  onChanged: () => setState(() {}),
                  hintText: '至少 6 位',
                ),
                const _FormDivider(),
                _PasswordRow(
                  label: '确认新密码',
                  controller: _confirmCtrl,
                  obscure: _confirmObscure,
                  onToggle: () =>
                      setState(() => _confirmObscure = !_confirmObscure),
                  onChanged: () => setState(() {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRow extends StatelessWidget {
  const _PasswordRow({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.onChanged,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.inkPrimary)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  onChanged: (_) => onChanged(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 2),
                    hintText: hintText,
                    hintStyle: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 15),
                    hintTextDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        );
}

class _FormDivider extends StatelessWidget {
  const _FormDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(left: 14),
        child: Divider(
            height: 0.5, thickness: 0.5, color: Color(0x0F1C1C1E)),
      );
}
