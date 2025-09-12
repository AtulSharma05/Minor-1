import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import the intl package
import '../core/app_colors.dart'; // Correct import for app colors
import '../widgets/UI-Helpers/custom_line_chart_data.dart'; // Import the custom line chart data
import '../notifiers/dashboard_notifier.dart'; // Import the DashboardNotifier

class LineChartSample6 extends StatefulWidget {
  const LineChartSample6({Key? key}) : super(key: key);

  @override
  _LineChartSample6State createState() => _LineChartSample6State();
}

class _LineChartSample6State extends State<LineChartSample6> {
  final Color line1Color1 = AppColors.contentColorOrange;
  final Color line1Color2 = AppColors.contentColorOrange;
  final Color line2Color1 = AppColors.contentColorGreen;
  final Color line2Color2 = AppColors.contentColorGreen;
  final Color line3Color1 = AppColors.contentColorRed;
  final Color line3Color2 = AppColors.contentColorRed;

  late double minSpotX;
  late double maxSpotX;
  late double minSpotY;
  late double maxSpotY;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _initializeSpots(List<FlSpot> spotsData) {
    if (spotsData.isEmpty) {
      // Set default values if the list is empty
      minSpotX = 0;
      maxSpotX = 0;
      minSpotY = 0;
      maxSpotY = 0;
      return;
    }

    minSpotX = spotsData.first.x;
    maxSpotX = spotsData.first.x;
    minSpotY = spotsData.first.y;
    maxSpotY = spotsData.first.y;

    // Loop through the spots data to find min and max for x and y
    for (final spot in spotsData) {
      if (spot.x > maxSpotX) {
        maxSpotX = spot.x;
      }

      if (spot.x < minSpotX) {
        minSpotX = spot.x;
      }

      if (spot.y > maxSpotY) {
        maxSpotY = spot.y;
      }

      if (spot.y < minSpotY) {
        minSpotY = spot.y;
      }
    }

    // Adjust max and min values for better readability
    maxSpotY =
        (maxSpotY / 10).ceil() * 10; // Round up to nearest multiple of 10
    minSpotY =
        (minSpotY / 10).floor() * 10; // Round down to nearest multiple of 10
  }

  void _fetchData() async {
    final notifier = Provider.of<DashboardNotifier>(context, listen: false);
    final now = DateTime.now();
    final startDate =
        DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 7)));
    final endDate = DateFormat('dd-MM-yyyy').format(now);

    await notifier.fetchCaloriesConsumed('all', startDate, endDate);
    print('Protein Data: ${notifier.proteinData}');
    print('Carbohydrate Data: ${notifier.carbohydrateData}');
    print('Fat Data: ${notifier.fatData}');
    final allSpots = [
      ...notifier.proteinData,
      ...notifier.carbohydrateData,
      ...notifier.fatData
    ];

    // Call the function to initialize min and max values based on all spots
    _initializeSpots(allSpots);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: line1Color1,
      fontWeight: FontWeight.bold,
      fontSize: 18,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Text(
        value.toString(),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    if (value % 1 != 0) {
      return Container();
    }
    return Text(
      value.toInt().toString(),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.contentColorGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Dynamically calculate the Y-axis step size (e.g., 4-5 ticks)
        double stepSize = (maxSpotY - minSpotY) / 4; // Show 4 labels
        if (stepSize == 0) {
          stepSize = 1; // Ensure stepSize is not zero to avoid assertion error
        }

        return Padding(
          padding: const EdgeInsets.only(right: 22, top: 200),
          child: AspectRatio(
            aspectRatio: 1,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 0,
                    getTooltipColor: (spot) => Colors.white,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          touchedSpot.y.toString(),
                          TextStyle(
                            color: touchedSpot.bar.gradient!.colors.first,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator: (
                    _,
                    indicators,
                  ) {
                    return indicators
                        .map((int index) => const TouchedSpotIndicatorData(
                              FlLine(color: Colors.transparent),
                              FlDotData(show: false),
                            ))
                        .toList();
                  },
                  touchSpotThreshold: 12,
                  distanceCalculator:
                      (Offset touchPoint, Offset spotPixelCoordinates) =>
                          (touchPoint - spotPixelCoordinates).distance,
                ),
                lineBarsData: [
                  CustomLineChartData.create(
                    spots: notifier.proteinData,
                    color1: line1Color1,
                    color2: line1Color2,
                  ),
                  CustomLineChartData.create(
                    spots: notifier.carbohydrateData,
                    color1: line2Color1,
                    color2: line2Color2,
                  ),
                  CustomLineChartData.create(
                    spots: notifier.fatData,
                    color1: line3Color1,
                    color2: line3Color2,
                  ),
                ],
                minY: minSpotY,
                maxY: maxSpotY,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: leftTitleWidgets,
                      reservedSize: 50,
                      interval:
                          stepSize, // Adjust intervals to create 4-5 labels
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: true,
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: AppColors.borderColor),
                    top: BorderSide(color: Colors.transparent),
                    bottom: BorderSide(color: AppColors.borderColor),
                    right: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
