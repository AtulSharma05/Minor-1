import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_workout.dart';

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

    // Open boxes
    _workoutsBox = await Hive.openBox<LocalWorkout>(_workoutsBoxName);
    _userBox = await Hive.openBox<LocalUser>(_userBoxName);
    _settingsBox = await Hive.openBox<Map<String, dynamic>>(_settingsBoxName);

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    print('Local storage initialized successfully');
  }

  // ===================== WORKOUT OPERATIONS =====================

  /// Save a workout to local storage
  static Future<void> saveWorkout(LocalWorkout workout) async {
    await _workoutsBox.put(workout.id, workout);
    print('Workout saved locally: ${workout.name}');
  }

  /// Get a specific workout by ID
  static LocalWorkout? getWorkout(String id) {
    return _workoutsBox.get(id);
  }

  /// Get all workouts
  static List<LocalWorkout> getAllWorkouts() {
    return _workoutsBox.values.toList();
  }

  /// Get workouts for a specific date
  static List<LocalWorkout> getWorkoutsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _workoutsBox.values.where((workout) {
      return workout.date.isAfter(startOfDay) && workout.date.isBefore(endOfDay);
    }).toList();
  }

  /// Get workouts in a date range
  static List<LocalWorkout> getWorkoutsInRange(DateTime start, DateTime end) {
    return _workoutsBox.values.where((workout) {
      return workout.date.isAfter(start) && workout.date.isBefore(end);
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

  /// Get completed workouts count
  static int getCompletedWorkoutsCount() {
    return _workoutsBox.values.where((workout) => workout.isCompleted).length;
  }

  // ===================== USER OPERATIONS =====================

  /// Save user data
  static Future<void> saveUser(LocalUser user) async {
    await _userBox.put('current_user', user);
    print('User data saved locally: ${user.username}');
  }

  /// Get current user
  static LocalUser? getCurrentUser() {
    return _userBox.get('current_user');
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
