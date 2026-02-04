import 'package:hive/hive.dart';

part 'service_reminder.g.dart';

@HiveType(typeId: 2)
class ServiceReminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int vehicleKey;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  String reminderType; // 'TIME', 'MILEAGE', 'COMBINED'

  @HiveField(5)
  int? intervalDays;

  @HiveField(6)
  int? intervalMileage;

  @HiveField(7)
  DateTime? lastServiceDate;

  @HiveField(8)
  int? lastServiceMileage;

  @HiveField(9)
  DateTime? nextDueDate;

  @HiveField(10)
  int? nextDueMileage;

  @HiveField(11)
  bool isActive;

  @HiveField(12)
  int? notificationId;

  @HiveField(13)
  String category;

  ServiceReminder({
    required this.id,
    required this.vehicleKey,
    required this.title,
    required this.description,
    required this.reminderType,
    this.intervalDays,
    this.intervalMileage,
    this.lastServiceDate,
    this.lastServiceMileage,
    this.nextDueDate,
    this.nextDueMileage,
    required this.isActive,
    this.notificationId,
    required this.category,
  });
}
