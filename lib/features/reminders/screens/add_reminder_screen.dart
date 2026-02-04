import 'package:flutter/material.dart';
import 'package:garaji/data/models/service_reminder.dart';
import 'package:garaji/data/providers/reminder_provider.dart';
import 'package:provider/provider.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddReminderScreen extends StatefulWidget {
  final int? preselectedVehicleKey;

  const AddReminderScreen({super.key, this.preselectedVehicleKey});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _intervalDaysController = TextEditingController();
  final _intervalMileageController = TextEditingController();
  final _lastServiceMileageController = TextEditingController();
  
  int? _selectedVehicleKey;
  String _selectedType = 'TIME'; // TIME, MILEAGE, COMBINED
  DateTime? _lastServiceDate;
  String _selectedCategory = 'Oil Change';
  final List<String> _categories = [
    'Oil Change',
    'Tire Rotation',
    'Inspection',
    'Brake Service',
    'Filter Replacement',
    'Fluid Check',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleKey = widget.preselectedVehicleKey;
    _lastServiceDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _intervalDaysController.dispose();
    _intervalMileageController.dispose();
    _lastServiceMileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access Hive box directly
    final vehicleBox = Hive.box<Vehicle>('vehicles');
    final vehicles = vehicleBox.values.toList();

    // If no vehicles, show warning or redirect (handled simply here)
    if (vehicles.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Reminder')),
        body: const Center(child: Text('Please add a vehicle first.')),
      );
    }
    
    // Auto-select first vehicle if none selected
    _selectedVehicleKey ??= vehicles.first.key as int?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Vehicle'),
                value: _selectedVehicleKey,
                items: vehicles.map((v) {
                  return DropdownMenuItem<int>(
                    value: v.key as int,
                    child: Text('${v.year} ${v.brand} ${v.model}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedVehicleKey = val);
                },
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Title and Category
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: _categories.map((c) {
                  return DropdownMenuItem<String>(
                    value: c,
                    child: Text(c),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                     setState(() {
                       _selectedCategory = val;
                       if (val != 'Other') {
                         _titleController.text = val;
                       } else {
                         _titleController.clear();
                       }
                     });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Reminder Title'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Reminder Type Segmented Control (Simulated with Chips or Radio)
              Text('Trigger Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                   _buildTypeChip('Time', 'TIME'),
                   const SizedBox(width: 8),
                   _buildTypeChip('Mileage', 'MILEAGE'),
                   const SizedBox(width: 8),
                   _buildTypeChip('Both', 'COMBINED'),
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic Inputs based on Type
              if (_selectedType == 'TIME' || _selectedType == 'COMBINED') ...[
                TextFormField(
                  controller: _intervalDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Interval (Days)',
                    helperText: 'e.g., 90 for 3 months',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (_selectedType == 'TIME' || _selectedType == 'COMBINED') {
                       if (val == null || val.isEmpty) return 'Required';
                       if (int.tryParse(val) == null) return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Last Service Date'),
                  subtitle: Text(_lastServiceDate!.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastServiceDate!,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _lastServiceDate = picked);
                    }
                  },
                  tileColor: Theme.of(context).inputDecorationTheme.fillColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 16),
              ],

              if (_selectedType == 'MILEAGE' || _selectedType == 'COMBINED') ...[
                 TextFormField(
                  controller: _intervalMileageController,
                  decoration: const InputDecoration(
                    labelText: 'Interval (Miles/Km)',
                    helperText: 'e.g., 5000',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (_selectedType == 'MILEAGE' || _selectedType == 'COMBINED') {
                       if (val == null || val.isEmpty) return 'Required';
                       if (int.tryParse(val) == null) return 'Invalid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                 TextFormField(
                  controller: _lastServiceMileageController,
                  decoration: const InputDecoration(
                    labelText: 'Mileage at Last Service',
                  ),
                  keyboardType: TextInputType.number,
                  // Not strictly required, could assume 0 or current mileage
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Create Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final isSelected = _selectedType == value;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[800];
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: Colors.grey[900],
      onSelected: (selected) {
        if (selected) setState(() => _selectedType = value);
      },
    );
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      
      final intervalDays = int.tryParse(_intervalDaysController.text);
      final intervalMileage = int.tryParse(_intervalMileageController.text);
      final lastMileage = int.tryParse(_lastServiceMileageController.text);

      final reminder = ServiceReminder(
        id: Uuid().v4(),
        vehicleKey: _selectedVehicleKey!,
        title: _titleController.text,
        description: _descriptionController.text,
        reminderType: _selectedType,
        category: _selectedCategory,
        isActive: true,
        intervalDays: intervalDays,
        intervalMileage: intervalMileage,
        lastServiceDate: _lastServiceDate,
        lastServiceMileage: lastMileage,
      );

      provider.addReminder(reminder);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder created successfully')),
      );
    }
  }
}
