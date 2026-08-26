import 'dart:io';
import '../entities/currency_note.dart';
import '../repositories/scan_repository.dart';

class PerformScanUseCase {
  final ScanRepository _repository;

  const PerformScanUseCase(this._repository);

  Future<CurrencyNote> call(List<File> imageFiles) async {
    if (imageFiles.isEmpty) {
      throw ArgumentError('At least one image file must be provided');
    }
    for (var imageFile in imageFiles) {
      if (!imageFile.existsSync()) {
        throw ArgumentError('Image file does not exist: ${imageFile.path}');
      }
    }

    final result = await _repository.scanImages(imageFiles);
    return result;
  }
}
