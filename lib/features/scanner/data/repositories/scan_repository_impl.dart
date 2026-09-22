import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/currency_note.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';
import '../datasources/scan_history_remote_datasource.dart';
import '../models/currency_note_model.dart';
import '../../../../core/error/exceptions.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource _remoteDataSource;
  final ScanHistoryRemoteDataSource _historyDataSource;
  final Connectivity _connectivity;

  ScanRepositoryImpl({
    required ScanRemoteDataSource remoteDataSource,
    required ScanHistoryRemoteDataSource historyDataSource,
    required Connectivity connectivity,
  })  : _remoteDataSource = remoteDataSource,
        _historyDataSource = historyDataSource,
        _connectivity = connectivity;

  @override
  Future<CurrencyNote> scanImages(List<File> imageFiles) async {
    try {
      final CurrencyNoteModel model = await _remoteDataSource.scanImages(imageFiles);
      return model;
    } on ScanException {
      rethrow;
    } catch (e) {
      throw ScanException(message: e.toString());
    }
  }

  ///   VALUES ($1, $jwt_user_id, $2, $3, $4, $5, $6, $7, $8, $9);
  @override
  Future<void> saveScan(CurrencyNote note) async {
    try {
      await _historyDataSource.saveScan(CurrencyNoteModel.fromEntity(note));
    } on ScanException {
      rethrow;
    } catch (e) {
      throw ScanException(message: 'Failed to save scan: ${e.toString()}');
    }
  }

  ///   ORDER BY scanned_at DESC;
  @override
  Future<List<CurrencyNote>> getScanHistory() async {
    try {
      return await _historyDataSource.getScanHistory();
    } on ScanException {
      rethrow;
    } catch (e) {
      throw ScanException(
          message: 'Failed to fetch scan history: ${e.toString()}');
    }
  }
}
