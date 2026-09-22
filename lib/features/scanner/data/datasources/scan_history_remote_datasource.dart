import 'package:dio/dio.dart';
import '../models/currency_note_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

///   );
///   CREATE INDEX idx_scan_history_user ON scan_history(user_id);
///   CREATE INDEX idx_scan_history_date ON scan_history(scanned_at DESC);
abstract class ScanHistoryRemoteDataSource {
  Future<void> saveScan(CurrencyNoteModel note);

  Future<List<CurrencyNoteModel>> getScanHistory();

  Future<void> deleteScan(String id);
}

class ScanHistoryRemoteDataSourceImpl implements ScanHistoryRemoteDataSource {
  final Dio _dio;
  final AuthLocalDataSource _authLocal;

  const ScanHistoryRemoteDataSourceImpl(this._dio, this._authLocal);

  //   VALUES ($1, $jwt_user_id, $2, $3, $4, $5, $6, $7, $8, $9);

  @override
  Future<void> saveScan(CurrencyNoteModel note) async {
    try {
      final response = await _dio.post(
        ApiConstants.scanHistoryEndpoint,
        data: note.toJson(),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const NetworkException(
          message: 'Connection timed out. Please check your internet.',
        ),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw ServerException(
          message: 'Failed to save scan: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  //   ORDER BY scanned_at DESC;

  @override
  Future<List<CurrencyNoteModel>> getScanHistory() async {
    try {
      final user = await _authLocal.getCachedUser();
      if (user?.isGuest == true) {
        return [];
      }

      final response = await _dio.get(ApiConstants.scanHistoryEndpoint).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const NetworkException(
          message: 'Connection timed out. Please check your internet.',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final scans = (data['scans'] as List<dynamic>?) ?? [];
        return scans
            .map((json) =>
                CurrencyNoteModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        message: 'Failed to fetch scan history: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  //   WHERE id = $1 AND user_id = $jwt_user_id;

  @override
  Future<void> deleteScan(String id) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deleteScanEndpoint(id),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const NetworkException(
          message: 'Connection timed out. Please check your internet.',
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: 'Failed to delete scan: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }


  ScanException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Connection timed out. Please check your internet.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection.',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: e.response?.data?['message'] ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      default:
        return ScanException(message: e.message ?? 'Unknown error');
    }
  }
}
