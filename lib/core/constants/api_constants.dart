abstract class ApiConstants {
  /// Root URL — no trailing slash.
  static const String baseUrl = 'https://k-guard-3.onrender.com';

  // ── Auth ────────────────────────────────────────────────────────────────
  static const String signInEndpoint         = '$baseUrl/v1/auth/login';
  static const String registerEndpoint       = '$baseUrl/v1/auth/register';
  static const String signOutEndpoint        = '$baseUrl/v1/auth/logout';
  static const String deleteAccountEndpoint  = '$baseUrl/v1/auth/account';
  static const String forgotPasswordEndpoint = '$baseUrl/v1/auth/forgot-password';
  static const String refreshTokenEndpoint   = '$baseUrl/v1/auth/refresh';
  static const String currentUserEndpoint    = '$baseUrl/v1/auth/me';
  static const String changePasswordEndpoint = '$baseUrl/v1/auth/change-password';

  // ── Scan ─────────────────────────────────────────────────────────────────
  static const String scanEndpoint           = '$baseUrl/v1/scan';
  static const String scansEndpoint          = '$baseUrl/v1/scans';
  static const String scanHistoryEndpoint    = '$baseUrl/v1/scans';
  static const String scanStatsEndpoint      = '$baseUrl/v1/scans/stats';
  static String deleteScanEndpoint(String id) => '$baseUrl/v1/scans/$id';

  // ── Timeouts ─────────────────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout    = Duration(seconds: 20);
}
