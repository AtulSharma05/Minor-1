import '../core/app_export.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background shapes
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/welcome/left-rec.png',
              width: width,
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/welcome/right-rec.png',
              width: width,
              fit: BoxFit.fill,
            ),
          ),
          // Main content
          Positioned(
            top: height * 0.5,
            left: width * 0.1,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Greeting text
                  Text(
                    'Hello!',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      // Adjust color as needed
                    ),
                  ),
                  // const SizedBox(height: 10),
                  Text(
                    'Let\'s get started',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary, // Adjust color as needed
                    ),
                  ),
                ]),
          ),
          // const SizedBox(height: 20),

          Positioned(
              bottom: height * 0.1,
              left: width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Sign in button
                  CustomButton(
                    text: 'Sign in',
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signin');
                    },
                  ),
                  const SizedBox(height: 20),
                  // Sign up button
                  CustomButton(
                    text: 'Create an account',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
