import 'package:flutter/material.dart';
import 'package:garaji/data/models/vehicle.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _brandController.text = widget.vehicle.brand;
    _modelController.text = widget.vehicle.model;
    _yearController.text = widget.vehicle.year.toString();
    _mileageController.text = widget.vehicle.mileage.toString();
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    widget.vehicle.brand = _brandController.text.trim();
    widget.vehicle.model = _modelController.text.trim();
    widget.vehicle.year = int.parse(_yearController.text);
    widget.vehicle.mileage = int.parse(_mileageController.text);

    widget.vehicle.save();
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
      appBar: AppBar(title: const Text("Edit Vehicle")),
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Mileage'),
                validator: (v) => v == null || int.tryParse(v) == null
                    ? 'Invalid Mileage'
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _saveVehicle,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
