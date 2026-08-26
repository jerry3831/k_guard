import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';
import '../../domain/usecases/delete_scan_usecase.dart';
import '../../../../features/scanner/domain/entities/currency_note.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetScanHistoryUseCase _getHistory;
  final DeleteScanUseCase _deleteScan;

  HistoryBloc({
    required GetScanHistoryUseCase getHistory,
    required DeleteScanUseCase deleteScan,
  })  : _getHistory = getHistory,
        _deleteScan = deleteScan,
        super(const HistoryInitial()) {
    on<HistoryLoaded>(_onLoaded);
    on<HistoryRefreshed>(_onRefreshed);
    on<HistoryFilterChanged>(_onFilterChanged);
    on<HistorySearchChanged>(_onSearchChanged);
    on<HistoryScanDeleted>(_onScanDeleted);
  }


  Future<void> _onLoaded(
    HistoryLoaded event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    await _fetchAndEmit(
      emit,
      filter: HistoryFilter.all,
      query: '',
    );
  }

  Future<void> _onRefreshed(
    HistoryRefreshed event,
    Emitter<HistoryState> emit,
  ) async {
    // Retain current filter and search context if history was already loaded
    final current = state is HistoryLoadSuccess
        ? state as HistoryLoadSuccess
        : null;

    await _fetchAndEmit(
      emit,
      filter: current?.activeFilter ?? HistoryFilter.all,
      query: current?.searchQuery ?? '',
    );
  }

  void _onFilterChanged(
    HistoryFilterChanged event,
    Emitter<HistoryState> emit,
  ) {
    if (state is! HistoryLoadSuccess) return;
    final current = state as HistoryLoadSuccess;

    emit(current.copyWith(
      activeFilter: event.filter,
      displayedScans: _applyFilterAndSearch(
        current.allScans,
        event.filter,
        current.searchQuery,
      ),
    ));
  }

  void _onSearchChanged(
    HistorySearchChanged event,
    Emitter<HistoryState> emit,
  ) {
    if (state is! HistoryLoadSuccess) return;
    final current = state as HistoryLoadSuccess;

    emit(current.copyWith(
      searchQuery: event.query,
      displayedScans: _applyFilterAndSearch(
        current.allScans,
        current.activeFilter,
        event.query,
      ),
    ));
  }

  Future<void> _onScanDeleted(
    HistoryScanDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoadSuccess) return;
    final current = state as HistoryLoadSuccess;

    try {
      await _deleteScan(event.scanId);

      // Re-calculate derived lists and summary statistics locally to avoid redundant API calls
      final updatedAll =
          current.allScans.where((n) => n.id != event.scanId).toList();

      emit(current.copyWith(
        allScans: updatedAll,
        displayedScans: _applyFilterAndSearch(
          updatedAll,
          current.activeFilter,
          current.searchQuery,
        ),
        totalCount: updatedAll.length,
        validCount: updatedAll
            .where((n) => n.verdict == ScanVerdict.authentic)
            .length,
        suspectCount: updatedAll
            .where((n) => n.verdict == ScanVerdict.suspicious)
            .length,
        fakeCount: updatedAll
            .where((n) => n.verdict == ScanVerdict.counterfeit)
            .length,
      ));
    } catch (_) {
    }
  }


  Future<void> _fetchAndEmit(
    Emitter<HistoryState> emit, {
    required HistoryFilter filter,
    required String query,
  }) async {
    try {
      final all = await _getHistory();

      emit(HistoryLoadSuccess(
        allScans: all,
        displayedScans: _applyFilterAndSearch(all, filter, query),
        activeFilter: filter,
        searchQuery: query,
        totalCount: all.length,
        validCount: all
            .where((n) => n.verdict == ScanVerdict.authentic)
            .length,
        suspectCount: all
            .where((n) => n.verdict == ScanVerdict.suspicious)
            .length,
        fakeCount: all
            .where((n) => n.verdict == ScanVerdict.counterfeit)
            .length,
      ));
    } catch (e) {
      emit(HistoryLoadFailure(
        'Could not load scan history. Pull down to retry.',
      ));
    }
  }

  List<CurrencyNote> _applyFilterAndSearch(
    List<CurrencyNote> all,
    HistoryFilter filter,
    String query,
  ) {
    // Chain filter conditions: First by verdict status, then by search string
    var result = all;

    if (filter.verdict != null) {
      result = result.where((n) => n.verdict == filter.verdict).toList();
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((n) {
        return n.displayLabel.toLowerCase().contains(trimmed) ||
            n.serialNumber.toLowerCase().contains(trimmed) ||
            n.denomination.toLowerCase().contains(trimmed) ||
            n.currencyCode.toLowerCase().contains(trimmed);
      }).toList();
    }

    return result;
  }
}
