import 'package:nutrition_app/pages/home.dart';

import '../core/app_export.dart';

class CurrentPage extends StatefulWidget {
  const CurrentPage({Key? key}) : super(key: key);

  @override
  CurrentPageState createState() => CurrentPageState();
}

class CurrentPageState extends State<CurrentPage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    // Placeholder pages, replace with actual pages
    const LineChartSample6(),
    const HomePage(),
    const TrackersPage(), // TrackersPage
    const FeaturesPage(),
    const ProfilePage(),
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex, // Pass the current index
        onTap: _onNavBarTap, // Handle tab changes
      ),
    );
  }
}
