import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyStatsChart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const MonthlyStatsChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.values.every((v) => v == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDC143C).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart,
                size: 48,
                color: Color(0xFFDC143C),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No data available for this year',
              style: TextStyle(fontSize: 16, color: Color(0xFF616161)),
            ),
          ],
        ),
      );
    }

    final maxY = monthlyData.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC143C), Color(0xFFD4AF37)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w500,
                    ),
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
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w500,
                        ),
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
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.white.withValues(alpha: 0.1), strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
