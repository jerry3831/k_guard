import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';


class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);

  Future<AppUser> call({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    _validateEmail(email);
    _validatePassword(password);
    return _repository.signIn(
      email: email.trim(),
      password: password,
      rememberMe: rememberMe,
    );
  }
}


class SignInAsGuestUseCase {
  final AuthRepository _repository;
  const SignInAsGuestUseCase(this._repository);

  Future<AppUser> call() => _repository.signInAsGuest();
}


class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<AppUser> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (fullName.trim().isEmpty) {
      throw ArgumentError('Full name is required.');
    }
    if (password != confirmPassword) {
      throw ArgumentError('Passwords do not match.');
    }
    _validateEmail(email);
    _validatePassword(password);
    return _repository.register(
      fullName: fullName.trim(),
      email: email.trim(),
      password: password,
    );
  }
}


class ForgotPasswordUseCase {
  final AuthRepository _repository;
  const ForgotPasswordUseCase(this._repository);

  Future<void> call(String email) {
    _validateEmail(email);
    return _repository.sendPasswordResetEmail(email.trim());
  }
}


class SignOutUseCase {
  final AuthRepository _repository;
  const SignOutUseCase(this._repository);

  Future<void> call() => _repository.signOut();
}


class DeleteAccountUseCase {
  final AuthRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<void> call() => _repository.deleteAccount();
}


class GetCurrentUserUseCase {
  final AuthRepository _repository;
  const GetCurrentUserUseCase(this._repository);

  Future<AppUser?> call() => _repository.getCurrentUser();
}


class ChangePasswordUseCase {
  final AuthRepository _repository;
  const ChangePasswordUseCase(this._repository);

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    _validatePassword(currentPassword);
    _validatePassword(newPassword);
    return _repository.changePassword(currentPassword, newPassword);
  }
}


void _validateEmail(String email) {
  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailRegex.hasMatch(email.trim())) {
    throw ArgumentError('Please enter a valid email address.');
  }
}

void _validatePassword(String password) {
  if (password.length < 8) {
    throw ArgumentError('Password must be at least 8 characters.');
  }
}
