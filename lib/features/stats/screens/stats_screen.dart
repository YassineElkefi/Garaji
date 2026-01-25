import 'package:flutter/material.dart';
import 'package:garaji/data/models/vehicle.dart';
import 'package:garaji/features/stats/services/stats_service.dart';
import 'package:garaji/features/stats/widgets/monthly_stats_chart.dart';
import 'package:garaji/features/stats/widgets/stats_summary_card.dart';
import 'package:garaji/features/stats/widgets/yearly_stats_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int? _selectedVehicleKey;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistics'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.calendar_today), text: 'Yearly'),
              Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Vehicle Filter
            _buildVehicleFilter(),

            // Stats Summary Cards
            _buildSummaryCards(),

            // Tab View with Charts
            Expanded(
              child: TabBarView(
                children: [_buildYearlyTab(), _buildMonthlyTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleFilter() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Vehicle>('vehicles').listenable(),
      builder: (context, Box<Vehicle> box, _) {
        final vehicles = box.values.toList();

        return Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<int?>(
            initialValue: _selectedVehicleKey,
            decoration: const InputDecoration(
              labelText: 'Filter by Vehicle',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Vehicles')),
              ...vehicles.map((vehicle) {
                return DropdownMenuItem(
                  value: vehicle.key as int,
                  child: Text('${vehicle.brand} ${vehicle.model}'),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedVehicleKey = value);
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    final totalCost = StatsService.getTotalCost(_selectedVehicleKey);
    final avgCost = StatsService.getAverageCost(_selectedVehicleKey);
    final entryCount = StatsService.getEntryCount(_selectedVehicleKey);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatsSummaryCard(
              title: 'Total Cost',
              value: '${totalCost.toStringAsFixed(2)} DT',
              icon: Icons.payments,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsSummaryCard(
              title: 'Average',
              value: '${avgCost.toStringAsFixed(2)} DT',
              icon: Icons.calculate,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsSummaryCard(
              title: 'Entries',
              value: entryCount.toString(),
              icon: Icons.format_list_numbered,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTab() {
    final yearlyData = StatsService.getYearlyStats(_selectedVehicleKey);
    final categoryData = StatsService.getCategoryStats(_selectedVehicleKey);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Yearly Trends',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: YearlyStatsChart(yearlyData: yearlyData),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By Category',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...categoryData.entries.map((entry) {
                  final percentage =
                      (entry.value /
                      categoryData.values.reduce((a, b) => a + b) *
                      100);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(
                              '${entry.value.toStringAsFixed(2)} DT (${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTab() {
    final yearlyData = StatsService.getYearlyStats(_selectedVehicleKey);
    final years = yearlyData.keys.toList();

    return Column(
      children: [
        // Year Selector
        if (years.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<int>(
              initialValue: years.contains(_selectedYear)
                  ? _selectedYear
                  : years.last,
              decoration: const InputDecoration(
                labelText: 'Select Year',
                border: OutlineInputBorder(),
              ),
              items: years.map((year) {
                return DropdownMenuItem(
                  value: year,
                  child: Text(year.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedYear = value);
                }
              },
            ),
          ),

        // Monthly Chart
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Breakdown - $_selectedYear',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: MonthlyStatsChart(
                      monthlyData: StatsService.getMonthlyStats(
                        _selectedYear,
                        _selectedVehicleKey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
