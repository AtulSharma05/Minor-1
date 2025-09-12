import '../core/app_export.dart';

class DashboardNotifier extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  bool isLoading = false;
  List<FlSpot> proteinData = [];
  List<FlSpot> carbohydrateData = [];
  List<FlSpot> fatData = [];

  Future<void> fetchCaloriesConsumed(
      String mealType, String startDate, String endDate) async {
    isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      List<dynamic> data = await _foodRepository.fetchCaloriesForDashboard(
          mealType, startDate, endDate);
      _processData(data);
    } catch (error) {
      throw Exception('Failed to fetch data: $error');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _processData(List<dynamic> data) {
    proteinData = [];
    carbohydrateData = [];
    fatData = [];

    Map<String, double> proteinMap = {};
    Map<String, double> carbMap = {};
    Map<String, double> fatMap = {};
    for (var entry in data) {
      final date = entry['current_date'];
      proteinMap[date] = (proteinMap[date] ?? 0) + entry['proteins_100g'];
      carbMap[date] = (carbMap[date] ?? 0) + entry['carbohydrates_100g'];
      fatMap[date] = (fatMap[date] ?? 0) + entry['fat_100g'];
    }

    var sortedDates = proteinMap.keys.toList()
      ..sort((a, b) => DateFormat('dd-MM-yyyy')
          .parse(a)
          .compareTo(DateFormat('dd-MM-yyyy').parse(b)));

    for (var date in sortedDates) {
      final day = DateFormat('dd-MM-yyyy').parse(date).day.toDouble();
      proteinData.add(FlSpot(day, proteinMap[date]!));
      carbohydrateData.add(FlSpot(day, carbMap[date]!));
      fatData.add(FlSpot(day, fatMap[date]!));
    }

  print("hellow");
  print(sortedDates); // This should now show sorted dates
}
}
