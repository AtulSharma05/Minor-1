import '../core/app_export.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers are initialized only once in the State class
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void _handleSignup(BuildContext context) async {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

    // Get values from your text fields
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    // Call the signup function and wait for it to complete
    await authNotifier.signup(username, email, password);

    // Show SnackBar with the appropriate message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authNotifier.successMessage ??
            authNotifier.errorMessage ??
            'An error occurred'),
      ),
    );

    // Check if signup was successful
    if (authNotifier.successMessage != null) {
      // Navigate to the Welcome page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SigninPage()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers when no longer needed to avoid memory leaks
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final authNotifier = Provider.of<AuthNotifier>(context);

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
          Positioned(
            top: height * 0.23, // Adjust the vertical position as needed
            left: width * 0.1,
            right: width *
                0.1, // Center-align the text by keeping equal space on both sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Register!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.38,
            left: width * 0.1,
            right: width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextField(
                  hintText: "Username",
                  fieldType: "username",
                  controller: usernameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Your email",
                  fieldType: "email",
                  controller: emailController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  hintText: "Your password",
                  fieldType: "password",
                  controller: passwordController,
                ),
                const SizedBox(height: 45),
                Center(
                  child: authNotifier.isLoading // Check the loading state
                      ? const CircularProgressIndicator() // Show spinner if loading
                      : CustomButton(
                          text: 'Sign up',
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            _handleSignup(context); // Call the signup function
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: height * 0.8,
            left: width * 0.1,
            right: width * 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: [
                          // Left line
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary, // Line color
                            ),
                          ),
                          // Text in the middle
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          // Right line
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary, // Line color
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset('assets/icons/glogin.png'),
                            onPressed: () {
                              // Handle Google login
                            },
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Image.asset('assets/icons/flogin.png'),
                            onPressed: () {
                              // Handle Facebook login
                            },
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Image.asset('assets/icons/xlogin.png'),
                            onPressed: () {
                              // Handle Twitter login
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
