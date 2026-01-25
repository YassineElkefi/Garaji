import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyStatsChart extends StatelessWidget {
  final Map<int, double> yearlyData;

  const YearlyStatsChart({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No maintenance data available'),
        ),
      );
    }

    final maxY = yearlyData.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          maxY: maxY * 1.2,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: yearlyData.entries.map((entry) {
                final index = yearlyData.keys.toList().indexOf(entry.key);
                return FlSpot(index.toDouble(), entry.value);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < yearlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        yearlyData.keys.elementAt(index).toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
