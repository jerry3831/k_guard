import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_bloc.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  bool _rememberMe = false;
  final _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
      email:      _emailController.text.trim(),
      password:   _passController.text,
      rememberMe: _rememberMe,
    ));
  }

  Future<void> _biometricLogin() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) { _showSnack('Biometrics not available.'); return; }
      final ok = await _localAuth.authenticate(
        localizedReason: 'Sign in with biometrics',
      );
      if (ok && mounted) {
        context.read<AuthBloc>().add(const AuthAppStarted());
      }
    } catch (_) {
      _showSnack('Biometric authentication failed.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (_, current) =>
            current is AuthAuthenticated || current is AuthUnauthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/home',
              (route) => false,
            );
          }
        },
        buildWhen: (_, current) =>
            current is AuthLoading ||
            current is AuthFailure ||
            current is AuthUnauthenticated ||
            current is AuthChecking,
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const AuthHeader(
                          title: 'KwachaGuard',
                          subtitle: 'Advanced Counterfeit Detection',
                        ),
                        Expanded(
                          child: AuthCard(
                            child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Sign in to continue',
                            style: TextStyle(
                                fontSize: 13, color: isDark ? Colors.white70 : AppColors.textSecondary)),
                        const SizedBox(height: 24),

                        if (state is AuthFailure) ...[
                          AuthErrorBanner(
                              message: state.message,
                              isOffline: state.isOffline),
                          const SizedBox(height: 16),
                        ],

                        AuthTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isLoading,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),

                        AuthTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passController,
                          obscure: true,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: isLoading ? null : _submit,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(
                                        () => _rememberMe = v ?? false),
                                activeColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(
                                    color: AppColors.textSecondary),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('Remember me',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : AppColors.textSecondary)),
                            const Spacer(),
                            GestureDetector(
                              onTap: isLoading
                                  ? null
                                  : () => Navigator.of(context)
                                      .pushNamed('/forgot-password'),
                              child: const Text('Forgot Password?',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        AuthPrimaryButton(
                          label: 'Sign In',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 16),

                        Row(children: [
                          const Expanded(
                              child: Divider(color: AppColors.divider)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade400)),
                          ),
                          const Expanded(
                              child: Divider(color: AppColors.divider)),
                        ]),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.goldAccent,
                              side: const BorderSide(
                                  color: AppColors.goldAccent, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isLoading ? null : _biometricLogin,
                            icon: const Icon(Icons.fingerprint_rounded,
                                size: 20),
                            label: const Text('Login with Biometrics',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => Navigator.of(context)
                                    .pushReplacementNamed('/register'),
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                        color: isDark ? Colors.white : AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
      ),
    );
  },
);
        },
      ),
    );
  }
}
