import 'package:flutter/material.dart';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:garaji/features/vehicles/screens/add_vehicle_screen.dart';
import 'package:garaji/features/vehicles/screens/edit_vehicle_screen.dart';
import 'package:garaji/features/vehicles/screens/vehicle_details_screen.dart';
import 'package:garaji/features/stats/screens/stats_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehiclesListScreen extends StatelessWidget {
  const VehiclesListScreen({super.key});

  void _deleteVehicle(BuildContext context, Vehicle vehicle) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.brand} ${vehicle.model}? This will also delete all associated maintenance records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Delete all maintenance entries for this vehicle
    final maintenanceBox = Hive.box<MaintenanceEntry>('maintenance');
    final entriesToDelete = maintenanceBox.values
        .where((entry) => entry.vehicleKey == vehicle.key)
        .toList();

    for (var entry in entriesToDelete) {
      await entry.delete();
    }

    // Delete the vehicle
    await vehicle.delete();

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Vehicle>('vehicles');

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Vehicles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Vehicle> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No Vehicles added yet"));
          }
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, index) {
              final vehicle = box.getAt(index)!;
              return Dismissible(
                key: Key(vehicle.key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  _deleteVehicle(context, vehicle);
                  return false; // Prevent automatic dismissal
                },
                child: ListTile(
                  title: Text('${vehicle.brand} ${vehicle.model}'),
                  subtitle: Text('Mileage: ${vehicle.mileage} km'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditVehicleScreen(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
