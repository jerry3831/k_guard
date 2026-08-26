import 'package:dio/dio.dart';
import '../models/app_user_model.dart';
import '../../../../core/error/auth_exceptions.dart';
import '../../../../core/constants/api_constants.dart';

///   );
abstract class AuthRemoteDataSource {
  Future<AppUserModel> signIn({required String email, required String password});
  Future<AppUserModel> register({required String fullName, required String email, required String password});
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut(String token);
  Future<void> deleteAccount(String token);
  Future<void> changePassword(String currentPassword, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  const AuthRemoteDataSourceImpl(this._dio);

  //     AND password_hash = crypt($2, password_hash);

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.signInEndpoint,
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final user = AppUserModel.fromJson(
            data['user'] as Map<String, dynamic>);
        final token = data['token'] as String?;
        return AppUserModel(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          createdAt: user.createdAt,
          avatarUrl: user.avatarUrl,
          sessionToken: token,
        );
      }
      throw AuthServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  //   RETURNING id, full_name, email, created_at;

  @override
  Future<AppUserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'full_name': fullName,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final user = AppUserModel.fromJson(
            data['user'] as Map<String, dynamic>);
        final token = data['token'] as String?;
        return AppUserModel(
          id: user.id,
          fullName: user.fullName,
          email: user.email,
          createdAt: user.createdAt,
          avatarUrl: user.avatarUrl,
          sessionToken: token,
        );
      }
      throw AuthServerException(statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  //     SET token = EXCLUDED.token, expires_at = EXCLUDED.expires_at;
  //   );
  //   DELETE FROM password_reset_tokens WHERE token = $token;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _dio.post(
        ApiConstants.forgotPasswordEndpoint,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  //   VALUES ($token, NOW());
  //   DELETE FROM refresh_tokens WHERE token = $refresh_token;

  @override
  Future<void> signOut(String token) async {
    try {
      await _dio.post(
        ApiConstants.signOutEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (_) {
    }
  }


  @override
  Future<void> deleteAccount(String token) async {
    try {
      await _dio.delete(
        ApiConstants.deleteAccountEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }


  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post(
        ApiConstants.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.statusCode == 400) {
        throw const AuthException('Enter valid password');
      }
      throw _mapDioError(e);
    }
  }


  AuthException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const AuthNetworkException();
    }

    final statusCode = e.response?.statusCode;
    String message = 'Unknown error';
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? data['detail'] as String? ?? 'Unknown error';
    } else if (data is String) {
      message = data;
    }

    switch (statusCode) {
      case 401:
        return const InvalidCredentialsException();
      case 404:
        return const UserNotFoundException();
      case 409:
        return const EmailAlreadyInUseException();
      default:
        return AuthServerException(
            message: message, statusCode: statusCode);
    }
  }
}
