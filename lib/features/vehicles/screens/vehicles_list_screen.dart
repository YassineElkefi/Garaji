import 'package:flutter/material.dart';
import 'package:garaji/data/vehicle.dart';
import 'package:garaji/features/vehicles/screens/add_vehicle_screen.dart';
import 'package:garaji/features/vehicles/screens/vehicle_details_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehiclesListScreen extends StatelessWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Vehicle>('vehicles');

    return Scaffold(
      appBar: AppBar(title: const Text("My Vehicles")),
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
              return ListTile(
                title: Text('${vehicle.brand} ${vehicle.model}'),
                subtitle: Text('Mileage: ${vehicle.mileage} km'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                    ),
                  );
                },
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
