import '../../domain/entities/app_user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthChecking extends AuthState {
  const AuthChecking();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  final bool isOfflineSession;
  const AuthAuthenticated(this.user, {this.isOfflineSession = false});
}

class AuthFailure extends AuthState {
  final String message;
  final bool isOffline;
  const AuthFailure(this.message, {this.isOffline = false});
}

class AuthPasswordResetSent extends AuthState {
  final String email;
  const AuthPasswordResetSent(this.email);
}
