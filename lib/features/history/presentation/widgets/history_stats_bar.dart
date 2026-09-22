import 'package:flutter/material.dart';

class HistoryStatsBar extends StatelessWidget {
  final int total;
  final int valid;
  final int suspect;
  final int fake;

  const HistoryStatsBar({
    super.key,
    required this.total,
    required this.valid,
    required this.suspect,
    required this.fake,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: 'Total', value: total),
        const SizedBox(width: 10),
        _StatChip(label: 'Valid', value: valid),
        const SizedBox(width: 10),
        _StatChip(label: 'Suspect', value: suspect),
        const SizedBox(width: 10),
        _StatChip(label: 'Fake', value: fake),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
