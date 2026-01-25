import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyStatsChart extends StatelessWidget {
  final Map<int, double> yearlyData;

  const YearlyStatsChart({super.key, required this.yearlyData});

  @override
  Widget build(BuildContext context) {
    if (yearlyData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.trending_up,
                size: 48,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No maintenance data available',
              style: TextStyle(fontSize: 16, color: Color(0xFF616161)),
            ),
          ],
        ),
      );
    }

    final maxY = yearlyData.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFFD4AF37)],
              ),
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: const Color(0xFF1A237E),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withValues(alpha: 0.3),
                    const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
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
                  if (index >= 0 && index < yearlyData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        yearlyData.keys.elementAt(index).toString(),
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
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey.shade300, strokeWidth: 1);
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
