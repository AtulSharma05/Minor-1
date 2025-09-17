import '../core/app_export.dart';

class DashboardNotifier extends ChangeNotifier {
  bool isLoading = false;
  List<FlSpot> workoutData = [];
  
  // Workout-specific data properties
  List<FlSpot> weightLiftingData = [];
  List<FlSpot> cardioData = [];
  List<FlSpot> durationData = [];
  
  Map<String, dynamic>? todayProgress;
  Map<String, dynamic>? weeklyStats;

  Future<void> fetchWorkoutData(
      String workoutType, String startDate, String endDate) async {
    isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Parse date strings
      final start = DateTime.tryParse(startDate) ?? DateTime.now().subtract(const Duration(days: 7));
      final end = DateTime.tryParse(endDate) ?? DateTime.now();
      
      // Fetch workout statistics
      final stats = await DataService.getWorkoutStats(start, end);
      final progress = await DataService.getTodayProgress();
      
      // Update state
      todayProgress = progress;
      weeklyStats = stats;
      
      // Process data for charts
      await _processWorkoutData(stats, start, end);
      
    } catch (error) {
      print('Failed to fetch workout data: $error');
      // Reset data on error
      workoutData = [];
      weightLiftingData = [];
      cardioData = [];
      durationData = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _processWorkoutData(Map<String, dynamic> stats, DateTime start, DateTime end) async {
    // Get workout history for the period
    final history = await DataService.getWorkoutHistory(limit: 100);
    
    // Filter workouts within the date range
    final filteredWorkouts = history.where((workout) {
      final workoutDate = DateTime.parse(workout['date']);
      return workoutDate.isAfter(start) && workoutDate.isBefore(end);
    }).toList();

    // Generate data points for charts
    final dayData = <String, Map<String, int>>{};
    
    // Initialize days with zero values
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      final day = start.add(Duration(days: i));
      final dayKey = '${day.year}-${day.month}-${day.day}';
      dayData[dayKey] = {
        'strength': 0,
        'cardio': 0,
        'duration': 0,
      };
    }
    
    // Populate with actual workout data
    for (final workout in filteredWorkouts) {
      final workoutDate = DateTime.parse(workout['date']);
      final dayKey = '${workoutDate.year}-${workoutDate.month}-${workoutDate.day}';
      final category = workout['category']?.toString().toLowerCase() ?? 'general';
      
      if (dayData.containsKey(dayKey)) {
        if (category.contains('strength')) {
          dayData[dayKey]!['strength'] = (dayData[dayKey]!['strength']! + 1);
        } else if (category.contains('cardio')) {
          dayData[dayKey]!['cardio'] = (dayData[dayKey]!['cardio']! + 1);
        }
        dayData[dayKey]!['duration'] = 
            (dayData[dayKey]!['duration']! + (workout['duration'] as int? ?? 0));
      }
    }
    
    // Convert to FlSpot data for charts
    final sortedKeys = dayData.keys.toList()..sort();
    
    workoutData = [];
    weightLiftingData = [];
    cardioData = [];
    durationData = [];
    
    for (int i = 0; i < sortedKeys.length; i++) {
      final dayKey = sortedKeys[i];
      final data = dayData[dayKey]!;
      
      workoutData.add(FlSpot(i.toDouble(), (data['strength']! + data['cardio']!).toDouble()));
      weightLiftingData.add(FlSpot(i.toDouble(), data['strength']!.toDouble()));
      cardioData.add(FlSpot(i.toDouble(), data['cardio']!.toDouble()));
      durationData.add(FlSpot(i.toDouble(), (data['duration']! / 60).toDouble())); // Convert to hours
    }
  }
}
