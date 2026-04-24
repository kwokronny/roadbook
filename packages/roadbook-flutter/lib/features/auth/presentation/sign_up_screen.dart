// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/pastel_mesh_background.dart';
import '../domain/auth_provider.dart';
import 'sign_in_screen.dart'; // _GlassInput is private, use AuthField

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
        AppToast.error(context, next.error.toString());
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PastelMeshBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Brand title
                      const Text('小肥路书', style: AppTextStyles.display),
                      const SizedBox(height: 4),
                      Text(
                        '创建你的账号',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Glass form card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        child: BackdropFilter(
                          filter: GlassSpec.cardBlur,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: GlassSpec.cardBg,
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: GlassSpec.cardBorder),
                            ),
                            child: Column(
                              children: [
                                // Username
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
                                const SizedBox(height: 12),

                                // Password
                                AuthField(
                                  controller: _passwordCtrl,
                                  hintText: '密码',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) =>
                                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                                ),
                                const SizedBox(height: 12),

                                // Confirm password
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
                                const SizedBox(height: 16),

                                // Dark CTA
                                GestureDetector(
                                  onTap: state.isLoading ? null : _submit,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.darkPill,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.pill),
                                    ),
                                    child: Center(
                                      child: state.isLoading
                                          ? const SizedBox(
                                              width: 20, height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white),
                                            )
                                          : const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '注册',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  '→',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Login link
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/signin'),
                          child: Text.rich(
                            TextSpan(
                              text: '已有账号？',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: '登录',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
