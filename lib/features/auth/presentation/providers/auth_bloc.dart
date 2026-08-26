import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../../../core/error/auth_exceptions.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase _signIn;
  final RegisterUseCase _register;
  final ForgotPasswordUseCase _forgotPassword;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;
  final GetCurrentUserUseCase _getCurrentUser;
  final ChangePasswordUseCase _changePassword;
  final SignInAsGuestUseCase _signInAsGuest;

  static const _timeout = Duration(seconds: 15);

  AuthBloc({
    required SignInUseCase signIn,
    required RegisterUseCase register,
    required ForgotPasswordUseCase forgotPassword,
    required SignOutUseCase signOut,
    required DeleteAccountUseCase deleteAccount,
    required GetCurrentUserUseCase getCurrentUser,
    required ChangePasswordUseCase changePassword,
    required SignInAsGuestUseCase signInAsGuest,
  })  : _signIn = signIn,
        _register = register,
        _forgotPassword = forgotPassword,
        _signOut = signOut,
        _deleteAccount = deleteAccount,
        _getCurrentUser = getCurrentUser,
        _changePassword = changePassword,
        _signInAsGuest = signInAsGuest,
        super(const AuthChecking()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthGuestSignInRequested>(_onGuestSignIn);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
    on<AuthChangePasswordRequested>(_onChangePassword);
  }


  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check session on startup with a brief timeout to prevent blocking UI
      final user = await _getCurrentUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null, // timeout → treat as no session
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }


  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Execute sign-in and trap distinct exception types for specific UI error messages
      final user = await _signIn(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      ).timeout(_timeout, onTimeout: () {
        throw TimeoutException('Sign in timed out');
      });
      emit(AuthAuthenticated(user));
    } on TimeoutException {
      emit(const AuthFailure(
        'Sign in is taking too long. Please check your device and try again.',
        isOffline: true,
      ));
    } on AuthNetworkException catch (e) {
      emit(AuthFailure(e.message, isOffline: true));
    } on InvalidCredentialsException catch (e) {
      emit(AuthFailure(e.message));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } on ArgumentError catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Sign in failed: ${e.toString()}'));
    }
  }


  Future<void> _onGuestSignIn(
    AuthGuestSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _signInAsGuest().timeout(_timeout, onTimeout: () {
        throw TimeoutException('Guest sign in timed out');
      });
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthFailure('Guest sign in failed: ${e.toString()}'));
    }
  }


  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _register(
        fullName:        event.fullName,
        email:           event.email,
        password:        event.password,
        confirmPassword: event.confirmPassword,
      ).timeout(_timeout, onTimeout: () {
        throw TimeoutException('Registration timed out');
      });
      emit(AuthAuthenticated(user));
    } on TimeoutException {
      emit(const AuthFailure(
        'Registration is taking too long. Please check your device storage and try again.',
        isOffline: true,
      ));
    } on AuthNetworkException catch (e) {
      emit(AuthFailure(e.message, isOffline: true));
    } on EmailAlreadyInUseException catch (e) {
      emit(AuthFailure(e.message));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } on ArgumentError catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('Registration failed: ${e.toString()}'));
    }
  }


  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _forgotPassword(event.email).timeout(_timeout);
      emit(AuthPasswordResetSent(event.email));
    } on TimeoutException {
      emit(const AuthFailure(
        'Request timed out. Please try again.',
        isOffline: true,
      ));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } on ArgumentError catch (e) {
      emit(AuthFailure(e.message));
    } catch (_) {
      emit(const AuthFailure('Could not send reset email. Please try again.'));
    }
  }


  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Ignore errors on sign out to ensure local state is cleared regardless of network
      await _signOut().timeout(const Duration(seconds: 5));
    } catch (_) {
    }
    emit(const AuthUnauthenticated());
  }


  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _deleteAccount().timeout(const Duration(seconds: 15));
      emit(const AuthUnauthenticated());
    } on TimeoutException {
      emit(const AuthFailure(
        'Request timed out. Please try again.',
        isOffline: true,
      ));
    } catch (_) {
      emit(const AuthFailure('Could not delete account. Please try again.'));
    }
  }


  Future<void> _onChangePassword(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      ).timeout(_timeout);
      event.onSuccess();
    } on TimeoutException {
      event.onError('Request timed out. Please try again.');
    } on AuthException catch (e) {
      event.onError(e.message);
    } on ArgumentError catch (e) {
      event.onError(e.message);
    } catch (_) {
      event.onError('Could not change password. Please try again.');
    }
  }
}
