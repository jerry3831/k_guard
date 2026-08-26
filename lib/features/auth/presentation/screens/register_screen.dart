import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../providers/auth_bloc.dart';
import '../providers/auth_event.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_widgets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _emailController  = TextEditingController();
  final _passController   = TextEditingController();
  final _confirmController= TextEditingController();
  bool _agreedToTerms  = false;
  bool _termsError     = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _termsError = !_agreedToTerms);
    if (!_formKey.currentState!.validate() || !_agreedToTerms) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
      fullName:        _nameController.text.trim(),
      email:           _emailController.text.trim(),
      password:        _passController.text,
      confirmPassword: _confirmController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            current is AuthAuthenticated || current is AuthUnauthenticated,
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/registration-success',
              (route) => false,
            );
          }
        },

        buildWhen: (previous, current) =>
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
                          title: 'Create Account',
                          subtitle: 'Start detecting counterfeit currency',
                        ),
                        Expanded(
                          child: AuthCard(
                            child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state is AuthFailure) ...[
                          AuthErrorBanner(
                            message: state.message,
                            isOffline: state.isOffline,
                          ),
                          const SizedBox(height: 16),
                        ],

                        AuthTextField(
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          enabled: !isLoading,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Full name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

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
                          hint: 'Create a password',
                          controller: _passController,
                          obscure: true,
                          enabled: !isLoading,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: 16),

                        AuthTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmController,
                          obscure: true,
                          enabled: !isLoading,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: isLoading ? null : _submit,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != _passController.text) return 'Passwords do not match';
                            return Validators.validatePassword(v);
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20, height: 20,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: isLoading
                                    ? null
                                    : (v) => setState(() {
                                          _agreedToTerms = v ?? false;
                                          _termsError = false;
                                        }),
                                activeColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(
                                  color: _termsError
                                      ? AppColors.counterfeit
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : AppColors.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : AppColors.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_termsError) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'You must agree to the Terms of Service',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.counterfeit),
                          ),
                        ],
                        const SizedBox(height: 24),

                        AuthPrimaryButton(
                          label: 'Create Account',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        ),
                        const SizedBox(height: 20),

                        Center(
                          child: GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => Navigator.of(context)
                                    .pushReplacementNamed('/login'),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                                    fontSize: 13),
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
