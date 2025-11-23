import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class RevenueLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyRevenue;
  final bool dark;

  const RevenueLineChart({
    super.key,
    required this.dailyRevenue,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: dark ? TColors.darkContainer : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution des Revenus (7 derniers jours)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Aucune donnée disponible'),
              ),
            ),
          ],
        ),
      );
    }

    final maxRevenue = dailyRevenue
        .map((e) => (e['revenue'] as num?)?.toDouble() ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution des Revenus (7 derniers jours)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: maxRevenue > 0 ? maxRevenue / 5 : 200,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < dailyRevenue.length) {
                          final date = dailyRevenue[value.toInt()]['date'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              date.substring(5), // Affiche MM-DD
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxRevenue > 0 ? maxRevenue / 5 : 200,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()} DT',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                minX: 0,
                maxX: (dailyRevenue.length - 1).toDouble(),
                minY: 0,
                maxY: maxRevenue > 0 ? maxRevenue * 1.2 : 1000,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailyRevenue.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['revenue'] as num?)?.toDouble() ?? 0.0,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue.shade400,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.shade400.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


