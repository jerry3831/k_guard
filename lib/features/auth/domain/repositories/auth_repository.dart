import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<AppUser> signInAsGuest();

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> deleteAccount();

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<AppUser?> getCurrentUser();

  Future<void> persistSession(AppUser user, String token);

  Future<void> clearSession();
}
