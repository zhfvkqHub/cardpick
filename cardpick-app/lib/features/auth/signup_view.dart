import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class SignupView extends ConsumerStatefulWidget {
  const SignupView({super.key});

  @override
  ConsumerState<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends ConsumerState<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authTokenProvider.notifier).signup(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        showSuccessSnackBar(context, '회원가입이 완료됐습니다. 로그인해주세요.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('회원가입'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Text(
                  '카드픽에 오신 것을\n환영합니다',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '간단한 정보를 입력하고 시작하세요',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? '이름을 입력하세요' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '이메일을 입력하세요';
                    if (!v.contains('@')) return '올바른 이메일 형식을 입력하세요';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded, size: 20),
                    helperText: '8자 이상 입력하세요',
                    helperStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return '비밀번호를 입력하세요';
                    if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다';
                    return null;
                  },
                  onFieldSubmitted: (_) => _signup(),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
                        )
                      : const Text('가입하기'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
