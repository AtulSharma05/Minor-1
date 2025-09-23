import '../core/app_export.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Initial selected index (set to Workouts)
  int selectedIndex = 1;

  // Progress bar value for workout goals
  double workoutProgressValue = 0.65;

  // Current workout metric index
  int workoutMetricIndex = 0;
  
  // User progress data
  int totalWorkouts = 0;
  int currentStreak = 0;
  bool isLoadingProgress = true;
  
  // Demo mode for showcase (set to true to unlock all workouts)
  static const bool isDemoMode = false; // Set to false to see lock functionality

  final List<Map<String, dynamic>> carouselItems = [
    {
      'image': 'assets/icons/weight_lifting.png',
      'title': 'Beginner Cardio',
      'subtitle': 'Start your fitness journey',
      'isLocked': false, // Always unlocked for beginners
      'lockReason': '',
      'difficulty': 'Beginner',
      'requiredWorkouts': 0,
    },
    {
      'image': 'assets/icons/cardio.png', 
      'title': 'Strength Training',
      'subtitle': 'Build muscle and strength',
      'isLocked': true,
      'lockReason': 'Complete 3 workouts to unlock',
      'difficulty': 'Intermediate',
      'requiredWorkouts': 3,
    },
    {
      'image': 'assets/icons/flexibility.png',
      'title': 'Advanced HIIT',
      'subtitle': 'High-intensity interval training',
      'isLocked': true,
      'lockReason': 'Complete 10 workouts to unlock',
      'difficulty': 'Advanced',
      'requiredWorkouts': 10,
    },
    {
      'image': 'assets/icons/flexibility.png',
      'title': 'Elite Training',
      'subtitle': 'Professional-level workouts',
      'isLocked': true,
      'lockReason': 'Maintain a 7-day streak to unlock',
      'difficulty': 'Elite',
      'requiredWorkouts': 20,
      'requiredStreak': 7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorkoutData();
  }

  void _fetchWorkoutData() async {
    try {
      print('Fetching workout data...');
      
      // Get user workout statistics
      final streakDetails = await DataService.getStreakDetails();
      final workoutHistory = await DataService.getWorkoutHistory(limit: 100);
      
      setState(() {
        totalWorkouts = workoutHistory.length;
        currentStreak = streakDetails['current_streak'] ?? 0;
        isLoadingProgress = false;
        
        // Update progress based on daily goal (example: 1 workout per day)
        workoutProgressValue = totalWorkouts > 0 ? 
          (totalWorkouts % 7) / 7.0 : 0.0; // Weekly progress
      });
      
      print('Progress loaded: $totalWorkouts workouts, $currentStreak streak');
    } catch (error) {
      print('Error fetching workout data: $error');
      setState(() {
        isLoadingProgress = false;
      });
    }
  }

  // Check if a workout is unlocked based on user progress
  bool _isWorkoutUnlocked(Map<String, dynamic> workout) {
    // Demo mode for showcase - unlock all workouts
    if (isDemoMode) return true;
    
    if (!workout['isLocked']) return true;
    
    final requiredWorkouts = workout['requiredWorkouts'] ?? 0;
    final requiredStreak = workout['requiredStreak'] ?? 0;
    
    if (requiredWorkouts > 0 && totalWorkouts < requiredWorkouts) {
      return false;
    }
    
    if (requiredStreak > 0 && currentStreak < requiredStreak) {
      return false;
    }
    
    return true;
  }

  // Get lock reason for UI display
  String _getLockReason(Map<String, dynamic> workout) {
    if (_isWorkoutUnlocked(workout)) return '';
    
    final requiredWorkouts = workout['requiredWorkouts'] ?? 0;
    final requiredStreak = workout['requiredStreak'] ?? 0;
    
    if (requiredWorkouts > 0 && totalWorkouts < requiredWorkouts) {
      final remaining = requiredWorkouts - totalWorkouts;
      return 'Complete $remaining more workout${remaining != 1 ? 's' : ''} to unlock';
    }
    
    if (requiredStreak > 0 && currentStreak < requiredStreak) {
      final remaining = requiredStreak - currentStreak;
      return 'Maintain $remaining more day${remaining != 1 ? 's' : ''} streak to unlock';
    }
    
    return workout['lockReason'] ?? 'Locked';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildWorkoutProgress(),
              const SizedBox(height: 20),
              StreakWidget(
                showDetails: false,
                onTap: () => Navigator.pushNamed(context, '/streak-details'),
              ),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildWorkoutCarousel(),
              const SizedBox(height: 20),
              _buildRecentWorkouts(),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'Ready for your workout?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (!isLoadingProgress)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalWorkouts workouts',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (isLoadingProgress)
              const LinearProgressIndicator()
            else ...[
              LinearProgressIndicator(
                value: workoutProgressValue,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(workoutProgressValue * 100).toInt()}% weekly goal',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Streak: $currentStreak 🔥',
                    style: TextStyle(
                      color: currentStreak > 0 
                        ? Colors.orange 
                        : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (_getNextUnlockInfo().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getNextUnlockInfo(),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _getNextUnlockInfo() {
    // Find the next workout to unlock
    for (final workout in carouselItems) {
      if (!_isWorkoutUnlocked(workout)) {
        final requiredWorkouts = workout['requiredWorkouts'] ?? 0;
        final requiredStreak = workout['requiredStreak'] ?? 0;
        
        if (requiredWorkouts > totalWorkouts) {
          final remaining = requiredWorkouts - totalWorkouts;
          return '$remaining more workout${remaining != 1 ? 's' : ''} to unlock ${workout['title']}';
        }
        
        if (requiredStreak > currentStreak) {
          final remaining = requiredStreak - currentStreak;
          return '$remaining more day${remaining != 1 ? 's' : ''} streak to unlock ${workout['title']}';
        }
      }
    }
    return '';
  }

  // Helper method to navigate to workout logging with lock check
  Future<void> _navigateToWorkoutLogging({
    String workoutType = 'General',
    String difficulty = 'Beginner',
  }) async {
    // Check if workout is unlocked
    final unlockStatus = await DataService.getWorkoutUnlockStatus();
    bool isUnlocked = false;
    
    switch (difficulty) {
      case 'Beginner':
        isUnlocked = true;
        break;
      case 'Intermediate':
        isUnlocked = unlockStatus['totalWorkouts'] >= 3;
        break;
      case 'Advanced':
        isUnlocked = unlockStatus['totalWorkouts'] >= 10 && unlockStatus['currentStreak'] >= 3;
        break;
      case 'Elite':
        isUnlocked = unlockStatus['totalWorkouts'] >= 20 && unlockStatus['currentStreak'] >= 7;
        break;
      default:
        isUnlocked = true;
    }
    
    if (isUnlocked) {
      final result = await Navigator.pushNamed(
        context, 
        '/workout_logging',
        arguments: {
          'workoutType': workoutType,
          'difficulty': difficulty,
        },
      );
      // Refresh progress when returning from workout logging
      if (result == true) {
        _fetchWorkoutData();
      }
    } else {
      String lockMessage = 'This $difficulty workout is locked. ';
      switch (difficulty) {
        case 'Intermediate':
          lockMessage += 'Complete 3 total workouts to unlock.';
          break;
        case 'Advanced':
          lockMessage += 'Complete 10 total workouts and maintain a 3-day streak to unlock.';
          break;
        case 'Elite':
          lockMessage += 'Complete 20 total workouts and maintain a 7-day streak to unlock.';
          break;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lockMessage),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.fitness_center,
          label: 'Start Workout',
          onTap: () {
            // Navigate to basic beginner workout
            _navigateToWorkoutLogging(
              workoutType: 'General Fitness',
              difficulty: 'Beginner',
            );
          },
        ),
        _buildActionButton(
          icon: Icons.emoji_events,
          label: 'Rewards',
          onTap: () {
            Navigator.pushNamed(context, '/rewards');
          },
        ),
        _buildActionButton(
          icon: Icons.analytics,
          label: 'Progress',
          onTap: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workout Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isLoadingProgress)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: carouselItems.length,
            itemBuilder: (context, index) {
              final item = carouselItems[index];
              final isUnlocked = _isWorkoutUnlocked(item);
              final lockReason = _getLockReason(item);
              
              return GestureDetector(
                onTap: () {
                  if (isUnlocked) {
                    // Navigate to workout logging with the selected type
                    Navigator.pushNamed(
                      context, 
                      '/workout_logging',
                      arguments: {
                        'workoutType': item['title'],
                        'difficulty': item['difficulty'],
                      },
                    );
                  } else {
                    // Show lock reason
                    _showLockDialog(item['title'], lockReason);
                  }
                },
                child: Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    gradient: isUnlocked 
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.grey[400]!,
                            Colors.grey[600]!,
                          ],
                        ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  isUnlocked ? Icons.fitness_center : Icons.lock,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                if (!isUnlocked)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6, 
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'LOCKED',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isUnlocked ? item['subtitle'] : lockReason,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white70 : Colors.white60,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['difficulty'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isUnlocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showLockDialog(String workoutTitle, String lockReason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Workout Locked'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workoutTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(lockReason),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Keep working out to unlock new challenges!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToWorkoutLogging(
                  workoutType: 'General Fitness',
                  difficulty: 'Beginner',
                );
              },
              child: const Text('Start Basic Workout'),
            ),
          ],
        );
      },
    );
  }

  // Show achievement notification when workouts are unlocked
  void _showUnlockNotification(String workoutTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.star, color: Colors.yellow),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🎉 Congratulations! $workoutTitle unlocked!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Try Now',
          textColor: Colors.white,
          onPressed: () {
            _navigateToWorkoutLogging(
              workoutType: workoutTitle,
              difficulty: 'Beginner', // Default to beginner for unlocked workouts
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Workouts',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: DataService.getWorkoutHistory(limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final workouts = snapshot.data ?? [];
            
            if (workouts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No recent workouts',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Start your first workout to see it here!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: workouts.map((workout) {
                    final date = DateTime.parse(workout['date']);
                    final isToday = date.day == DateTime.now().day &&
                        date.month == DateTime.now().month &&
                        date.year == DateTime.now().year;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout['name'] ?? 'Workout',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isToday 
                                    ? 'Today • ${workout['duration']} min'
                                    : '${date.day}/${date.month} • ${workout['duration']} min',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${workout['calories']} cal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
