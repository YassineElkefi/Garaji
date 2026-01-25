import 'package:flutter/material.dart';
import 'package:garaji/data/maintenance_entry.dart';
import 'package:garaji/data/vehicle.dart';

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

  DateTime _selectedDate = DateTime.now();
  final String _category = 'Maintenance';

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
        title: Text(widget.entry.title),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              TextFormField(
                //initialValue: widget.entry.description,
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              TextFormField(
                //initialValue: widget.entry.mileage.toString(),
                controller: _mileageController,
                decoration: const InputDecoration(labelText: 'Mileage'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                    ? 'Please enter a valid mileage'
                    : null,
              ),
              TextFormField(
                //initialValue: widget.entry.cost.toString(),
                controller: _costController,
                decoration: const InputDecoration(labelText: 'Cost'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? 'Please enter a valid cost'
                    : null,
              ),
              TextFormField(
                //initialValue: widget.entry.recommendations,
                controller: _recommendationsController,
                decoration: const InputDecoration(labelText: 'Recommendations'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
