import 'package:flutter/material.dart';
import '../providers/history_event.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryFilterTabs extends StatelessWidget {
  final HistoryFilter activeFilter;
  final ValueChanged<HistoryFilter> onFilterSelected;

  const HistoryFilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: HistoryFilter.values.map((filter) {
          final isActive = filter == activeFilter;
          return GestureDetector(
            onTap: () => onFilterSelected(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isActive ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? (isDark ? AppColors.darkBlueBackground : Colors.white)
                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
