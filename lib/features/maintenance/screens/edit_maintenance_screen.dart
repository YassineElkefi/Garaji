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

    widget.entry.date = _selectedDate;
    widget.entry.title = _titleController.text.trim();
    widget.entry.description = _descriptionController.text.trim();
    widget.entry.mileage = int.parse(_mileageController.text);
    widget.entry.cost = double.parse(_costController.text);
    widget.entry.category = _category;
    widget.entry.recommendations = _recommendationsController.text.trim();

    widget.entry.save();

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF212121),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Maintenance'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: Color(0xFFD4AF37),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.vehicle.brand} ${widget.vehicle.model}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Form Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'e.g., Oil Change, Brake Inspection',
                          icon: Icons.title,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(
                              Icons.category,
                              color: Color(0xFFD4AF37),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Maintenance',
                              child: Text('Maintenance'),
                            ),
                            DropdownMenuItem(
                              value: 'Repair',
                              child: Text('Repair'),
                            ),
                            DropdownMenuItem(
                              value: 'Inspection',
                              child: Text('Inspection'),
                            ),
                            DropdownMenuItem(
                              value: 'Wash',
                              child: Text('Wash'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _category = value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFFD4AF37),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Service Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF616161),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _mileageController,
                          label: 'Mileage (km)',
                          hint: 'e.g., 50000',
                          icon: Icons.speed,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Mileage is required';
                            }
                            if (int.tryParse(v) == null) {
                              return 'Invalid mileage';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _costController,
                          label: 'Cost (DT)',
                          hint: 'e.g., 150.00',
                          icon: Icons.payments,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Cost is required';
                            }
                            if (double.tryParse(v) == null) {
                              return 'Invalid cost';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Detailed description of the service',
                            prefixIcon: const Icon(
                              Icons.description,
                              color: Color(0xFFD4AF37),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _recommendationsController,
                          decoration: InputDecoration(
                            labelText: 'Recommendations',
                            hintText: 'Future maintenance recommendations',
                            prefixIcon: const Icon(
                              Icons.lightbulb,
                              color: Color(0xFFD4AF37),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveMaintenance,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 24),
                        SizedBox(width: 12),
                        Text('Save Changes'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
      ),
      validator: validator,
    );
  }
}
