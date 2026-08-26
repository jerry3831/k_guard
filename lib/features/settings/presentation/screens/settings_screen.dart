import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/settings_bloc.dart';
import '../providers/settings_event.dart';
import '../providers/settings_state.dart';
import '../widgets/settings_widgets.dart';
import '../../../auth/presentation/providers/auth_bloc.dart';
import '../../../auth/presentation/providers/auth_event.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/domain/entities/app_user.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(const SettingsLoaded());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderWithProfile()),

            const SliverToBoxAdapter(
              child: SettingsSectionHeader(title: 'Account'),
            ),
            SliverToBoxAdapter(child: _buildAccountGroup()),

            const SliverToBoxAdapter(
              child: SettingsSectionHeader(title: 'Preferences'),
            ),
            SliverToBoxAdapter(child: _buildPreferencesGroup()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }


  Widget _buildHeaderWithProfile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 50, // Ends around the middle of the profile card
          child: Container(
            decoration: isDark
                ? BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  )
                : const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
                    ),
                  ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your account and preferences',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _buildProfileCard(),
          ],
        ),
      ],
    );
  }


  Widget _buildProfileCard() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                const BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (user != null) {
                _showProfileDialog(context, user);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: user?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.avatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 26,
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'Guest',
                          style: TextStyle(
                            fontSize: (user?.isGuest ?? false) ? 18 : 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (!(user?.isGuest ?? false)) ...[
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildAccountGroup() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isGuest = authState is AuthAuthenticated && authState.user.isGuest;

        return SettingsGroup(
          children: [
            if (!isGuest)
              SettingsNavRow(
                icon: Icons.lock_outline_rounded,
                label: 'Security',
                onTap: () => _showChangePasswordDialog(context),
              ),
            SettingsNavRow(
              icon: Icons.camera_alt_outlined,
              label: 'Camera Permissions',
              onTap: _openCameraPermissions,
            ),
          ],
        );
      },
    );
  }

  Future<void> _openCameraPermissions() async {
    final status = await Permission.camera.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is already granted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, anim1, anim2) {
        return const _ChangePasswordDialog();
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5 * anim1.value, sigmaY: 5 * anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }


  Widget _buildPreferencesGroup() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final prefs = state is SettingsLoadSuccess
            ? state.preferences
            : null;

        return SettingsGroup(
          children: [
            SettingsToggleRow(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              value: prefs?.notificationsEnabled ?? true,
              onChanged: (v) => context
                  .read<SettingsBloc>()
                  .add(SettingsNotificationsToggled(v)),
            ),
            SettingsToggleRow(
              icon: Icons.dark_mode_outlined,
              label: 'Dark Mode',
              value: prefs?.darkModeEnabled ?? false,
              onChanged: (v) => context
                  .read<SettingsBloc>()
                  .add(SettingsDarkModeToggled(v)),
            ),
            SettingsToggleRow(
              icon: Icons.volume_up_outlined,
              label: 'Sound Effects',
              value: prefs?.soundEffectsEnabled ?? true,
              onChanged: (v) => context
                  .read<SettingsBloc>()
                  .add(SettingsSoundEffectsToggled(v)),
            ),
            SettingsToggleRow(
              icon: Icons.vibration_rounded,
              label: 'Vibration',
              value: prefs?.vibrationEnabled ?? true,
              onChanged: (v) => context
                  .read<SettingsBloc>()
                  .add(SettingsVibrationToggled(v)),
            ),
          ],
        );
      },
    );
  }


  Widget _buildBottomNav(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          if (!isDark)
            const BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              active: false,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
            ),
            _NavItem(
              icon: Icons.camera_alt_outlined,
              active: false,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/scan'),
            ),
            _NavItem(
              icon: Icons.history,
              active: false,
              onTap: () =>
                  Navigator.of(context).pushReplacementNamed('/history'),
            ),
            _NavItem(
              icon: Icons.menu_book_outlined,
              active: false,
              onTap: () => Navigator.of(context).pushReplacementNamed('/learn'),
            ),
            _NavItem(
              icon: Icons.settings_rounded,
              active: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}


