import 'package:flutter/material.dart';
import 'package:garaji/data/models/maintenance_entry.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:garaji/features/home/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(VehicleAdapter());
  Hive.registerAdapter(MaintenanceEntryAdapter());

  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<MaintenanceEntry>('maintenance');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Garaji',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFD4AF37),
          surface: const Color(0xFFF5F7FA),
          error: const Color(0xFFC62828),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4AF37),
            foregroundColor: const Color(0xFF1A237E),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFD4AF37),
          foregroundColor: Color(0xFF1A237E),
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFC62828)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(color: Color(0xFF616161)),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF212121),
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: Color(0xFF212121)),
          bodyMedium: TextStyle(color: Color(0xFF616161)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
