import '../../../../features/scanner/domain/entities/currency_note.dart';

abstract class HistoryEvent {
  const HistoryEvent();
}

class HistoryLoaded extends HistoryEvent {
  const HistoryLoaded();
}

class HistorySearchChanged extends HistoryEvent {
  final String query;
  const HistorySearchChanged(this.query);
}

class HistoryFilterChanged extends HistoryEvent {
  final HistoryFilter filter;
  const HistoryFilterChanged(this.filter);
}

class HistoryRefreshed extends HistoryEvent {
  const HistoryRefreshed();
}

class HistoryScanDeleted extends HistoryEvent {
  final String scanId;
  const HistoryScanDeleted(this.scanId);
}

enum HistoryFilter {
  all,
  authentic,
  suspicious,
  counterfeit;

  String get label {
    switch (this) {
      case HistoryFilter.all:
        return 'All Scans';
      case HistoryFilter.authentic:
        return 'Authentic';
      case HistoryFilter.suspicious:
        return 'Suspicious';
      case HistoryFilter.counterfeit:
        return 'Counterfeit';
    }
  }

  ScanVerdict? get verdict {
    switch (this) {
      case HistoryFilter.all:
        return null;
      case HistoryFilter.authentic:
        return ScanVerdict.authentic;
      case HistoryFilter.suspicious:
        return ScanVerdict.suspicious;
      case HistoryFilter.counterfeit:
        return ScanVerdict.counterfeit;
    }
  }
}
