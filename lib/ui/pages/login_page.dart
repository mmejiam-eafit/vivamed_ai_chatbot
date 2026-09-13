import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radiologist_helper/app.dart';
import 'package:radiologist_helper/services/providers.dart';
import 'package:radiologist_helper/ui/atoms/app_button.dart';
import 'package:radiologist_helper/ui/atoms/app_logo.dart';
import 'package:radiologist_helper/ui/atoms/app_text.dart';
import 'package:radiologist_helper/ui/atoms/app_text_field.dart';
import 'package:radiologist_helper/ui/core/preview_utils.dart';
import 'package:radiologist_helper/ui/templates/auth_template.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isSigningIn = true);
    await ref.read(authServiceProvider).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    final hasCompletedOnboarding =
        await ref.read(onboardingServiceProvider).hasCompletedOnboarding();
    if (!mounted) return;
    setState(() => _isSigningIn = false);
    Navigator.of(context).pushReplacementNamed(
      hasCompletedOnboarding ? Routes.home : Routes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthTemplate(
      formContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: AppLogo()),
          const AppText('Sign In'),
          AppTextField(
            controller: _emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          AppTextField(
            controller: _passwordController,
            hintText: 'Password',
            obscureText: true,
          ),
          AppButton(
            label: 'Sign In',
            isLoading: _isSigningIn,
            onPressed: _isSigningIn ? null : _signIn,
          ),
        ],
      ),
    );
  }
}

// ── Previews ──────────────────────────────────────────────────────────────────

@Preview(name: 'sign in', size: Size(480, 560), wrapper: previewWrapperFull)
Widget previewLoginPage() => const LoginPage();
