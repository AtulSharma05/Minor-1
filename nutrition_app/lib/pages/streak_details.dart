import '../core/app_export.dart';

class StreakDetailsPage extends StatefulWidget {
  const StreakDetailsPage({Key? key}) : super(key: key);

  @override
  _StreakDetailsPageState createState() => _StreakDetailsPageState();
}

class _StreakDetailsPageState extends State<StreakDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Streak'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main streak display
            StreakWidget(showDetails: true),
            
            const SizedBox(height: 24),
            
            // Streak statistics
            _buildStreakStats(),
            
            const SizedBox(height: 24),
            
            // Achievements
            StreakAchievementsWidget(),
            
            const SizedBox(height: 24),
            
            // Tips and motivation
            _buildMotivationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DataService.getStreakDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final streakData = snapshot.data!;
        final currentStreak = streakData['current_streak'] as int;
        final longestStreak = streakData['longest_streak'] as int;
        final isActive = streakData['is_active'] as bool;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Statistics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Current Streak',
                        '$currentStreak days',
                        Icons.local_fire_department,
                        isActive ? Colors.orange : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        'Longest Streak',
                        '$longestStreak days',
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Status',
                        isActive ? 'Active 🔥' : 'Inactive 😴',
                        isActive ? Icons.check_circle : Icons.warning,
                        isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FutureBuilder<int>(
                        future: DataService.getUserTokens(),
                        builder: (context, tokenSnapshot) {
                          final tokens = tokenSnapshot.data ?? 0;
                          return _buildStatItem(
                            'Tokens Earned',
                            '$tokens 🪙',
                            Icons.monetization_on,
                            Colors.yellow.shade700,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                Text(
                  'Streak Tips',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '🎯',
              'Set Daily Goals',
              'Even a 10-minute workout counts towards your streak!',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '⏰',
              'Be Consistent',
              'Try to work out at the same time each day to build a habit.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '🎉',
              'Celebrate Milestones',
              'Reward yourself when you hit streak milestones to stay motivated.',
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '💪',
              'Listen to Your Body',
              'Light exercise on rest days can still keep your streak alive.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
