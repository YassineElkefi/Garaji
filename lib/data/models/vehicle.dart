import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class Vehicle extends HiveObject {

  @HiveField(0)
  String brand;

  @HiveField(1)
  String model;

  @HiveField(2)
  int year;

  @HiveField(3)
  int mileage;

  Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage
  });
}