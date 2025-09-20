import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smartlocker/utils/app_colors.dart';

class PlaceholderSalesChart extends StatelessWidget {
  const PlaceholderSalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: bottomTitleWidgets,
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarData(0, 12),
          _makeBarData(1, 15),
          _makeBarData(2, 8),
          _makeBarData(3, 18),
          _makeBarData(4, 13),
          _makeBarData(5, 19),
          _makeBarData(6, 16),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: AppColors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mn', style: style);
        break;
      case 1:
        text = const Text('Tu', style: style);
        break;
      case 2:
        text = const Text('Wd', style: style);
        break;
      case 3:
        text = const Text('Th', style: style);
        break;
      case 4:
        text = const Text('Fr', style: style);
        break;
      case 5:
        text = const Text('Sa', style: style);
        break;
      case 6:
        text = const Text('Su', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 22,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }
}