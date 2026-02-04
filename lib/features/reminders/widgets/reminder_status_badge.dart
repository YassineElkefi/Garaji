import 'package:flutter/material.dart';

enum ReminderStatus {
  overdue,
  dueSoon,
  upcoming,
}

class ReminderStatusBadge extends StatelessWidget {
  final ReminderStatus status;
  final bool compact;

  const ReminderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case ReminderStatus.overdue:
        color = const Color(0xFFCF6679);
        label = 'Overdue';
        icon = Icons.warning_rounded;
        break;
      case ReminderStatus.dueSoon:
        color = const Color(0xFFFF9800);
        label = 'Due Soon';
        icon = Icons.access_time_rounded;
        break;
      case ReminderStatus.upcoming:
        color = const Color(0xFF4CAF50);
        label = 'Upcoming';
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    if (compact) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
