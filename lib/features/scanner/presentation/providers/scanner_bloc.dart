import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/perform_scan_usecase.dart';
import '../../domain/repositories/scan_repository.dart';
import '../../domain/entities/currency_note.dart';
import '../../../../core/error/exceptions.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final PerformScanUseCase _performScan;
  final ScanRepository _repository;

  ScannerBloc({
    required PerformScanUseCase performScan,
    required ScanRepository repository,
  })  : _performScan = performScan,
        _repository = repository,
        super(const ScannerIdle()) {
    on<ScannerImageCaptured>(_onImageCaptured);
    on<ScannerImagePicked>(_onImagePicked);
    on<ScannerImageRemoved>(_onImageRemoved);
    on<ScannerClearImages>(_onClearImages);
    on<ScannerStartInference>(_onStartInference);
    on<ScannerSaveToHistory>(_onSaveToHistory);
    on<ScannerReset>(_onReset);
    on<ScannerFlipCamera>(_onFlipCamera);
    on<ScannerToggleAutoFocus>(_onToggleAutoFocus);
  }


  Future<void> _onImageCaptured(
    ScannerImageCaptured event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      final newImages = List<File>.from(current.stagedImages)..add(event.imageFile);
      emit(current.copyWith(stagedImages: newImages));
    }
  }

  Future<void> _onImagePicked(
    ScannerImagePicked event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      final newImages = List<File>.from(current.stagedImages)..add(event.imageFile);
      emit(current.copyWith(stagedImages: newImages));
    }
  }

  void _onImageRemoved(
    ScannerImageRemoved event,
    Emitter<ScannerState> emit,
  ) {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      final newImages = List<File>.from(current.stagedImages)..removeAt(event.index);
      emit(current.copyWith(stagedImages: newImages));
    }
  }

  void _onClearImages(
    ScannerClearImages event,
    Emitter<ScannerState> emit,
  ) {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      emit(current.copyWith(stagedImages: []));
    }
  }

  Future<void> _onStartInference(
    ScannerStartInference event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      if (current.stagedImages.isNotEmpty) {
        await _runScan(current.stagedImages, emit);
      }
    }
  }

  Future<void> _onSaveToHistory(
    ScannerSaveToHistory event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is! ScannerSuccess) return;

    final currentResult = (state as ScannerSuccess).result;
    emit(ScannerSaving(currentResult));

    try {
      await _repository.saveScan(currentResult);
      emit(ScannerSuccess(result: currentResult, savedToHistory: true));
    } catch (e) {
      emit(ScannerSuccess(result: currentResult));
    }
  }

  void _onReset(ScannerReset event, Emitter<ScannerState> emit) {
    emit(const ScannerIdle());
  }

  void _onFlipCamera(ScannerFlipCamera event, Emitter<ScannerState> emit) {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      emit(current.copyWith(isFrontCamera: !current.isFrontCamera));
    }
  }

  void _onToggleAutoFocus(
    ScannerToggleAutoFocus event,
    Emitter<ScannerState> emit,
  ) {
    if (state is ScannerIdle) {
      final current = state as ScannerIdle;
      emit(current.copyWith(autoFocusEnabled: !current.autoFocusEnabled));
    }
  }


  Future<void> _runScan(
    List<File> imageFiles,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerAnalyzing(imageFiles));

    try {
      // Offload ML inference to the remote AI service via usecase
      final CurrencyNote result = await _performScan(imageFiles);
      emit(ScannerSuccess(result: result));
    } on NetworkException catch (e) {
      emit(ScannerFailure(e.message));
      emit(ScannerIdle(stagedImages: imageFiles));
    } on ServerException catch (e) {
      emit(ScannerFailure(e.message));
      emit(ScannerIdle(stagedImages: imageFiles));
    } on ScanException catch (e) {
      emit(ScannerFailure(e.message));
      emit(ScannerIdle(stagedImages: imageFiles));
    } catch (e) {
      emit(ScannerFailure('An unexpected error occurred. Please try again.'));
      emit(ScannerIdle(stagedImages: imageFiles));
    }
  }
}
