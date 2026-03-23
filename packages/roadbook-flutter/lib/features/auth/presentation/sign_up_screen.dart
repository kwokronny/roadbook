// lib/features/auth/presentation/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../domain/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString())),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('注册')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontal, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: '用户名'),
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return '请输入用户名';
                    if (v.trim().length > 16) return '用户名最多 16 位';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.length < 6) ? '密码至少 6 位' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(labelText: '确认密码'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) =>
                      v != _passwordCtrl.text ? '两次密码不一致' : null,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('注册'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/signin'),
                  child: const Text('已有账号？去登录'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
