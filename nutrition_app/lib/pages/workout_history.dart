import '../core/app_export.dart';

class WorkoutHistoryPage extends StatefulWidget {
  const WorkoutHistoryPage({Key? key}) : super(key: key);

  @override
  _WorkoutHistoryPageState createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;
  Map<String, dynamic>? _todayProgress;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load workout history and today's progress
      final history = await DataService.getWorkoutHistory(limit: 50);
      final progress = await DataService.getTodayProgress();
      
      setState(() {
        _workoutHistory = history;
        _todayProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToLogWorkout() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WorkoutLoggingPage()),
    );
    
    if (result == true) {
      // Reload data if workout was successfully logged
      _loadWorkoutData();
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength training':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'flexibility':
        return Colors.green;
      case 'sports':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadWorkoutData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Today's Progress Card
                if (_todayProgress != null) _buildTodayProgressCard(),
                
                // Workout History List
                Expanded(
                  child: _workoutHistory.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadWorkoutData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: _workoutHistory.length,
                            itemBuilder: (context, index) {
                              return _buildWorkoutCard(_workoutHistory[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToLogWorkout,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTodayProgressCard() {
    final progress = _todayProgress!;
    final workoutProgress = progress['workout_progress'] ?? 0;
    final durationProgress = progress['duration_progress'] ?? 0;
    
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Progress",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workouts: ${progress['workouts_completed']}/${progress['workout_goal']}'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: workoutProgress / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          workoutProgress >= 100 ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration: ${progress['duration_completed']}/${progress['duration_goal']} min'),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: durationProgress / 100.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          durationProgress >= 100 ? Colors.green : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress['calories_burned'] > 0) ...[
              const SizedBox(height: 12),
              Text('Calories burned today: ${progress['calories_burned']} kcal'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts logged yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your fitness journey by logging your first workout!',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToLogWorkout,
            icon: const Icon(Icons.add),
            label: const Text('Log Your First Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Map<String, dynamic> workout) {
    final date = DateTime.parse(workout['date']);
    final exercises = workout['exercises'] as List<dynamic>? ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    workout['name'] ?? 'Unnamed Workout',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(workout['category'] ?? 'general'),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    workout['category'] ?? 'General',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            if (workout['description']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(workout['description']),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                  icon: Icons.timer,
                  label: _formatDuration(workout['duration'] ?? 0),
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  icon: Icons.local_fire_department,
                  label: '${workout['calories'] ?? 0} kcal',
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatChip(
                  icon: Icons.fitness_center,
                  label: '${exercises.length} exercises',
                  color: Colors.green,
                ),
              ],
            ),
            if (exercises.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Exercises:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...exercises.take(3).map((exercise) => Text(
                '• ${exercise['name']} - ${exercise['sets']}x${exercise['reps']}' +
                (exercise['weight'] > 0 ? ' @ ${exercise['weight']}kg' : ''),
                style: TextStyle(color: Colors.grey[600]),
              )),
              if (exercises.length > 3)
                Text(
                  '  ... and ${exercises.length - 3} more',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
            if (workout['notes']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Notes: ${workout['notes']}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
