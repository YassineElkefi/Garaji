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
  @override
  Widget build(BuildContext context) {
    return const StatsScreenContent();
  }
}

class StatsScreenContent extends StatefulWidget {
  const StatsScreenContent({super.key});

  @override
  State<StatsScreenContent> createState() => _StatsScreenContentState();
}

class _StatsScreenContentState extends State<StatsScreenContent> {
  int? _selectedVehicleKey;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: const Text('Statistics'),
            pinned: true,
            floating: true,
            elevation: 0,
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            bottom: TabBar(
              indicatorColor: const Color(0xFFD4AF37),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today), text: 'Yearly'),
                Tab(icon: Icon(Icons.calendar_month), text: 'Monthly'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            _buildVehicleFilter(),
            _buildSummaryCards(),
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
          color: const Color(0xFF000000),
          child: DropdownButtonFormField<int?>(
            initialValue: _selectedVehicleKey,
            decoration: InputDecoration(
              labelText: 'Filter by Vehicle',
              prefixIcon: const Icon(
                Icons.filter_list,
                color: Color(0xFFD4AF37),
              ),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
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

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF000000),
      child: Row(
        children: [
          Expanded(
            child: StatsSummaryCard(
              title: 'Total Cost',
              value: '${totalCost.toStringAsFixed(2)} DT',
              icon: Icons.payments,
              color: const Color(0xFFDC143C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsSummaryCard(
              title: 'Average',
              value: '${avgCost.toStringAsFixed(2)} DT',
              icon: Icons.calculate,
              color: const Color(0xFF00897B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatsSummaryCard(
              title: 'Entries',
              value: entryCount.toString(),
              icon: Icons.format_list_numbered,
              color: const Color(0xFFD4AF37),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyTab() {
    final yearlyData = StatsService.getYearlyStats(_selectedVehicleKey);
    final categoryData = StatsService.getCategoryStats(_selectedVehicleKey);

    return Container(
      color: const Color(0xFF000000),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            color: const Color(0xFF1E1E1E),
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC143C).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Color(0xFFDC143C),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Yearly Trends',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
            elevation: 2,
            color: const Color(0xFF1E1E1E),
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.pie_chart,
                          color: Color(0xFFD4AF37),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'By Category',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFFFFF),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (categoryData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No category data available'),
                      ),
                    )
                  else
                    ...categoryData.entries.map((entry) {
                      final percentage =
                          (entry.value /
                          categoryData.values.reduce((a, b) => a + b) *
                          100);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(entry.key),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${entry.value.toStringAsFixed(2)} DT (${percentage.toStringAsFixed(1)}%)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDC143C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: const Color(0xFF2C2C2C),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getCategoryColor(entry.key),
                                ),
                                minHeight: 8,
                              ),
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
      ),
    );
  }

  Widget _buildMonthlyTab() {
    final yearlyData = StatsService.getYearlyStats(_selectedVehicleKey);
    final years = yearlyData.keys.toList();

    return Container(
      color: const Color(0xFF000000),
      child: Column(
        children: [
          if (years.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<int>(
                initialValue: years.contains(_selectedYear)
                    ? _selectedYear
                    : years.last,
                decoration: InputDecoration(
                  labelText: 'Select Year',
                  prefixIcon: const Icon(
                    Icons.date_range,
                    color: Color(0xFFD4AF37),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
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
          Expanded(
            child: Card(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              elevation: 2,
              color: const Color(0xFF1E1E1E),
              shadowColor: Colors.black.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFDC143C,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: Color(0xFFDC143C),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Monthly Breakdown - $_selectedYear',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFFFFF),
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Maintenance':
        return const Color(0xFFDC143C);
      case 'Repair':
        return const Color(0xFFC62828);
      case 'Inspection':
        return const Color(0xFF00897B);
      case 'Wash':
        return const Color(0xFFD4AF37);
      default:
        return Colors.grey;
    }
  }
}
