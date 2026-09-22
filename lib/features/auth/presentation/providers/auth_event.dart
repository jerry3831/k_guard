abstract class AuthEvent {
  const AuthEvent();
}

class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  const AuthSignInRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class AuthGuestSignInRequested extends AuthEvent {
  const AuthGuestSignInRequested();
}

class AuthRegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  const AuthRegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested(this.email);
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}

class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final void Function() onSuccess;
  final void Function(String error) onError;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.onSuccess,
    required this.onError,
  });
}
