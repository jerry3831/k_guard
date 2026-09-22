import 'package:flutter/material.dart';

class ScanSummaryCard extends StatelessWidget {
  final int totalScans;
  final int suspiciousNotes;

  const ScanSummaryCard({
    super.key,
    required this.totalScans,
    required this.suspiciousNotes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('Total Scans', totalScans.toString(), theme.colorScheme.onPrimaryContainer),
          Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
          _buildStatColumn('Suspicious', suspiciousNotes.toString(), Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: valueColor),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}