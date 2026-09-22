import '../../../scanner/domain/entities/currency_note.dart';
import '../../../scanner/data/repositories/scan_repository_impl.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final ScanRepositoryImpl _scanRepo;

  HistoryRepositoryImpl({required ScanRepositoryImpl scanRepo})
      : _scanRepo = scanRepo;

  @override
  Future<DashboardStats> getDashboardStats() async {
    final all = await _scanRepo.getScanHistory();

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return DashboardStats(
      totalScans: all.length,
      authenticCount: all
          .where((n) => n.verdict == ScanVerdict.authentic)
          .length,
      suspiciousCount: all
          .where((n) => n.verdict == ScanVerdict.suspicious)
          .length,
      thisWeekCount:
          all.where((n) => n.timestamp.isAfter(weekAgo)).length,
    );
  }

  @override
  Future<List<CurrencyNote>> getRecentScans({int limit = 5}) async {
    final all = await _scanRepo.getScanHistory();
    return all.take(limit).toList();
  }
}
