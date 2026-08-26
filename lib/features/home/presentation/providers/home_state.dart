import '../../../scanner/domain/entities/currency_note.dart';
import '../../domain/entities/dashboard_stats.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final DashboardStats stats;
  final List<CurrencyNote> recentScans;


  const HomeLoaded({
    required this.stats,
    required this.recentScans,
  });
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}
