import '../core/app_export.dart';

class AuthNotifier extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> signup(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    final token = dotenv.env['TOKEN'] ?? '';
    try {
      User user = User(
          username: username,
          email_id: email,
          password: password,
          token: token);
      final result = await _userRepository.signup(user);
      if (result == true) {
        _successMessage = "Signup successful";
      } else {
        _errorMessage = "Signup failed";
      }
    } catch (e) {
      _errorMessage = "Signup failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI of state changes
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    final token = dotenv.env['TOKEN'] ?? '';
    try {
      User user = User(username: username, password: password, token: token);
      final result = await _userRepository.login(user);
      
      if (result != null && result['success'] == true) {
        print('AUTH_NOTIFIER: Login result success = true');
        _successMessage = "Login successful";

        // Extract user data from backend response
        final userData = result['userData'];
        final accessToken = result['token'];
        print('AUTH_NOTIFIER: userData = $userData');
        print('AUTH_NOTIFIER: accessToken = $accessToken');
        
        // Save login status and user info to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', userData['username'] ?? username);
        await prefs.setString('user_email', userData['email'] ?? '');
        await prefs.setString('user_fullname', userData['fullName'] ?? '');
        await prefs.setString('access_token', accessToken ?? '');
        await prefs.setBool('isLoggedIn', true);
        print('AUTH_NOTIFIER: Shared preferences saved');
        
        // Also save user profile using DataService for local storage
        print('AUTH_NOTIFIER: About to call DataService.saveUserProfile');
        final saveResult = await DataService.saveUserProfile(
          username: userData['username'] ?? username,
          email: userData['email'] ?? '',
          preferences: {
            'fullName': userData['fullName'] ?? '',
            'age': userData['age'],
            'height': userData['height'],
            'weight': userData['weight'],
            'bmi': userData['bmi'],
            'bmiCategory': userData['bmiCategory'],
          },
        );
        print('AUTH_NOTIFIER: DataService.saveUserProfile result = $saveResult');
      } else {
        print('AUTH_NOTIFIER: Login result was null or success = false');
        print('AUTH_NOTIFIER: result = $result');
        _errorMessage = "Login failed";
      }
    } catch (e) {
      print('AUTH_NOTIFIER: Exception in login: $e');
      _errorMessage = "Login failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    // Get SharedPreferences instance
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the username from SharedPreferences
    String? username = prefs.getString('username');

    try {
      // Create the User object with the retrieved username
      User user = User(username: username);
      final result = await _userRepository.logout(user);

      if (result == true) {
        _successMessage = "Logout successful";

        // Clear login status from shared preferences
        await prefs.setBool('isLoggedIn', false);
        // Optionally, clear the username as well
        await prefs.remove('username');
        
        // Clear user data from local storage to ensure data isolation
        await LocalStorageService.clearCurrentUser();
      } else {
        _errorMessage = "Logout failed";
      }
    } catch (e) {
      _errorMessage = "Logout failed: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners about state changes
    }
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
