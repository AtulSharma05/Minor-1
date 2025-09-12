import '../core/app_export.dart';
import 'chatbot.dart'; // Import the chatbot page

class TrackersPage extends StatelessWidget {
  const TrackersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trackers',
      ),
      body: Stack(
        children: [
          // Scrollable list of trackers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: const [
                // Card 1: Camera Card
                ExpandingImgFoodTrackerCard(title: "Image Food"),
                // Card 2: Input Fields Card
                ExpandingFoodTrackerCard(title: "Meal"),
                // Card 3: Workout Card
                ExpandingWorkoutTrackerCard(title: "Workout"),
              ],
            ),
          ),

          // "Talk to AI" button that stays at the bottom-right
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotPage()),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Talk to AI'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
