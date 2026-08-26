import '../../../scanner/domain/entities/currency_note.dart';
import '../repositories/history_repository.dart';

class GetRecentScansUseCase {
  final HistoryRepository _repository;
  const GetRecentScansUseCase(this._repository);

  Future<List<CurrencyNote>> call({int limit = 5}) =>
      _repository.getRecentScans(limit: limit);
}
