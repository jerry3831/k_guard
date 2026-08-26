import 'dart:async';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/app_user_model.dart';
import '../../../../core/error/auth_exceptions.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
  })  : _remote = remote,
        _local = local;


  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    //      RETURNING id, full_name, email, created_at;
    final AppUserModel user;
    try {
      user = await _remote.register(
        fullName: fullName,
        email: email,
        password: password,
      );
    } on AuthException {
      rethrow; // Already typed — let the BLoC handle it
    } on TimeoutException {
      throw const AuthNetworkException();
    } on Exception catch (e) {
      throw AuthServerException(
          message: 'Registration failed: ${e.toString()}');
    }

    unawaited(_local.cacheUser(user).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugLog('WARNING: Session caching timed out after 3 seconds');
        return Future<void>.value();
      },
    ).catchError((e) {
      debugLog('WARNING: Session caching failed after registration: $e');
    }));

    return user;
  }


  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    AppUserModel user;

    try {
      //       AND password_hash = crypt($2, password_hash);
      user = await _remote.signIn(email: email, password: password);
    } on AuthNetworkException {
      // Gracefully fallback to local cache on network error if emails match
      final cached = await _local.getCachedUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (cached != null &&
          cached.email.toLowerCase() == email.toLowerCase()) {
        return cached;
      }
      rethrow;
    } on AuthException {
      rethrow; // InvalidCredentialsException, etc.
    } on TimeoutException {
      final cached = await _local.getCachedUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (cached != null &&
          cached.email.toLowerCase() == email.toLowerCase()) {
        return cached;
      }
      throw const AuthNetworkException();
    } on Exception catch (e) {
      throw AuthServerException(
          message: 'Login failed: ${e.toString()}');
    }

    unawaited(_local.cacheUser(user).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugLog('WARNING: Session caching timed out after 3 seconds');
        return Future<void>.value();
      },
    ).catchError((e) {
      debugLog('WARNING: Session caching failed after login: $e');
    }));

    if (rememberMe) {
      unawaited(_local.setRememberMe(true).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugLog('WARNING: Remember-me save timed out after 3 seconds');
          return Future<void>.value();
        },
      ).catchError((e) {
        debugLog('WARNING: Remember-me save failed after login: $e');
      }));
    }

    return user;
  }


  @override
  Future<AppUser> signInAsGuest() async {
    final guest = AppUserModel.guest();
    
    try {
      await _local.clearCache();
    } catch (e) {
      debugLog('WARNING: clearCache failed on guest login: $e');
    }

    return guest;
  }


  @override
  Future<void> sendPasswordResetEmail(String email) async {
    //       SET token = EXCLUDED.token, expires_at = EXCLUDED.expires_at;
    try {
      await _remote.sendPasswordResetEmail(email);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthServerException(
          message: 'Password reset failed: ${e.toString()}');
    }
  }


  @override
  Future<void> signOut() async {
    //      VALUES ($token, NOW());
    try {
      final cached = await _local.getCachedUser();
      if (cached?.sessionToken != null) {
        await _remote.signOut(cached!.sessionToken!);
      }
    } catch (e) {
      debugLog('WARNING: Server-side token revocation failed: $e');
    }

    try {
      await _local.clearCache();
    } catch (e) {
      debugLog('WARNING: clearCache failed on sign out: $e');
    }
  }

  @override
  Future<void> deleteAccount() async {
    final cached = await _local.getCachedUser();
    final token = cached?.sessionToken;
    if (token == null) {
      throw const SessionExpiredException();
    }
    
    await _remote.deleteAccount(token);
    
    await _local.clearCache();
  }


  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _remote.changePassword(currentPassword, newPassword);
    } on AuthException {
      rethrow;
    } on Exception catch (e) {
      throw AuthServerException(message: 'Failed to change password: ${e.toString()}');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final cachedUser = await _local.getCachedUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );

      // Invalidate guest session on startup to ensure a fresh session is used
      if (cachedUser != null && cachedUser.isGuest) {
        try {
          await _local.clearCache();
        } catch (_) {}
        return null;
      }

      return cachedUser;
    } catch (_) {
      return null; // safe degradation — shows login screen
    }
  }


  @override
  Future<void> persistSession(AppUser user, String token) async {
    final model = AppUserModel(
      id:           user.id,
      fullName:     user.fullName,
      email:        user.email,
      createdAt:    user.createdAt,
      avatarUrl:    user.avatarUrl,
      sessionToken: token,
    );
    await _local.cacheUser(model);
  }

  @override
  Future<void> clearSession() => _local.clearCache();

  void debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print('[AuthRepository] $message');
      return true;
    }());
  }
}
