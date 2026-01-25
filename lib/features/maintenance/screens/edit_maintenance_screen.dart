import 'package:flutter/material.dart';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';

class EditMaintenanceScreen extends StatefulWidget {
  final MaintenanceEntry entry;
  final Vehicle vehicle;
  const EditMaintenanceScreen({
    super.key,
    required this.entry,
    required this.vehicle,
  });

  @override
  State<EditMaintenanceScreen> createState() => _EditMaintenanceScreenState();
}

class _EditMaintenanceScreenState extends State<EditMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _recommendationsController = TextEditingController();

  late DateTime _selectedDate;
  late String _category;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing entry data
    _titleController.text = widget.entry.title;
    _descriptionController.text = widget.entry.description;
    _mileageController.text = widget.entry.mileage.toString();
    _costController.text = widget.entry.cost.toString();
    _recommendationsController.text = widget.entry.recommendations;
    _selectedDate = widget.entry.date;
    _category = widget.entry.category;
  }

  void _saveMaintenance() {
    if (!_formKey.currentState!.validate()) return;

    // Update the existing entry
    widget.entry.date = _selectedDate;
    widget.entry.title = _titleController.text.trim();
    widget.entry.description = _descriptionController.text.trim();
    widget.entry.mileage = int.parse(_mileageController.text);
    widget.entry.cost = double.parse(_costController.text);
    widget.entry.category = _category;
    widget.entry.recommendations = _recommendationsController.text.trim();

    widget.entry.save();

    // Update vehicle mileage if needed
    if (widget.vehicle.mileage < widget.entry.mileage) {
      widget.vehicle.mileage = widget.entry.mileage;
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Maintenance'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveMaintenance),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
