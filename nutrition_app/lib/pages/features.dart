import '../core/app_export.dart';
import '../widgets/Commons/icon_feature_card.dart';
import 'chatbot.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      'Workout Blogs',
      'Log Workout',
      'Workout History',
      'Streak & Rewards',
      'Talk to AI/\nChatbot',
      'AI Pose Detection',
    ];

    final List<Widget?> pages = [
      const WorkoutBlogsPage(), // Workout blogs
      null, // Log new workouts - will handle with navigation
      const WorkoutHistoryPage(), // View workout history
      const StreakDetailsPage(), // View streak details and achievements
      const ChatbotPage(), // Talk to AI/Chatbot
      const PoseDetectionPage(), // AI Pose Detection
    ];

    // Map of appropriate icons for each feature
    final List<IconData> featureIcons = [
      Icons.article, // Workout Blogs
      Icons.fitness_center, // Log Workout
      Icons.history, // Workout History
      Icons.emoji_events, // Streak & Rewards
      Icons.chat, // Talk to AI/Chatbot
      Icons.camera_alt, // AI Pose Detection
    ];

    final List<Color> featureColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: "Features",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: titles.length, // Adjust the number of cards as needed
          itemBuilder: (context, index) {
            return IconFeatureCard(
              icon: featureIcons[index],
              iconColor: featureColors[index],
              title: titles[index],
              onTap: () {
                if (index == 1) {
                  // Special handling for Log Workout with lock check
                  Navigator.pushNamed(
                    context,
                    '/workout_logging',
                    arguments: {
                      'workoutType': 'General Fitness',
                      'difficulty': 'Beginner',
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => pages[index]!),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
