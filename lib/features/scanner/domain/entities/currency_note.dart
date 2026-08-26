class CurrencyNote {
  final String id;
  final String denomination;

  final String currencyCode;
  final double confidenceScore;
  final ScanVerdict verdict;
  final String serialNumber;
  final DateTime timestamp;
  final String verificationSource;
  final String? imageLocalPath;

  const CurrencyNote({
    required this.id,
    required this.denomination,
    required this.currencyCode,
    required this.confidenceScore,
    required this.verdict,
    required this.serialNumber,
    required this.timestamp,
    required this.verificationSource,
    this.imageLocalPath,
  });

  String get displayLabel => 'MWK $denomination';

  String get confidenceLabel =>
      '${(confidenceScore * 100).toStringAsFixed(1)}%';

  String get shortSerial {
    if (serialNumber.length <= 10) return serialNumber;
    return '${serialNumber.substring(0, 6)}'
        '...${serialNumber.substring(serialNumber.length - 3)}';
  }

  CurrencyNote copyWith({
    String? id,
    String? denomination,
    String? currencyCode,
    double? confidenceScore,
    ScanVerdict? verdict,
    String? serialNumber,
    DateTime? timestamp,
    String? verificationSource,
    String? imageLocalPath,
  }) {
    return CurrencyNote(
      id: id ?? this.id,
      denomination: denomination ?? this.denomination,
      currencyCode: currencyCode ?? this.currencyCode,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      verdict: verdict ?? this.verdict,
      serialNumber: serialNumber ?? this.serialNumber,
      timestamp: timestamp ?? this.timestamp,
      verificationSource: verificationSource ?? this.verificationSource,
      imageLocalPath: imageLocalPath ?? this.imageLocalPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyNote &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum ScanVerdict {
  authentic,
  suspicious,
  counterfeit,
  invalid;

  String get label {
    switch (this) {
      case ScanVerdict.authentic:
        return 'AUTHENTIC';
      case ScanVerdict.suspicious:
        return 'SUSPICIOUS';
      case ScanVerdict.counterfeit:
        return 'COUNTERFEIT';
      case ScanVerdict.invalid:
        return 'INVALID';
    }
  }

  String get description {
    switch (this) {
      case ScanVerdict.authentic:
        return 'This Malawian Kwacha note appears to be genuine';
      case ScanVerdict.suspicious:
        return 'This note has suspicious characteristics';
      case ScanVerdict.counterfeit:
        return 'This note appears to be counterfeit';
      case ScanVerdict.invalid:
        return 'Please upload or capture a valid banknote image.';
    }
  }
}
