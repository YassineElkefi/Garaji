import 'package:flutter/material.dart';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:garaji/features/maintenance/screens/add_maintenance_screen.dart';
import 'package:garaji/features/maintenance/screens/edit_maintenance_screen.dart';
import 'package:garaji/features/vehicles/services/pdf_export_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;
  const VehicleDetailsScreen({super.key, required this.vehicle});

  void _deleteMaintenanceEntry(
    BuildContext context,
    MaintenanceEntry entry,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Maintenance Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
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

    await entry.delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance entry deleted')),
      );
    }
  }

  Future<void> _exportToPdf(
    BuildContext context,
    List<MaintenanceEntry> entries,
  ) async {
    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No maintenance records to export')),
      );
      return;
    }

    try {
      await PdfExportService.exportMaintenanceToPdf(vehicle, entries);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleBox = Hive.box<Vehicle>('vehicles');
    final maintenanceBox = Hive.box<MaintenanceEntry>('maintenance');

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehicle.brand} ${vehicle.model}'),
        actions: [
          ValueListenableBuilder(
            valueListenable: maintenanceBox.listenable(),
            builder: (context, Box<MaintenanceEntry> box, _) {
              final entries = box.values
                  .where((e) => e.vehicleKey == vehicle.key)
                  .toList();

              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () => _exportToPdf(context, entries),
                tooltip: 'Export to PDF',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle info card - now listening to vehicle changes
            ValueListenableBuilder(
              valueListenable: vehicleBox.listenable(),
              builder: (context, Box<Vehicle> box, _) {
                // Get the latest vehicle data
                final currentVehicle = box.get(vehicle.key) ?? vehicle;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currentVehicle.brand} ${currentVehicle.model}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Year: ${currentVehicle.year}'),
                        Text('Mileage: ${currentVehicle.mileage} km'),
                      ],
                    ),
                  ),
                );
              },
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
                          .where((e) => e.vehicleKey == vehicle.key)
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
                            return Dismissible(
                              key: Key(e.key.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                _deleteMaintenanceEntry(context, e);
                                return false; // Prevent automatic dismissal
                              },
                              child: Card(
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditMaintenanceScreen(
                                          entry: e,
                                          vehicle: vehicle,
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(e.title),
                                  subtitle: Text(
                                    '${e.date.day}/${e.date.month}/${e.date.year} • ${e.mileage} km',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${e.cost} DT'),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
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
              builder: (_) => AddMaintenanceScreen(vehicle: vehicle),
            ),
          );
        },
      ),
    );
  }
}
