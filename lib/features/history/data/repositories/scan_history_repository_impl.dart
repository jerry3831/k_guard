import '../../../scanner/domain/entities/currency_note.dart';
import '../../../scanner/data/repositories/scan_repository_impl.dart';
import '../../../scanner/data/datasources/scan_history_remote_datasource.dart';
import '../../domain/repositories/scan_history_repository.dart';

class ScanHistoryRepositoryImpl implements ScanHistoryRepository {
  final ScanRepositoryImpl _scanRepo;
  final ScanHistoryRemoteDataSource _historyRemote;

  ScanHistoryRepositoryImpl({
    required ScanRepositoryImpl scanRepo,
    required ScanHistoryRemoteDataSource historyRemote,
  })  : _scanRepo = scanRepo,
        _historyRemote = historyRemote;

  @override
  Future<List<CurrencyNote>> getAllScans() => _scanRepo.getScanHistory();

  ///   WHERE id = $1 AND user_id = $jwt_user_id;
  @override
  Future<void> deleteScan(String id) async {
    await _historyRemote.deleteScan(id);
  }
}
