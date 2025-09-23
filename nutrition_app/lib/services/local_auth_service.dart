import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage_service.dart';
import '../models/local_user.dart';

/// Simplified local authentication service for new-features branch
class LocalAuthService {
  static late SharedPreferences _prefs;
  
  /// Initialize the service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Register a new user locally
  static Future<bool> registerUser(String username, String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = _prefs.getString('user_$username');
      if (existingUser != null) {
        print('User $username already exists');
        return false;
      }
      
      // Save user credentials
      final userData = '$username|$email|$password|${DateTime.now().millisecondsSinceEpoch}';
      await _prefs.setString('user_$username', userData);
      
      // Add to users list
      final users = _prefs.getStringList('all_users') ?? [];
      if (!users.contains(username)) {
        users.add(username);
        await _prefs.setStringList('all_users', users);
      }
      
      print('User $username registered successfully');
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }
  
  /// Login user locally
  static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    try {
      final userData = _prefs.getString('user_$username');
      if (userData == null) {
        print('User $username not found');
        return null;
      }
      
      final parts = userData.split('|');
      if (parts.length < 4) {
        print('Invalid user data format');
        return null;
      }
      
      final storedUsername = parts[0];
      final storedEmail = parts[1];
      final storedPassword = parts[2];
      final createdAt = int.parse(parts[3]);
      
      if (storedPassword != password) {
        print('Invalid password for user $username');
        return null;
      }
      
      // Create user session
      await _prefs.setBool('is_logged_in', true);
      await _prefs.setString('current_username', storedUsername);
      await _prefs.setString('current_email', storedEmail);
      
      // Save to local storage service as well
      final localUser = LocalUser(
        id: storedUsername,
        username: storedUsername,
        email: storedEmail,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
        tokens: 0,
        totalTokens: 0,
        workoutStreak: 0,
      );
      
      await LocalStorageService.saveUser(localUser);
      
      print('User $username logged in successfully');
      return {
        'success': true,
        'username': storedUsername,
        'email': storedEmail,
        'token': 'local_token_$storedUsername',
      };
    } catch (e) {
      print('Error logging in user: $e');
      return null;
    }
  }
  
  /// Check if user is logged in
  static bool isLoggedIn() {
    return _prefs.getBool('is_logged_in') ?? false;
  }
  
  /// Get current logged in user
  static String? getCurrentUsername() {
    if (!isLoggedIn()) return null;
    return _prefs.getString('current_username');
  }
  
  /// Get current user email
  static String? getCurrentUserEmail() {
    if (!isLoggedIn()) return null;
    return _prefs.getString('current_email');
  }
  
  /// Logout current user
  static Future<void> logout() async {
    await _prefs.setBool('is_logged_in', false);
    await _prefs.remove('current_username');
    await _prefs.remove('current_email');
    await LocalStorageService.clearCurrentUser();
    print('User logged out successfully');
  }
  
  /// Get all registered users (for debugging)
  static List<String> getAllUsers() {
    return _prefs.getStringList('all_users') ?? [];
  }
  
  /// Check if user exists
  static bool userExists(String username) {
    return _prefs.getString('user_$username') != null;
  }
}