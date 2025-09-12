import '../core/app_export.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  FlSpot? touchedSpot;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    try {
      final notifier = Provider.of<DashboardNotifier>(context, listen: false);
      final now = DateTime.now();
      final startDate = DateFormat('dd-MM-yyyy').format(now.subtract(const Duration(days: 7)));
      final endDate = DateFormat('dd-MM-yyyy').format(now);

      await notifier.fetchCaloriesConsumed('all', startDate, endDate);
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<DashboardNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: notifier.proteinData,
                          isCurved: true,
                          color: Colors.redAccent,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: notifier.carbohydrateData,
                          isCurved: true,
                          color: Colors.greenAccent,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: notifier.fatData,
                          isCurved: true,
                          color: Colors.blueAccent,
                          barWidth: 4,
                          belowBarData: BarAreaData(show: false),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 3,
                            getTitlesWidget: (value, meta) {
                              final day = value.toInt();
                              if (day % 3 == 0) {
                                return Text(
                                  DateFormat('dd-MM').format(DateTime.now().subtract(Duration(days: 7 - day))),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text('${value.toInt()}');
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) {
                          return const FlLine(
                            color: Colors.grey,
                            strokeWidth: 0.5,
                          );
                        },
                      ),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          // tooltipBgColor: Colors.white.withOpacity(0.8),
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((touchedSpot) {
                              final textStyle = TextStyle(
                                color: touchedSpot.bar.color,
                                fontWeight: FontWeight.bold,
                              );
                              return LineTooltipItem(
                                '${touchedSpot.y}g',
                                textStyle,
                              );
                            }).toList();
                          },
                        ),
                        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                          if (!event.isInterestedForInteractions || response == null || response.lineBarSpots == null) {
                            setState(() {
                              touchedSpot = null;
                            });
                            return;
                          }
                          setState(() {
                            touchedSpot = response.lineBarSpots!.first;
                          });
                        },
                        handleBuiltInTouches: true,
                      ),
                    ),
                  ),
                ),
              ),
              if (touchedSpot != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Protein: ${touchedSpot!.y}g',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      Text(
                        'Carbohydrates: ${touchedSpot!.y}g',
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                      Text(
                        'Fat: ${touchedSpot!.y}g',
                        style: const TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(Colors.redAccent, 'Protein'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.greenAccent, 'Carbohydrates'),
                    const SizedBox(width: 16),
                    _buildLegendItem(Colors.blueAccent, 'Fat'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

