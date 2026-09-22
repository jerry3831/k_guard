import 'dart:io';

abstract class ScannerEvent {
  const ScannerEvent();
}

class ScannerImageCaptured extends ScannerEvent {
  final File imageFile;
  const ScannerImageCaptured(this.imageFile);
}

class ScannerImagePicked extends ScannerEvent {
  final File imageFile;
  const ScannerImagePicked(this.imageFile);
}

class ScannerImageRemoved extends ScannerEvent {
  final int index;
  const ScannerImageRemoved(this.index);
}

class ScannerClearImages extends ScannerEvent {
  const ScannerClearImages();
}

class ScannerStartInference extends ScannerEvent {
  const ScannerStartInference();
}

class ScannerSaveToHistory extends ScannerEvent {
  const ScannerSaveToHistory();
}

class ScannerReset extends ScannerEvent {
  const ScannerReset();
}

class ScannerFlipCamera extends ScannerEvent {
  const ScannerFlipCamera();
}

class ScannerToggleAutoFocus extends ScannerEvent {
  const ScannerToggleAutoFocus();
}
