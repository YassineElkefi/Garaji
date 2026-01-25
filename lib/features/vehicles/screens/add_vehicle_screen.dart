import 'package:flutter/material.dart';
import 'package:garaji/data/models/vehicle.dart';
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
      appBar: AppBar(
        title: const Text("Add Vehicle"),
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
                          Icons.directions_car,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Vehicle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add your vehicle details',
                              style: TextStyle(
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
                          'Vehicle Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A237E),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Brand Field
                        _buildTextField(
                          controller: _brandController,
                          label: 'Brand',
                          hint: 'e.g., Toyota, BMW, Mercedes',
                          icon: Icons.branding_watermark,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Brand is required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Model Field
                        _buildTextField(
                          controller: _modelController,
                          label: 'Model',
                          hint: 'e.g., Camry, X5, C-Class',
                          icon: Icons.car_rental,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Model is required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Year Field
                        _buildTextField(
                          controller: _yearController,
                          label: 'Year',
                          hint: 'e.g., 2020',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Year is required';
                            }
                            final year = int.tryParse(v);
                            if (year == null) return 'Invalid year';
                            if (year < 1900 || year > DateTime.now().year + 1) {
                              return 'Year must be between 1900 and ${DateTime.now().year + 1}';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Mileage Field
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveVehicle,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 24),
                        SizedBox(width: 12),
                        Text('Save Vehicle'),
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
