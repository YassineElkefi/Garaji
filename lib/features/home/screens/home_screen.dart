import 'dart:io';
import 'package:flutter/material.dart';
import 'package:garaji/features/vehicles/screens/vehicles_list_screen.dart';
import 'package:garaji/features/stats/screens/stats_screen.dart';

import 'package:garaji/features/reminders/screens/reminders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const VehiclesListScreenContent(),
    const RemindersScreen(),
    const StatsScreenContent(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildAdaptiveBottomNavBar(),
    );
  }

  Widget _buildAdaptiveBottomNavBar() {
    final isIOS = Platform.isIOS;

    if (isIOS) {
      return _buildLiquidGlassBottomNav();
    } else {
      return _buildStandardBottomNav();
    }
  }

  Widget _buildLiquidGlassBottomNav() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(25),
        topRight: Radius.circular(25),
      ),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          const Color(0xFF1E1E1E).withValues(alpha: 0.8),
          BlendMode.srcOver,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFDC143C).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 85,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavBarItem(
                    index: 0,
                    icon: Icons.directions_car_rounded,
                    label: 'Vehicles',
                  ),
                  _buildNavBarItem(
                    index: 1,
                    icon: Icons.notifications_active_rounded,
                    label: 'Reminders',
                  ),
                  _buildNavBarItem(
                    index: 2,
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFDC143C).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavBarItem(
                index: 0,
                icon: Icons.directions_car_rounded,
                label: 'Vehicles',
              ),
              _buildNavBarItem(
                index: 1,
                icon: Icons.notifications_active_rounded,
                label: 'Reminders',
              ),
              _buildNavBarItem(
                index: 2,
                icon: Icons.bar_chart_rounded,
                label: 'Statistics',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final isIOS = Platform.isIOS;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          _animationController.reset();
          _animationController.forward();
          setState(() => _selectedIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 8,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFDC143C).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFDC143C).withValues(alpha: 0.4),
                  width: 1.5,
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.15 : 1.0,
              child: Icon(
                icon,
                color: isSelected
                    ? const Color(0xFFDC143C)
                    : const Color(0xFF757575),
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 13 : 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF757575),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
