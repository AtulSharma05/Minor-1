import '../core/app_export.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _rewardsData = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRewardsData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRewardsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DataService.getRewardsData();
      setState(() {
        _rewardsData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading rewards data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _purchaseReward(String rewardId, int cost) async {
    final result = await DataService.purchaseReward(rewardId, cost);
    
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      _loadRewardsData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards & Achievements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.shopping_cart), text: 'Rewards'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Tokens'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsTab(),
                _buildRewardsTab(),
                _buildTokensTab(),
              ],
            ),
    );
  }

  Widget _buildAchievementsTab() {
    final achievements = _rewardsData['achievements'] as List<dynamic>? ?? [];
    
    return RefreshIndicator(
      onRefresh: _loadRewardsData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProgressCard(),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => _buildAchievementCard(achievement)),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final totalAchievements = _rewardsData['total_achievements'] ?? 0;
    final unlockedAchievements = _rewardsData['unlocked_achievements'] ?? 0;
    final progress = totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievement Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$unlockedAchievements / $totalAchievements'),
                Text('${(progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['isUnlocked'] as bool? ?? false;
    final current = achievement['current'] ?? 0;
    final requirement = achievement['requirement'] ?? 0;
    final progress = requirement > 0 ? (current / requirement).clamp(0.0, 1.0) : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  achievement['icon'] ?? '🏆',
                  style: TextStyle(
                    fontSize: 24,
                    color: isUnlocked ? null : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'] ?? 'Achievement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['description'] ?? '',
                    style: TextStyle(
                      color: isUnlocked ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  if (!isUnlocked) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$current / $requirement',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnlocked)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsTab() {
    final rewards = _rewardsData['rewards'] as List<dynamic>? ?? [];
    
    return RefreshIndicator(
      onRefresh: _loadRewardsData,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_rewardsData['current_tokens'] ?? 0} Tokens',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...rewards.map((reward) => _buildRewardCard(reward)),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final isAffordable = reward['isAffordable'] as bool? ?? false;
    final cost = reward['cost'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isAffordable
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  reward['icon'] ?? '🎁',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward['title'] ?? 'Reward',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward['description'] ?? '',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$cost tokens',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isAffordable
                  ? () => _purchaseReward(reward['id'], cost)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isAffordable
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: Text(isAffordable ? 'Purchase' : 'Locked'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokensTab() {
    return RefreshIndicator(
      onRefresh: _loadRewardsData,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 64,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Balance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_rewardsData['current_tokens'] ?? 0}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tokens',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.amber[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to Earn Tokens',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildTokenEarnRow('Complete a workout', '10 tokens', Icons.fitness_center),
                    _buildTokenEarnRow('First workout milestone', '20 tokens', Icons.star),
                    _buildTokenEarnRow('3-day streak', '25 tokens', Icons.local_fire_department),
                    _buildTokenEarnRow('7-day streak', '50 tokens', Icons.flash_on),
                    _buildTokenEarnRow('30-day streak', '200 tokens', Icons.emoji_events),
                    _buildTokenEarnRow('10 workout milestone', '50 tokens', Icons.trending_up),
                    _buildTokenEarnRow('50 workout milestone', '150 tokens', Icons.military_tech),
                    _buildTokenEarnRow('Long workout bonus (45+ min)', '5 tokens', Icons.access_time),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenEarnRow(String action, String reward, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(action),
          ),
          Text(
            reward,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }
}
