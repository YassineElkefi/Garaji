import 'package:flutter/material.dart';
import 'package:garaji/data/models/service_reminder.dart';
import 'package:garaji/data/providers/reminder_provider.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class EditReminderScreen extends StatefulWidget {
  final ServiceReminder reminder;

  const EditReminderScreen({super.key, required this.reminder});

  @override
  State<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends State<EditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _intervalDaysController;
  late TextEditingController _intervalMileageController;
  late TextEditingController _lastServiceMileageController;
  
  int? _selectedVehicleKey;
  String _selectedType = 'TIME';
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
    final r = widget.reminder;
    _titleController = TextEditingController(text: r.title);
    _descriptionController = TextEditingController(text: r.description);
    _intervalDaysController = TextEditingController(text: r.intervalDays?.toString() ?? '');
    _intervalMileageController = TextEditingController(text: r.intervalMileage?.toString() ?? '');
    _lastServiceMileageController = TextEditingController(text: r.lastServiceMileage?.toString() ?? '');
    
    _selectedVehicleKey = r.vehicleKey;
    _selectedType = r.reminderType;
    _lastServiceDate = r.lastServiceDate;
    _selectedCategory = _categories.contains(r.category) ? r.category : 'Other';
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
    final vehicleBox = Hive.box<Vehicle>('vehicles');
    final vehicles = vehicleBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Service Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _deleteReminder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Vehicle'),
                value: _selectedVehicleKey,
                items: vehicles.map((v) {
                  return DropdownMenuItem<int>(
                    value: v.key as int,
                    child: Text('${v.year} ${v.brand} ${v.model}'),
                  );
                }).toList(),
                onChanged: null, // Vehicle cannot be changed after creation easily
                validator: (val) => val == null ? 'Required' : null,
                enableFeedback: false,
              ),
              const SizedBox(height: 16),

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
                       if (val != 'Other' && _titleController.text == widget.reminder.title) {
                          // Update title only if it hasn't been custom modified (simplified logic)
                          _titleController.text = val;
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

              if (_selectedType == 'TIME' || _selectedType == 'COMBINED') ...[
                TextFormField(
                  controller: _intervalDaysController,
                  decoration: const InputDecoration(
                    labelText: 'Interval (Days)',
                    helperText: 'e.g., 90',
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
                  subtitle: Text(_lastServiceDate != null 
                    ? _lastServiceDate!.toString().split(' ')[0] 
                    : 'Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _lastServiceDate ?? DateTime.now(),
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
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Save Changes'),
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

      widget.reminder.title = _titleController.text;
      widget.reminder.description = _descriptionController.text;
      widget.reminder.reminderType = _selectedType;
      widget.reminder.category = _selectedCategory;
      widget.reminder.intervalDays = intervalDays;
      widget.reminder.intervalMileage = intervalMileage;
      widget.reminder.lastServiceDate = _lastServiceDate;
      widget.reminder.lastServiceMileage = lastMileage;

      provider.updateReminder(widget.reminder);
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder updated successfully')),
      );
    }
  }

  void _deleteReminder() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: const Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<ReminderProvider>(context, listen: false);
              provider.deleteReminder(widget.reminder);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            }, 
            child: const Text('Delete', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
