import '../../../scanner/domain/entities/currency_note.dart';
import '../entities/dashboard_stats.dart';

abstract class HistoryRepository {
  Future<DashboardStats> getDashboardStats();
  Future<List<CurrencyNote>> getRecentScans({int limit = 5});
}
