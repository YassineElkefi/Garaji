import 'package:hive/hive.dart';

part 'maintenance_entry.g.dart';

@HiveType(typeId:1)
class MaintenanceEntry extends HiveObject {
  
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int mileage;

  @HiveField(4)
  double cost;

  @HiveField(5)
  String category;

  @HiveField(6)
  String recommendations;

  MaintenanceEntry({
    required this.date,
    required this.title,
    required this.description,
    required this.mileage,
    required this.cost,
    required this.category,
    required this.recommendations,
  });
}