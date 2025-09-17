import '../core/app_export.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // User profile section
            _buildUserProfileSection(context),
            
            const SizedBox(height: 16),
            
            // Streak widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreakWidget(
                showDetails: true,
                onTap: () => Navigator.pushNamed(context, '/streak-details'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick stats
            _buildQuickStats(),
            
            const SizedBox(height: 16),
            
            // Profile actions
            _buildProfileActions(context),
            
            const SizedBox(height: 24),

            // Logout button
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CustomLogoutButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: DataService.getUserProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final username = user?['username'] ?? 'User';
        final email = user?['email'] ?? 'user@example.com';
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                username,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: DataService.getWorkoutHistory(limit: 100),
        builder: (context, snapshot) {
          final workouts = snapshot.data ?? [];
          final totalWorkouts = workouts.length;
          final totalDuration = workouts.fold(0, (sum, w) => sum + (w['duration'] as int? ?? 0));
          final totalCalories = workouts.fold(0, (sum, w) => sum + (w['calories'] as int? ?? 0));
          
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Workouts',
                  '$totalWorkouts',
                  Icons.fitness_center,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Duration',
                  '${(totalDuration / 60).toStringAsFixed(1)}h',
                  Icons.timer,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Calories Burned',
                  '$totalCalories',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.history, color: Theme.of(context).colorScheme.primary),
            title: const Text('Workout History'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/workout-history'),
          ),
          ListTile(
            leading: Icon(Icons.local_fire_department, color: Colors.orange),
            title: const Text('Streak Details'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/streak-details'),
          ),
          ListTile(
            leading: Icon(Icons.add_circle, color: Colors.green),
            title: const Text('Log New Workout'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.pushNamed(context, '/workout-logging'),
          ),
        ],
      ),
    );
  }
}

class CustomLogoutButton extends StatelessWidget {
  const CustomLogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Make button full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          // color: Colors.red, // Button color
          // : Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
        ),
        onPressed: () {
          _handleLogout(context); // Handle logout
        },
        child: const Text("Logout"),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // Call the logout function in AuthNotifier (you need to implement this)
    await authNotifier
        .logout(); // Ensure you have a logout method in AuthNotifier

    // Navigate to the SigninPage or show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
      ),
    );

    // Navigate to the login page
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              const WelcomeScreen()), // Replace with your login page
    );
  }
}
