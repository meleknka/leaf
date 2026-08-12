import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final IconData icon;

  const GoalCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = target > 0
        ? (current / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4E9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE3DBCA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF667A55),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '$current / $target',
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 9),

          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFDDE2D4),
            color: const Color(0xFF7A8E69),
          ),
        ],
      ),
    );
  }
}