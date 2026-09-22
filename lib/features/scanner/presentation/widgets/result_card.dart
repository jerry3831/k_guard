import 'package:flutter/material.dart';
import '../../domain/entities/currency_note.dart';
import '../../../../core/theme/app_colors.dart';

class ResultCard extends StatelessWidget {
  final CurrencyNote note;

  const ResultCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(note.verdict);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: note.verdict == ScanVerdict.suspicious ? 3.0 : 0.0),
                  child: Icon(
                    _verdictIcon(note.verdict),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            note.verdict.label.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note.verdict.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _verdictColor(ScanVerdict verdict) {
    switch (verdict) {
      case ScanVerdict.authentic:
        return AppColors.authentic;
      case ScanVerdict.suspicious:
        return AppColors.suspicious;
      case ScanVerdict.counterfeit:
        return AppColors.counterfeit;
      case ScanVerdict.invalid:
        return Colors.grey.shade700;
    }
  }

  IconData _verdictIcon(ScanVerdict verdict) {
    switch (verdict) {
      case ScanVerdict.authentic:
        return Icons.check_rounded;
      case ScanVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case ScanVerdict.counterfeit:
        return Icons.close_rounded;
      case ScanVerdict.invalid:
        return Icons.warning_amber_rounded;
    }
  }
}
