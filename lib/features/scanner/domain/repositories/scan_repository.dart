import 'dart:io';
import '../entities/currency_note.dart';

abstract class ScanRepository {
  Future<CurrencyNote> scanImages(List<File> imageFiles);

  Future<void> saveScan(CurrencyNote note);

  Future<List<CurrencyNote>> getScanHistory();
}
