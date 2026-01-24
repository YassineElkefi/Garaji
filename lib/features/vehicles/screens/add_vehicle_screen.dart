import 'package:flutter/material.dart';
import 'package:garaji/data/vehicle.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      mileage: int.parse(_mileageController.text),
    );

    Hive.box<Vehicle>('vehicles').add(vehicle);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Vehicle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Invalid Year'
                    : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Mileage'),
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Invalid Mileage'
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveVehicle,
                child: const Text('Save Vehicle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
