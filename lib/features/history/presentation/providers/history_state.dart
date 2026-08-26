import '../../../../features/scanner/domain/entities/currency_note.dart';
import 'history_event.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoadSuccess extends HistoryState {
  final List<CurrencyNote> allScans;

  final List<CurrencyNote> displayedScans;

  final HistoryFilter activeFilter;
  final String searchQuery;

  final int totalCount;
  final int validCount;
  final int suspectCount;
  final int fakeCount;

  const HistoryLoadSuccess({
    required this.allScans,
    required this.displayedScans,
    required this.activeFilter,
    required this.searchQuery,
    required this.totalCount,
    required this.validCount,
    required this.suspectCount,
    required this.fakeCount,
  });

  HistoryLoadSuccess copyWith({
    List<CurrencyNote>? allScans,
    List<CurrencyNote>? displayedScans,
    HistoryFilter? activeFilter,
    String? searchQuery,
    int? totalCount,
    int? validCount,
    int? suspectCount,
    int? fakeCount,
  }) {
    return HistoryLoadSuccess(
      allScans: allScans ?? this.allScans,
      displayedScans: displayedScans ?? this.displayedScans,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      totalCount: totalCount ?? this.totalCount,
      validCount: validCount ?? this.validCount,
      suspectCount: suspectCount ?? this.suspectCount,
      fakeCount: fakeCount ?? this.fakeCount,
    );
  }
}

class HistoryLoadFailure extends HistoryState {
  final String message;
  const HistoryLoadFailure(this.message);
}
