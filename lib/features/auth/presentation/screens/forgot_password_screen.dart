import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_bloc.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(_emailController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthPasswordResetSent) {
            return _ConfirmationView(
              email: state.email,
              onBackToLogin: () {
                context.read<AuthBloc>().add(const AuthAppStarted());
                Navigator.of(context).pushReplacementNamed('/login');
              },
            );
          }

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
                          title: 'Reset Password',
                          subtitle: 'Enter your registered email address',
                        ),
                        Expanded(
                          child: AuthCard(
                            child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "No worries — we'll send a reset link to your email.",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (state is AuthFailure) ...[
                          AuthErrorBanner(
                            message: state.message,
                            isOffline: state.isOffline,
                          ),
                          const SizedBox(height: 16),
                        ],

                        AuthTextField(
                          label: 'Email Address',
                          hint: 'Enter your registered email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submit,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 28),

                        AuthPrimaryButton(
                          label: 'Send Reset Link',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: RichText(
                              text: TextSpan(
                                text: 'Remembered it? ',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppColors.primaryBlue,
                                      fontWeight: FontWeight.w600,
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


class _ConfirmationView extends StatelessWidget {
  final String email;
  final VoidCallback onBackToLogin;

  const _ConfirmationView({
    required this.email,
    required this.onBackToLogin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'Check Your Email',
                    subtitle: 'Reset link sent successfully',
                  ),
                  Expanded(
                    child: AuthCard(
                      child: Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.authentic.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.authentic,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset link sent!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'We sent a password reset link to\n',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    children: [
                      TextSpan(
                        text: email,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '\n\nThe link expires in 1 hour. Check your spam folder if you don\'t see it.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AuthPrimaryButton(
                  label: 'Back to Sign In',
                  onPressed: onBackToLogin,
                ),
                const SizedBox(height: 16),
                Center(
                  child: GestureDetector(
                    onTap: () => context.read<AuthBloc>().add(
                          AuthForgotPasswordRequested(email),
                        ),
                    child: const Text(
                      "Didn't receive it? Resend",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
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
  }
}
