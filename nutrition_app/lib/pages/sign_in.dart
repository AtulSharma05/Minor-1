import '../core/app_export.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers when no longer needed to avoid memory leaks
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // Get values from your text fields
    String username = usernameController.text;
    String password = passwordController.text;

    // Call the login function and wait for it to complete
    await authNotifier.login(username, password);

    // Check if login was successful
    if (authNotifier.successMessage != null) {
      // Navigate to the Home screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const CurrentPage()),
        (route) => false,
      );
    } else {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(authNotifier.errorMessage ?? 'An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Top background shape
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/auths/upper-rec.png', // Your upper shape
              width: width,
              fit: BoxFit.fill,
            ),
          ),
          // Bottom background shape
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset(
              'assets/auths/lower-rec.png', // Your lower shape
              width: width,
              fit: BoxFit.fill,
            ),
          ),

          // Back button (top left corner)
          Positioned(
            top: height * 0.1, // Adjust as needed
            left: width * 0.05,
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onPrimary),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          // Welcome text and login heading
          Positioned(
            top: height * 0.23, // Adjust the vertical position as needed
            left: width * 0.1,
            right: width *
                0.1, // Center-align the text by keeping equal space on both sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Input fields and other form elements
          Positioned(
            top: height * 0.4,
            left: width * 0.1,
            right: width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextField(
                  hintText: "Your email or username",
                  fieldType: "email",
                  controller: usernameController,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hintText: "Your password",
                  fieldType: "password",
                  controller: passwordController,
                ),

                // Row with checkbox and forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        CustomCheckbox(
                          initialValue: false, // Set initial value as needed
                          onChanged: (bool isChecked) {
                            // Handle checkbox state change
                          },
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle Forgot Password
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Sign in button
                Center(
                  child: CustomButton(
                    text: 'Sign in',
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      _handleLogin(context);
                    },
                  ),
                ),

                // New here? Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New here?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
