import '../core/app_export.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Column(
        children: [
          // Other profile items can go here
          Expanded(child: Container()), // Placeholder for other content

          // Logout button
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CustomLogoutButton(),
            ),
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
