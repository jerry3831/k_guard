import '../repositories/scan_history_repository.dart';

class DeleteScanUseCase {
  final ScanHistoryRepository _repository;
  const DeleteScanUseCase(this._repository);

  Future<void> call(String scanId) => _repository.deleteScan(scanId);
}
