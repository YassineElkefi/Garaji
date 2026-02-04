import 'package:flutter/material.dart';
import 'package:garaji/data/models/service_reminder.dart';
import 'package:garaji/features/reminders/widgets/reminder_status_badge.dart';
import 'package:intl/intl.dart';

class ReminderCard extends StatelessWidget {
  final ServiceReminder reminder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onComplete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onEdit,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final status = _calculateStatus(reminder);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (reminder.vehicleKey != 0) // TODO: Get vehicle name
                           Padding(
                             padding: const EdgeInsets.only(top: 2),
                             child: Text(
                              'Vehicle #${reminder.vehicleKey}', // Placeholder
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF757575),
                              ),
                             ),
                           ),
                      ],
                    ),
                  ),
                  ReminderStatusBadge(status: status),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'complete') onComplete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Mark Complete'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDueInfo(
                    context, 
                    Icons.calendar_today_outlined, 
                    reminder.nextDueDate != null 
                        ? DateFormat.yMMMd().format(reminder.nextDueDate!) 
                        : 'N/A'
                  ),
                  if (reminder.nextDueMileage != null) ...[
                    const SizedBox(width: 16),
                    _buildDueInfo(
                      context, 
                      Icons.speed_outlined, 
                      '${NumberFormat.decimalPattern().format(reminder.nextDueMileage)} mi'
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDueInfo(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFB0B0B0)),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFFB0B0B0),
          ),
        ),
      ],
    );
  }

  ReminderStatus _calculateStatus(ServiceReminder reminder) {
    // This is a simplified check. Real check should compare with current date/mileage
    final now = DateTime.now();
    if (reminder.nextDueDate != null && reminder.nextDueDate!.isBefore(now)) {
      return ReminderStatus.overdue;
    }
    if (reminder.nextDueDate != null && 
        reminder.nextDueDate!.difference(now).inDays <= 7) {
      return ReminderStatus.dueSoon;
    }
    return ReminderStatus.upcoming;
  }
}
