import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatsService {
  static List<MaintenanceEntry> getEntriesForVehicle(int? vehicleKey) {
    final box = Hive.box<MaintenanceEntry>('maintenance');
    if (vehicleKey == null) {
      return box.values.toList();
    }
    return box.values.where((e) => e.vehicleKey == vehicleKey).toList();
  }

  static Map<int, double> getYearlyStats(int? vehicleKey) {
    final entries = getEntriesForVehicle(vehicleKey);
    final Map<int, double> yearlyStats = {};

    for (var entry in entries) {
      final year = entry.date.year;
      yearlyStats[year] = (yearlyStats[year] ?? 0) + entry.cost;
    }

    return Map.fromEntries(
      yearlyStats.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static Map<String, double> getMonthlyStats(int year, int? vehicleKey) {
    final entries = getEntriesForVehicle(
      vehicleKey,
    ).where((e) => e.date.year == year).toList();

    final Map<int, double> monthlyStats = {};

    for (var entry in entries) {
      final month = entry.date.month;
      monthlyStats[month] = (monthlyStats[month] ?? 0) + entry.cost;
    }

    // Convert to month names
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return {
      for (var i = 1; i <= 12; i++) monthNames[i - 1]: monthlyStats[i] ?? 0.0,
    };
  }

  static Map<String, double> getCategoryStats(int? vehicleKey) {
    final entries = getEntriesForVehicle(vehicleKey);
    final Map<String, double> categoryStats = {};

    for (var entry in entries) {
      categoryStats[entry.category] =
          (categoryStats[entry.category] ?? 0) + entry.cost;
    }

    return categoryStats;
  }

  static double getTotalCost(int? vehicleKey) {
    final entries = getEntriesForVehicle(vehicleKey);
    return entries.fold(0.0, (sum, entry) => sum + entry.cost);
  }

  static double getAverageCost(int? vehicleKey) {
    final entries = getEntriesForVehicle(vehicleKey);
    if (entries.isEmpty) return 0.0;
    return getTotalCost(vehicleKey) / entries.length;
  }

  static int getEntryCount(int? vehicleKey) {
    return getEntriesForVehicle(vehicleKey).length;
  }
}
