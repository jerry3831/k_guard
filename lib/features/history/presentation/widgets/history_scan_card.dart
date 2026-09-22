import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../scanner/domain/entities/currency_note.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryScanCard extends StatelessWidget {
  final CurrencyNote note;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;

  const HistoryScanCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _verdictColor(note.verdict).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _verdictIcon(note.verdict),
                    color: _verdictColor(note.verdict),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.displayLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        note.serialNumber,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                _VerdictBadge(verdict: note.verdict),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 11,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy-MM-dd   HH:mm a').format(note.timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: 60,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: note.confidenceScore,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _verdictColor(note.verdict),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  note.confidenceLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (onDismissed == null) return card;

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.counterfeit,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      confirmDismiss: (_) async {
        return await _confirmDelete(context);
      },
      onDismissed: (_) => onDismissed?.call(),
      child: card,
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete scan?'),
            content: Text(
              'Remove ${note.displayLabel} from your history? '
              'This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.counterfeit,
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
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
        return Icons.check_circle_rounded;
      case ScanVerdict.suspicious:
        return Icons.warning_amber_rounded;
      case ScanVerdict.counterfeit:
        return Icons.cancel_rounded;
      case ScanVerdict.invalid:
        return Icons.block_rounded;
    }
  }
}


class _VerdictBadge extends StatelessWidget {
  final ScanVerdict verdict;
  const _VerdictBadge({required this.verdict});

  @override
  Widget build(BuildContext context) {
    final color = _verdictColor(verdict);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        verdict.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
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
}
