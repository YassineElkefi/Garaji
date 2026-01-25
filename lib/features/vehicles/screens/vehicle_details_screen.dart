import 'package:flutter/material.dart';
import 'package:garaji/data/maintenance_entry.dart';
import 'package:garaji/data/vehicle.dart';
import 'package:garaji/features/vehicles/screens/add_maintenance_screen.dart';
import 'package:garaji/features/vehicles/screens/edit_maintenance_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final maintenanceBox = Hive.box<MaintenanceEntry>('maintenance');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicle.brand} ${widget.vehicle.model}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.vehicle.brand} ${widget.vehicle.model}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Year: ${widget.vehicle.year}'),
                    Text('Moleage: ${widget.vehicle.mileage} km'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Maintenance History',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: maintenanceBox.listenable(),
                builder: (context, Box<MaintenanceEntry> box, _) {
                  final entries =
                      box.values
                          .where((e) => e.vehicleKey == widget.vehicle.key)
                          .toList()
                        ..sort((a, b) => b.date.compareTo(a.date));

                  if (entries.isEmpty) {
                    return const Center(child: Text('No maintenance records'));
                  }

                  final totalCost = entries.fold<double>(
                    0,
                    (sum, e) => sum + e.cost,
                  );

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Total Spent: ${totalCost.toStringAsFixed(2)} DT',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (_, index) {
                            final e = entries[index];
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  // Navigate to edit maintenance screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditMaintenanceScreen(
                                        entry: e,
                                        vehicle: widget.vehicle,
                                      ),
                                    ),
                                  );
                                  setState(() {});
                                },
                                title: Text(e.title),
                                subtitle: Text(
                                  '${e.date.day}/${e.date.month}/${e.date.year} • ${e.mileage} km}',
                                ),
                                trailing: Text('${e.cost} DT'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMaintenanceScreen(vehicle: widget.vehicle),
            ),
          );
          setState(() {});
        },
      ),
    );
  }
}
