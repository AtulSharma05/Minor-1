import '../core/app_export.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      'Nutrition Blogs',
      'Nutrion Dietplan',
      'Feature 3',
      'Feature 4',
    ];

    final List<Widget> pages = [
      NutritionBlogsPage(),
      DietPlanPage(),
      const Placeholder(),
      const Placeholder(),
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
            return FeatureCard(
              imageUrl:
                  'assets/features/feature${index + 1}.png', // Example image path
              title: titles[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pages[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
