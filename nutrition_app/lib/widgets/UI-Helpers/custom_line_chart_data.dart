import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomLineChartData {
  static LineChartBarData create({
    required List<FlSpot> spots,
    required Color color1,
    required Color color2,
    bool isCurved = true,
    double barWidth = 4,
  }) {
    return LineChartBarData(
      gradient: LinearGradient(
        colors: [
          color1,
          color2,
        ],
      ),
      spots: spots,
      isCurved: isCurved,
      isStrokeCapRound: true,
      barWidth: barWidth,
      belowBarData: BarAreaData(
        show: false,
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: Color.lerp(
              color1,
              color2,
              percent / 100,
            )!,
            strokeColor: Colors.white,
            strokeWidth: 1,
          );
        },
      ),
    );
  }
}
