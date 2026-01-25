import 'package:flutter/material.dart';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddMaintenanceScreen extends StatefulWidget {
  final Vehicle vehicle;
  const AddMaintenanceScreen({super.key, required this.vehicle});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _recommendationsController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _category = 'Maintenance';

  void _saveMaintenance() {
    if (!_formKey.currentState!.validate()) return;

    final entry = MaintenanceEntry(
      date: _selectedDate,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      mileage: int.parse(_mileageController.text),
      cost: double.parse(_costController.text),
      category: _category,
      recommendations: _recommendationsController.text.trim(),
      vehicleKey: widget.vehicle.key as int,
    );

    Hive.box<MaintenanceEntry>('maintenance').add(entry);

    // Updating Mileage if it gets higher
    if (entry.mileage > widget.vehicle.mileage) {
      widget.vehicle.mileage = entry.mileage;
      widget.vehicle.save();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    _recommendationsController.dispose();
    super.dispose();
  }

  Future _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Maintenance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(
                    value: 'Maintenance',
                    child: Text('Maintenance'),
                  ),
                  DropdownMenuItem(value: 'Repair', child: Text('Repair')),
                  DropdownMenuItem(
                    value: 'Inspection',
                    child: Text('Inspection'),
                  ),
                  DropdownMenuItem(value: 'Wash', child: Text('Wash')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),

              const SizedBox(height: 12),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 12),

              // Mileage
              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Mileage (km)'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Invalid mileage'
                    : null,
              ),

              const SizedBox(height: 12),

              // Cost
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost (DT)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => v == null || double.tryParse(v) == null
                    ? 'Invalid cost'
                    : null,
              ),

              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              // Recommendations
              TextFormField(
                controller: _recommendationsController,
                decoration: const InputDecoration(labelText: 'Recommendations'),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveMaintenance,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
