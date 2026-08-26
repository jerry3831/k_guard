import 'dart:io';
import 'package:dio/dio.dart';
import '../models/currency_note_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/api_constants.dart';

abstract class ScanRemoteDataSource {
  Future<CurrencyNoteModel> scanImages(List<File> imageFiles);
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final Dio _dio;

  const ScanRemoteDataSourceImpl(this._dio);

  @override
  Future<CurrencyNoteModel> scanImages(List<File> imageFiles) async {
    try {
      final List<MultipartFile> files = [];
      for (var i = 0; i < imageFiles.length; i++) {
        files.add(
          await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: 'currency_scan_$i.jpg',
          ),
        );
      }

      final formData = FormData.fromMap({
        'images': files,
      });

      final response = await _dio.post(
        ApiConstants.scanEndpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      ).timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw DioException(
          requestOptions: RequestOptions(path: ApiConstants.scanEndpoint),
          type: DioExceptionType.receiveTimeout,
          message: 'Scan request timed out.',
        ),
      );

      if (response.statusCode == 200) {
        return CurrencyNoteModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw ServerException(
        message: 'Unexpected status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
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
