import '../../../scanner/domain/entities/currency_note.dart';
import '../repositories/scan_history_repository.dart';

class GetScanHistoryUseCase {
  final ScanHistoryRepository _repository;
  const GetScanHistoryUseCase(this._repository);

  Future<List<CurrencyNote>> call() => _repository.getAllScans();
}
