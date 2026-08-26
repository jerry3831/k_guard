import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/get_recent_scans_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardStatsUseCase _getStats;
  final GetRecentScansUseCase _getRecentScans;

  HomeBloc({
    required GetDashboardStatsUseCase getStats,
    required GetRecentScansUseCase getRecentScans,
  })  : _getStats = getStats,
        _getRecentScans = getRecentScans,
        super(const HomeInitial()) {
    on<HomeLoadDashboard>(_onLoad);
    on<HomeRefreshed>(_onRefresh);
  }

  Future<void> _onLoad(
    HomeLoadDashboard event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefresh(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<HomeState> emit) async {
    try {
      final results = await Future.wait([
        _getStats(),
        _getRecentScans(limit: 5),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Dashboard load timed out.'),
      );
      emit(HomeLoaded(
        stats: results[0] as dynamic,
        recentScans: results[1] as dynamic,
      ));
    } on TimeoutException {
      emit(HomeError('Dashboard load timed out. Pull down to retry.'));
    } catch (e) {
      emit(HomeError('Failed to load dashboard. Pull down to retry.'));
    }
  }
}
