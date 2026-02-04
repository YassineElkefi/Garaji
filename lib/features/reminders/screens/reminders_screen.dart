import 'package:flutter/material.dart';
import 'package:garaji/data/providers/reminder_provider.dart';
import 'package:garaji/features/reminders/screens/add_reminder_screen.dart';
import 'package:garaji/features/reminders/screens/edit_reminder_screen.dart';
import 'package:garaji/features/reminders/widgets/reminder_card.dart';
import 'package:provider/provider.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Implement sorting/filtering
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
             provider.init();
             return const Center(child: CircularProgressIndicator());
          }

          final reminders = provider.activeReminders;

          if (reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No active reminders',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a reminder to stay on top of maintenance'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ReminderCard(
                reminder: reminder, 
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditReminderScreen(reminder: reminder),
                    ),
                  );
                }, 
                onEdit: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditReminderScreen(reminder: reminder),
                    ),
                  );
                }, 
                onComplete: () {
                  _showCompleteDialog(context, reminder);
                }
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context, dynamic reminder) {
    final mileageController = TextEditingController();
    
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter current mileage to reset this reminder:'),
            const SizedBox(height: 16),
            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Mileage',
                suffixText: 'mi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final mileage = int.tryParse(mileageController.text);
              if (mileage != null) {
                // Update reminder
                reminder.lastServiceDate = DateTime.now();
                reminder.lastServiceMileage = mileage;
                
                final provider = Provider.of<ReminderProvider>(context, listen: false);
                provider.updateReminder(reminder);
                
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Service marked as complete')),
                );
              }
            }, 
            child: const Text('Complete')
          ),
        ],
      )
    );
  }
}
