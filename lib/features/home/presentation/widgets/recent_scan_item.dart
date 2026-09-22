import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../scanner/domain/entities/currency_note.dart';
import '../../../../core/theme/app_colors.dart';

class RecentScanItem extends StatelessWidget {
  final CurrencyNote note;
  final VoidCallback? onTap;

  const RecentScanItem({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final verdictColor = _verdictColor(verdict: note.verdict, isDark: isDark);
    final timeAgo = _timeAgo(note.timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: verdictColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _verdictIcon(note.verdict),
                color: verdictColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.displayLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${note.verdict.label.toLowerCase().capitalize()} • '
                    '${note.confidenceLabel}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 10, color: isDark ? Colors.white70 : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _verdictColor({required ScanVerdict verdict, required bool isDark}) {
    switch (verdict) {
      case ScanVerdict.authentic:
        return AppColors.authentic;
      case ScanVerdict.suspicious:
        return AppColors.suspicious;
      case ScanVerdict.counterfeit:
        return isDark ? const Color(0xFFEF5350) : AppColors.counterfeit;
      case ScanVerdict.invalid:
        return isDark ? Colors.grey.shade400 : Colors.grey.shade700;
    }
  }

  IconData _verdictIcon(ScanVerdict verdict) {
    switch (verdict) {
      case ScanVerdict.authentic:
        return Icons.check_circle_rounded;
      case ScanVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case ScanVerdict.counterfeit:
        return Icons.cancel_rounded;
      case ScanVerdict.invalid:
        return Icons.block_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return DateFormat('MMM d').format(dt);
  }
}

extension _StringExt on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
