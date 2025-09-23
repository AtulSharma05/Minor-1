import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_workout.dart';
import '../models/local_user.dart';

class LocalStorageService {
  static const String _workoutsBoxName = 'workouts';
  static const String _userBoxName = 'user';
  static const String _settingsBoxName = 'settings';

  // Hive boxes for structured data
  static late Box<LocalWorkout> _workoutsBox;
  static late Box<LocalUser> _userBox;
  static late Box<Map<String, dynamic>> _settingsBox;

  // SharedPreferences for simple key-value data
  static late SharedPreferences _prefs;

  /// Initialize local storage
  static Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(LocalWorkoutAdapter());
    Hive.registerAdapter(LocalExerciseAdapter());
    Hive.registerAdapter(LocalUserAdapter());

    try {
      // Try to open boxes normally
      _workoutsBox = await Hive.openBox<LocalWorkout>(_workoutsBoxName);
      _userBox = await Hive.openBox<LocalUser>(_userBoxName);
      _settingsBox = await Hive.openBox<Map<String, dynamic>>(_settingsBoxName);
    } catch (e) {
      print('Error opening Hive boxes (likely schema change): $e');
      print('Attempting to clear and recreate boxes...');
      
      try {
        // Delete existing boxes to handle schema changes
        await Hive.deleteBoxFromDisk(_workoutsBoxName);
        await Hive.deleteBoxFromDisk(_userBoxName);
        await Hive.deleteBoxFromDisk(_settingsBoxName);
        
        // Recreate boxes
        _workoutsBox = await Hive.openBox<LocalWorkout>(_workoutsBoxName);
        _userBox = await Hive.openBox<LocalUser>(_userBoxName);
        _settingsBox = await Hive.openBox<Map<String, dynamic>>(_settingsBoxName);
        
        print('Successfully recreated Hive boxes');
      } catch (recreateError) {
        print('Failed to recreate boxes: $recreateError');
        rethrow;
      }
    }

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    print('Local storage initialized successfully');
  }

  // ===================== WORKOUT OPERATIONS =====================

  /// Save a workout to local storage with user scope
  static Future<void> saveWorkout(LocalWorkout workout) async {
    // Ensure workout has current user's ID
    final currentUser = getCurrentUser();
    print('Current user when saving workout: ${currentUser?.username}');
    
    if (currentUser != null && currentUser.username != null) {
      workout.userId = currentUser.username!;
      print('Assigned userId to workout: ${workout.userId}');
    } else {
      print('WARNING: No current user found or username is null when saving workout!');
    }
    
    await _workoutsBox.put(workout.id, workout);
    print('Workout saved locally for user ${workout.userId}: ${workout.name}');
    
    // Debug: Immediately try to retrieve and see if filtering works
    print('Verification - Total workouts after save: ${_workoutsBox.length}');
    final retrievedWorkout = _workoutsBox.get(workout.id);
    print('Verification - Retrieved workout userId: ${retrievedWorkout?.userId}');
    
    // Test the filtering logic
    final allUserWorkouts = getAllWorkouts();
    print('Verification - getAllWorkouts() returned ${allUserWorkouts.length} workouts');
  }

  /// Get a specific workout by ID
  static LocalWorkout? getWorkout(String id) {
    return _workoutsBox.get(id);
  }

  /// Get all workouts for the current user
  static List<LocalWorkout> getAllWorkouts() {
    final currentUser = getCurrentUser();
    if (currentUser == null || currentUser.username == null) {
      print('getAllWorkouts: No current user found or username is null!');
      return []; // No user logged in, return empty list
    }
    
    print('getAllWorkouts: Current user is ${currentUser.username}');
    print('getAllWorkouts: Total workouts in box: ${_workoutsBox.length}');
    
    // Debug: Print all workouts with detailed comparison
    for (final workout in _workoutsBox.values) {
      print('getAllWorkouts: Found workout ${workout.name} with userId: "${workout.userId}"');
      print('getAllWorkouts: Comparing "${workout.userId}" == "${currentUser.username}" = ${workout.userId == currentUser.username}');
      print('getAllWorkouts: userId length: ${workout.userId?.length}, username length: ${currentUser.username?.length}');
    }
    
    final userWorkouts = _workoutsBox.values
        .where((workout) {
          final match = workout.userId == currentUser.username;
          print('getAllWorkouts: Workout "${workout.name}" matches user? $match');
          return match;
        })
        .toList();
    
    print('getAllWorkouts: Filtered workouts for user ${currentUser.username}: ${userWorkouts.length}');
    
    return userWorkouts;
  }

  /// Get all workouts (admin function - not user-scoped)
  static List<LocalWorkout> getAllWorkoutsForAllUsers() {
    return _workoutsBox.values.toList();
  }

  /// Get workouts for a specific date (current user only)
  static List<LocalWorkout> getWorkoutsForDate(DateTime date) {
    final currentUser = getCurrentUser();
    if (currentUser == null || currentUser.username == null) {
      return [];
    }
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _workoutsBox.values.where((workout) {
      return workout.userId == currentUser.username! &&
             workout.date.isAfter(startOfDay) && 
             workout.date.isBefore(endOfDay);
    }).toList();
  }

  /// Get workouts in a date range (current user only)
  static List<LocalWorkout> getWorkoutsInRange(DateTime start, DateTime end) {
    final currentUser = getCurrentUser();
    if (currentUser == null || currentUser.username == null) {
      return [];
    }
    
    return _workoutsBox.values.where((workout) {
      return workout.userId == currentUser.username! &&
             workout.date.isAfter(start) && 
             workout.date.isBefore(end);
    }).toList();
  }

  /// Update a workout
  static Future<void> updateWorkout(LocalWorkout workout) async {
    await _workoutsBox.put(workout.id, workout);
    print('Workout updated locally: ${workout.name}');
  }

  /// Delete a workout
  static Future<void> deleteWorkout(String id) async {
    await _workoutsBox.delete(id);
    print('Workout deleted locally: $id');
  }

  /// Get completed workouts count for current user
  static int getCompletedWorkoutsCount() {
    final currentUser = getCurrentUser();
    if (currentUser == null || currentUser.username == null) {
      return 0;
    }
    
    return _workoutsBox.values
        .where((workout) => workout.userId == currentUser.username! && workout.isCompleted)
        .length;
  }

  // ===================== USER OPERATIONS =====================

  /// Save user data
  static Future<void> saveUser(LocalUser user) async {
    try {
      await _userBox.put('current_user', user);
      print('User data saved locally: ${user.username}');
      
      // Verify save by reading back
      final savedUser = _userBox.get('current_user');
      print('Verification - saved user: ${savedUser?.username}');
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }

  /// Get current user
  static LocalUser? getCurrentUser() {
    try {
      final user = _userBox.get('current_user');
      print('Getting current user: ${user?.username}');
      return user;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Update user workout streak
  static Future<void> updateWorkoutStreak(int streak) async {
    final user = getCurrentUser();
    if (user != null) {
      user.workoutStreak = streak;
      user.lastWorkoutDate = DateTime.now();
      await saveUser(user);
    }
  }

  /// Update user tokens
  static Future<void> updateUserTokens(int tokens) async {
    final user = getCurrentUser();
    if (user != null) {
      user.tokens = tokens;
      user.totalTokens = tokens; // Keep totalTokens as a record
      await saveUser(user);
    }
  }

  /// Add tokens to user
  static Future<void> addTokens(int tokensToAdd) async {
    final user = getCurrentUser();
    if (user != null) {
      user.tokens += tokensToAdd;
      user.totalTokens += tokensToAdd;
      await saveUser(user);
    }
  }

  /// Clear current user data (logout)
  static Future<void> clearCurrentUser() async {
    await _userBox.delete('current_user');
    print('Current user data cleared');
  }

  /// Clear all user data (for switching users)
  static Future<void> clearAllUserData() async {
    // Clear current user
    await clearCurrentUser();
    
    // Optionally, you could clear all workouts here if needed
    // await _workoutsBox.clear();
    
    print('All user data cleared');
  }

  // ===================== SETTINGS OPERATIONS =====================

  /// Save app settings
  static Future<void> saveSetting(String key, Map<String, dynamic> value) async {
    await _settingsBox.put(key, value);
  }

  /// Get app setting
  static Map<String, dynamic>? getSetting(String key) {
    return _settingsBox.get(key);
  }

  // ===================== SIMPLE PREFERENCES =====================

  /// Check if user is logged in
  static bool get isLoggedIn => _prefs.getBool('is_logged_in') ?? false;

  /// Set login status
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool('is_logged_in', value);
  }

  /// Get username
  static String? get username => _prefs.getString('username');

  /// Set username
  static Future<void> setUsername(String username) async {
    await _prefs.setString('username', username);
  }

  /// Get user token
  static String? get userToken => _prefs.getString('user_token');

  /// Set user token
  static Future<void> setUserToken(String token) async {
    await _prefs.setString('user_token', token);
  }

  /// Get last sync timestamp
  static DateTime? get lastSync {
    final timestamp = _prefs.getInt('last_sync');
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Set last sync timestamp
  static Future<void> setLastSync(DateTime dateTime) async {
    await _prefs.setInt('last_sync', dateTime.millisecondsSinceEpoch);
  }

  /// Check if offline mode is enabled
  static bool get isOfflineMode => _prefs.getBool('offline_mode') ?? false;

  /// Toggle offline mode
  static Future<void> setOfflineMode(bool value) async {
    await _prefs.setBool('offline_mode', value);
  }

  // ===================== DEBUG METHODS =====================
  
  /// Debug method to print all workouts and user info
  static void debugPrintAllData() {
    print('=== DEBUG: LOCAL STORAGE STATE ===');
    
    final currentUser = getCurrentUser();
    print('Current user: ${currentUser?.username} (ID: ${currentUser?.id})');
    print('User created at: ${currentUser?.createdAt}');
    print('Is logged in (prefs): ${_prefs.getBool('is_logged_in')}');
    print('Username (prefs): ${_prefs.getString('username')}');
    
    print('\nTotal workouts in database: ${_workoutsBox.length}');
    
    for (final workout in _workoutsBox.values) {
      print('Workout: ${workout.name}');
      print('  - ID: ${workout.id}');
      print('  - UserId: "${workout.userId}"');
      print('  - Date: ${workout.date}');
      print('  - Completed: ${workout.isCompleted}');
      print('');
    }
    
    final userWorkouts = getAllWorkouts();
    print('Filtered workouts for current user: ${userWorkouts.length}');
    
    print('=== END DEBUG ===');
  }

  /// Clear all data for testing
  static Future<void> debugClearAllData() async {
    await _workoutsBox.clear();
    await _userBox.clear();
    await _prefs.clear();
    print('DEBUG: All data cleared');
  }

  // ===================== UTILITY METHODS =====================

  /// Clear all workout data
  static Future<void> clearAllWorkouts() async {
    await _workoutsBox.clear();
    print('All workout data cleared');
  }

  /// Clear user data
  static Future<void> clearUserData() async {
    await _userBox.clear();
    await _prefs.remove('is_logged_in');
    await _prefs.remove('username');
    await _prefs.remove('user_token');
    print('User data cleared');
  }

  // ============ AUTHENTICATION METHODS ============
  
  /// Save user account for authentication (stores username, email, password)
  static Future<bool> saveUserAccount(String username, String email, String password) async {
    try {
      // Check if user already exists
      final existingAccounts = await getStoredAccounts();
      if (existingAccounts.any((account) => account['username'] == username || account['email'] == email)) {
        return false; // User already exists
      }
      
      // Store new account
      final accountKey = 'account_$username';
      await _prefs.setString(accountKey, '$username|$email|$password');
      
      // Keep track of all accounts
      final accounts = _prefs.getStringList('all_accounts') ?? [];
      accounts.add(username);
      await _prefs.setStringList('all_accounts', accounts);
      
      print('Account saved locally: $username');
      return true;
    } catch (e) {
      print('Error saving account: $e');
      return false;
    }
  }
  
  /// Verify user credentials and login
  static Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    try {
      final accountKey = 'account_$username';
      final accountData = _prefs.getString(accountKey);
      
      if (accountData != null) {
        final parts = accountData.split('|');
        if (parts.length == 3) {
          final storedUsername = parts[0];
          final storedEmail = parts[1];
          final storedPassword = parts[2];
          
          if (storedPassword == password) {
            // Create and save current user session
            final localUser = LocalUser(
              id: storedUsername,
              username: storedUsername,
              email: storedEmail,
              createdAt: DateTime.now(),
            );
            
            await saveUser(localUser);
            await _prefs.setBool('is_logged_in', true);
            await _prefs.setString('username', storedUsername);
            
            return {
              'username': storedUsername,
              'email': storedEmail,
              'token': 'local_token_$storedUsername',
            };
          }
        }
      }
      
      // Try email authentication as well
      final accounts = await getStoredAccounts();
      for (final account in accounts) {
        if (account['email'] == username && account['password'] == password) {
          final accountUsername = account['username']!;
          final accountEmail = account['email']!;
          
          final localUser = LocalUser(
            id: accountUsername,
            username: accountUsername,
            email: accountEmail,
            createdAt: DateTime.now(),
          );
          
          await saveUser(localUser);
          await _prefs.setBool('is_logged_in', true);
          await _prefs.setString('username', accountUsername);
          
          return {
            'username': accountUsername,
            'email': accountEmail,
            'token': 'local_token_$accountUsername',
          };
        }
      }
      
      return null; // Authentication failed
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }
  
  /// Get all stored accounts (for debugging)
  static Future<List<Map<String, String>>> getStoredAccounts() async {
    try {
      final accounts = _prefs.getStringList('all_accounts') ?? [];
      final List<Map<String, String>> accountList = [];
      
      for (final username in accounts) {
        final accountKey = 'account_$username';
        final accountData = _prefs.getString(accountKey);
        if (accountData != null) {
          final parts = accountData.split('|');
          if (parts.length == 3) {
            accountList.add({
              'username': parts[0],
              'email': parts[1],
              'password': parts[2], // Only for internal use
            });
          }
        }
      }
      
      return accountList;
    } catch (e) {
      print('Error getting stored accounts: $e');
      return [];
    }
  }

  /// Clear all local data
  static Future<void> clearAllData() async {
    await _workoutsBox.clear();
    await _userBox.clear();
    await _settingsBox.clear();
    await _prefs.clear();
    print('All local data cleared');
  }

  /// Get storage statistics
  static Map<String, int> getStorageStats() {
    return {
      'total_workouts': _workoutsBox.length,
      'completed_workouts': getCompletedWorkoutsCount(),
      'users': _userBox.length,
      'settings': _settingsBox.length,
    };
  }
}
