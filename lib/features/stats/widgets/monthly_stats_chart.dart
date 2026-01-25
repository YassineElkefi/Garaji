import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyStatsChart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const MonthlyStatsChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.values.every((v) => v == 0)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No data available for this year'),
        ),
      );
    }

    final maxY = monthlyData.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: monthlyData.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final monthEntry = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: monthEntry.value,
                  color: Colors.blue,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
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
                  if (index >= 0 && index < monthlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthlyData.keys.elementAt(index),
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 5,
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
