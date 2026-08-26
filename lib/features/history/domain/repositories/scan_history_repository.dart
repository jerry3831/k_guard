import '../../../scanner/domain/entities/currency_note.dart';

abstract class ScanHistoryRepository {
  Future<List<CurrencyNote>> getAllScans();

  Future<void> deleteScan(String id);
}