class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = active 
        ? Theme.of(context).colorScheme.primary 
        : (isDark ? Colors.white54 : AppColors.textSecondary);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: active ? color : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_newController.text != _confirmController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    context.read<AuthBloc>().add(
      AuthChangePasswordRequested(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        onSuccess: () {
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password changed successfully!'),
                backgroundColor: AppColors.authentic,
              ),
            );
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _error = err;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.counterfeit.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.counterfeit, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: AppColors.counterfeit, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _ValidatingField(
                    controller: _currentController,
                    label: 'Current Password',
                    obscure: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    isDark: isDark,
                    enabled: !_isLoading,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _ValidatingField(
                    controller: _newController,
                    label: 'New Password',
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    isDark: isDark,
                    enabled: !_isLoading,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  _ValidatingField(
                    controller: _confirmController,
                    label: 'Confirm New Password',
                    obscure: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    isDark: isDark,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != _newController.text) return 'Passwords do not match';
                      return Validators.validatePassword(v);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: isDark ? AppColors.darkBlueBackground : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? AppColors.darkBlueBackground : Colors.white,
                                ),
                              ),
                            )
                          : const Text('Update Password'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class _ValidatingField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isDark;
  final bool enabled;
  final String? Function(String?) validator;

  const _ValidatingField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.isDark,
    required this.enabled,
    required this.validator,
  });

  @override
  State<_ValidatingField> createState() => _ValidatingFieldState();
}

class _ValidatingFieldState extends State<_ValidatingField> {
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_validate);
    super.dispose();
  }

  void _validate() {
    final text = widget.controller.text;
    final valid = text.isNotEmpty && (widget.validator(text) == null);
    if (_isValid != valid) {
      setState(() {
        _isValid = valid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure,
      enabled: widget.enabled,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(
          fontSize: 15,
          color: widget.isDark ? Colors.white : AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: widget.isDark ? Colors.white70 : AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: widget.isDark
            ? AppColors.darkBlueBackground
            : const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isValid
                ? AppColors.authentic
                : (widget.isDark ? Colors.white12 : Colors.black12),
            width: _isValid ? 1.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _isValid
                ? AppColors.authentic
                : Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.counterfeit),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.counterfeit, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            widget.obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: widget.isDark ? Colors.white54 : Colors.black54,
            size: 20,
          ),
          onPressed: widget.onToggle,
        ),
      ),
      validator: widget.validator,
    );
  }
}


void _showProfileDialog(BuildContext context, AppUser user) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim1, anim2) {
      return _ProfileDialog(user: user);
    },
    transitionBuilder: (ctx, anim1, anim2, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5 * anim1.value, sigmaY: 5 * anim1.value),
        child: FadeTransition(
          opacity: anim1,
          child: child,
        ),
      );
    },
  );
}

class _ProfileDialog extends StatelessWidget {
  final AppUser user;
  const _ProfileDialog({required this.user});

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.counterfeit),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthDeleteAccountRequested());
      Navigator.of(context).pop(); // Close ProfileDialog
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBlueSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isDark
                ? Border.all(color: Colors.white.withOpacity(0.1))
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: user.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          user.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 40,
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                style: TextStyle(
                  fontSize: user.isGuest ? 24 : 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              if (!user.isGuest) ...[
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (user.isGuest) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed('/register');
                        } else {
                          context.read<AuthBloc>().add(const AuthSignOutRequested());
                          Navigator.of(context).pop();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        user.isGuest ? 'Sign In / Sign Up' : 'Sign Out',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (!user.isGuest) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _confirmDeleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.counterfeit.withOpacity(0.1),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(
                            color: AppColors.counterfeit,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

