import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:garaji/data/models/service_reminder.dart';

class ReminderProvider extends ChangeNotifier {
  late Box<ServiceReminder> _reminderBox;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  List<ServiceReminder> get reminders => _reminderBox.values.toList();

  List<ServiceReminder> get activeReminders =>
      _reminderBox.values.where((r) => r.isActive).toList();

  Future<void> init() async {
    if (_isInitialized) return;
    _reminderBox = await Hive.openBox<ServiceReminder>('serviceReminders');
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> addReminder(ServiceReminder reminder) async {
    _calculateNextDue(reminder);
    await _reminderBox.add(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ServiceReminder reminder) async {
    _calculateNextDue(reminder);
    await reminder.save();
    notifyListeners();
  }

  Future<void> deleteReminder(ServiceReminder reminder) async {
    await reminder.delete();
    notifyListeners();
  }

  // Calculate next due date/mileage based on intervals
  void _calculateNextDue(ServiceReminder reminder) {
    if (reminder.reminderType == 'TIME' || reminder.reminderType == 'COMBINED') {
      if (reminder.intervalDays != null && reminder.lastServiceDate != null) {
        reminder.nextDueDate = reminder.lastServiceDate!.add(Duration(days: reminder.intervalDays!));
      } else if (reminder.intervalDays != null) {
        // If no last service date, assume starts from now
        reminder.nextDueDate = DateTime.now().add(Duration(days: reminder.intervalDays!));
      }
    }

    if (reminder.reminderType == 'MILEAGE' || reminder.reminderType == 'COMBINED') {
      if (reminder.intervalMileage != null && reminder.lastServiceMileage != null) {
        reminder.nextDueMileage = reminder.lastServiceMileage! + reminder.intervalMileage!;
      }
    }
  }

  List<ServiceReminder> getRemindersForVehicle(int vehicleKey) {
    return _reminderBox.values.where((r) => r.vehicleKey == vehicleKey).toList();
  }
}
