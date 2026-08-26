abstract class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/v1';
  // static const String baseUrl = 'http://192.168.8.96:8000/v1';
  // static const String baseUrl = 'http://localhost:8000/v1';
  // static const String baseUrl = 'https://api.kwachaguard.vercel.app/v1';

  static const String scanHistoryEndpoint = '$baseUrl/scans';
  static String deleteScanEndpoint(String id) => '$baseUrl/scans/$id';


  static const String signInEndpoint         = '$baseUrl/auth/login';
  static const String registerEndpoint       = '$baseUrl/auth/register';
  static const String signOutEndpoint        = '$baseUrl/auth/logout';
  static const String deleteAccountEndpoint  = '$baseUrl/auth/account';
  static const String forgotPasswordEndpoint = '$baseUrl/auth/forgot-password';
  static const String refreshTokenEndpoint   = '$baseUrl/auth/refresh';
  static const String currentUserEndpoint    = '$baseUrl/auth/me';
  static const String changePasswordEndpoint = '$baseUrl/auth/change-password';

  static const String scanEndpoint           = '$baseUrl/scan';
  static const String scansEndpoint          = '$baseUrl/scans';
  static const String scanStatsEndpoint      = '$baseUrl/scans/stats';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 20);

}