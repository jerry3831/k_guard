import '../entities/dashboard_stats.dart';
import '../repositories/history_repository.dart';

class GetDashboardStatsUseCase {
  final HistoryRepository _repository;
  const GetDashboardStatsUseCase(this._repository);

  Future<DashboardStats> call() => _repository.getDashboardStats();
}
