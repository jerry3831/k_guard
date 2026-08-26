import '../../domain/entities/currency_note.dart';

class CurrencyNoteModel extends CurrencyNote {
  const CurrencyNoteModel({
    required super.id,
    required super.denomination,
    required super.currencyCode,
    required super.confidenceScore,
    required super.verdict,
    required super.serialNumber,
    required super.timestamp,
    required super.verificationSource,
    super.imageLocalPath,
  });

  factory CurrencyNoteModel.fromEntity(CurrencyNote entity) {
    return CurrencyNoteModel(
      id: entity.id,
      denomination: entity.denomination,
      currencyCode: entity.currencyCode,
      confidenceScore: entity.confidenceScore,
      verdict: entity.verdict,
      serialNumber: entity.serialNumber,
      timestamp: entity.timestamp,
      verificationSource: entity.verificationSource,
      imageLocalPath: entity.imageLocalPath,
    );
  }

  factory CurrencyNoteModel.fromJson(Map<String, dynamic> json) {
    return CurrencyNoteModel(
      id: json['id'] as String,
      denomination: json['denomination'] as String,
      currencyCode: json['currency_code'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      verdict: CurrencyNoteModel.verdictFromString(json['verdict'] as String),
      serialNumber: json['serial_number'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
      verificationSource: json['verification_source'] as String? ??
          'Cloud ResNet-50',
      imageLocalPath: json['image_local_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'denomination': denomination,
        'currency_code': currencyCode,
        'confidence_score': confidenceScore,
        'verdict': verdict.name,
        'serial_number': serialNumber,
        'timestamp': timestamp.toIso8601String(),
        'verification_source': verificationSource,
        if (imageLocalPath != null) 'image_local_path': imageLocalPath,
      };

  static ScanVerdict verdictFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'authentic':
        return ScanVerdict.authentic;
      case 'suspicious':
        return ScanVerdict.suspicious;
      case 'counterfeit':
        return ScanVerdict.counterfeit;
      case 'invalid':
        return ScanVerdict.invalid;
      default:
        throw ArgumentError('Unknown verdict: $raw');
    }
  }
}
