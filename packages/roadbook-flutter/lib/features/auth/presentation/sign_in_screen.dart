// lib/features/auth/presentation/sign_in_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../shared/widgets/pastel_mesh_background.dart';
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
                      // ── Brand title ──────────────────────────────────────
                      const Text(
                        '小肥路书',
                        style: AppTextStyles.display,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '登录你的旅行计划',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.inkSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Glass form card ──────────────────────────────────
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
                                _GlassInput(
                                  controller: _usernameCtrl,
                                  hintText: '输入用户名',
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? '请输入用户名'
                                          : null,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 12),

                                // Password
                                _GlassInput(
                                  controller: _passwordCtrl,
                                  hintText: '输入密码',
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  validator: (v) =>
                                      (v == null || v.length < 6)
                                          ? '密码至少 6 位'
                                          : null,
                                ),
                                const SizedBox(height: 16),

                                // Dark CTA button
                                SizedBox(
                                  height: 44,
                                  width: double.infinity,
                                  child: GestureDetector(
                                    onTap: state.isLoading ? null : _submit,
                                    child: Container(
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
                                                    '登录',
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Register link ────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: Text.rich(
                            TextSpan(
                              text: '没有账号？',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: '注册',
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

// ─── Glass Input Field ──────────────────────────────────────────────────────

class _GlassInput extends StatelessWidget {
  const _GlassInput({
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
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
      style: const TextStyle(fontSize: 14, color: AppColors.inkPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkTertiary),
        filled: true,
        fillColor: GlassSpec.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GlassSpec.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GlassSpec.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: GlassSpec.inputFocusBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.destructive, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.destructive, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Shared auth input field (also imported by SignUpScreen) ─────────────────

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
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
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkTertiary),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.inkTertiary),
        filled: true,
        fillColor: GlassSpec.inputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GlassSpec.inputBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: GlassSpec.inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: GlassSpec.inputFocusBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.destructive, width: 1),
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
