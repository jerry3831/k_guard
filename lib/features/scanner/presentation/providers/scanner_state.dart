import 'dart:io';
import '../../domain/entities/currency_note.dart';

abstract class ScannerState {
  const ScannerState();
}

class ScannerIdle extends ScannerState {
  final bool isFrontCamera;
  final bool autoFocusEnabled;
  final List<File> stagedImages;

  const ScannerIdle({
    this.isFrontCamera = false,
    this.autoFocusEnabled = true,
    this.stagedImages = const [],
  });

  ScannerIdle copyWith({
    bool? isFrontCamera, 
    bool? autoFocusEnabled,
    List<File>? stagedImages,
  }) {
    return ScannerIdle(
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      autoFocusEnabled: autoFocusEnabled ?? this.autoFocusEnabled,
      stagedImages: stagedImages ?? this.stagedImages,
    );
  }
}

class ScannerAnalyzing extends ScannerState {
  final List<File> images;
  const ScannerAnalyzing(this.images);
}

class ScannerSuccess extends ScannerState {
  final CurrencyNote result;
  final bool savedToHistory;

  const ScannerSuccess({
    required this.result,
    this.savedToHistory = false,
  });

  ScannerSuccess copyWith({CurrencyNote? result, bool? savedToHistory}) {
    return ScannerSuccess(
      result: result ?? this.result,
      savedToHistory: savedToHistory ?? this.savedToHistory,
    );
  }
}

class ScannerFailure extends ScannerState {
  final String message;
  const ScannerFailure(this.message);
}

class ScannerSaving extends ScannerState {
  final CurrencyNote result;
  const ScannerSaving(this.result);
}
