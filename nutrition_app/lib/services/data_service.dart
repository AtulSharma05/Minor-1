import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/local_workout.dart';
import '../models/local_user.dart';
import 'local_storage_service.dart';
import 'package:uuid/uuid.dart';

/// Simplified data abstraction layer that manages offline/online modes
class DataService {
  // UUID generator for local IDs
  static const Uuid _uuid = Uuid();

  /// Check if backend is enabled from environment
  static bool get isBackendEnabled {
    return dotenv.env['BACKEND_ENABLED']?.toLowerCase() == 'true';
  }

  /// Check if we should use local storage (always true for now in offline mode)
  static bool get shouldUseLocalStorage {
    return !isBackendEnabled || LocalStorageService.isOfflineMode;
  }

  // ===================== WORKOUT OPERATIONS =====================

  /// Search for workouts
  static Future<List<Map<String, dynamic>>> searchWorkouts(String query) async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final url = Uri.parse('$baseUrl/api/v1/workouts?search=${Uri.encodeComponent(query)}&limit=20');
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true) {
              final List<dynamic> workouts = responseData['data']['workouts'] ?? [];
              return workouts.map((workout) => workout as Map<String, dynamic>).toList();
            }
          }
          
          print('Backend workout search failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend workout search failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final allWorkouts = LocalStorageService.getAllWorkouts();
    return allWorkouts
        .where((workout) => workout.name.toLowerCase().contains(query.toLowerCase()))
        .map((workout) => workout.toJson())
        .toList();
  }

  /// Get workout details
  static Future<Map<String, dynamic>?> getWorkoutDetails(String workoutId) async {
    final workout = LocalStorageService.getWorkout(workoutId);
    return workout?.toJson();
  }

  /// Log a workout
  static Future<Map<String, dynamic>> logWorkout({
    required String name,
    required String description,
    required int duration,
    required int calories,
    required String category,
    List<Map<String, dynamic>> exercises = const [],
    String? notes,
  }) async {
    try {
      final localWorkout = LocalWorkout(
        id: _uuid.v4(),
        name: name,
        description: description,
        duration: duration,
        calories: calories,
        category: category,
        date: DateTime.now(),
        exercises: exercises.map((e) => LocalExercise(
          name: e['name'] ?? 'Exercise',
          sets: e['sets'] ?? 1,
          reps: e['reps'] ?? 1,
          weight: e['weight']?.toDouble(),
          duration: e['duration'],
          notes: e['notes'],
        )).toList(),
        isCompleted: true,
        notes: notes,
      );

      await LocalStorageService.saveWorkout(localWorkout);

      // Update user workout streak
      await _updateWorkoutStreak();

      // Award tokens for completing workout
      final tokenRewards = await _awardTokensForWorkout();

      // Automatically sync workout data after logging
      print('DataService: Starting automatic sync after workout logging');
      try {
        final syncResult = await synchronizeData();
        print('DataService: Workout sync result: ${syncResult['message']}');
      } catch (e) {
        print('DataService: Workout sync failed: $e');
        // Don't fail workout logging if sync fails
      }

      return {
        'success': true,
        'workout_id': localWorkout.id,
        'token_rewards': tokenRewards,
      };
    } catch (e) {
      print('Failed to log workout: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get workout history
  static Future<List<Map<String, dynamic>>> getWorkoutHistory({int limit = 50}) async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final url = Uri.parse('$baseUrl/api/v1/workouts?limit=$limit&sortBy=date&sortOrder=desc');
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true) {
              final List<dynamic> workouts = responseData['data']['workouts'] ?? [];
              return workouts.map((workout) => workout as Map<String, dynamic>).toList();
            }
          }
          
          print('Backend workout history failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend workout history failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final workouts = LocalStorageService.getAllWorkouts();
    workouts.sort((a, b) => b.date.compareTo(a.date)); // Most recent first
    return workouts
        .take(limit)
        .map((workout) => workout.toJson())
        .toList();
  }

  /// Get workout statistics for date range
  static Future<Map<String, dynamic>> getWorkoutStats(DateTime start, DateTime end) async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final startDate = start.toIso8601String().split('T')[0];
          final endDate = end.toIso8601String().split('T')[0];
          final url = Uri.parse('$baseUrl/api/v1/workouts/stats?startDate=$startDate&endDate=$endDate');
          
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true) {
              return responseData['data'] as Map<String, dynamic>;
            }
          }
          
          print('Backend workout stats failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend workout stats failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final workouts = LocalStorageService.getWorkoutsInRange(start, end);
    
    final totalWorkouts = workouts.length;
    final completedWorkouts = workouts.where((w) => w.isCompleted).length;
    final totalDuration = workouts.fold(0, (sum, w) => sum + w.duration);
    final totalCalories = workouts.fold(0, (sum, w) => sum + w.calories);

    // Group by category
    final categoryStats = <String, int>{};
    for (final workout in workouts) {
      categoryStats[workout.category] = (categoryStats[workout.category] ?? 0) + 1;
    }

    return {
      'total_workouts': totalWorkouts,
      'completed_workouts': completedWorkouts,
      'completion_rate': totalWorkouts > 0 ? (completedWorkouts / totalWorkouts * 100).round() : 0,
      'total_duration': totalDuration,
      'total_calories': totalCalories,
      'average_duration': totalWorkouts > 0 ? (totalDuration / totalWorkouts).round() : 0,
      'average_calories': totalWorkouts > 0 ? (totalCalories / totalWorkouts).round() : 0,
      'category_breakdown': categoryStats,
      'period': {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      }
    };
  }

  /// Get today's workout progress
  static Future<Map<String, dynamic>> getTodayProgress() async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final today = DateTime.now().toIso8601String().split('T')[0];
          final url = Uri.parse('$baseUrl/api/v1/workouts/stats?startDate=$today&endDate=$today');
          
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['success'] == true) {
              final apiData = responseData['data'] as Map<String, dynamic>;
              
              // Transform API response to match expected format
              const dailyWorkoutGoal = 1;
              const dailyDurationGoal = 30;
              
              final workoutsCompleted = apiData['completed_workouts'] ?? 0;
              final durationCompleted = apiData['total_duration'] ?? 0;
              final caloriesBurned = apiData['total_calories'] ?? 0;
              
              final workoutProgress = workoutsCompleted / dailyWorkoutGoal;
              final durationProgress = durationCompleted / dailyDurationGoal;
              
              return {
                'workouts_completed': workoutsCompleted,
                'workout_goal': dailyWorkoutGoal,
                'workout_progress': (workoutProgress * 100).clamp(0, 100).round(),
                'duration_completed': durationCompleted,
                'duration_goal': dailyDurationGoal,
                'duration_progress': (durationProgress * 100).clamp(0, 100).round(),
                'calories_burned': caloriesBurned,
                'overall_progress': ((workoutProgress + durationProgress) / 2 * 100).clamp(0, 100).round(),
              };
            }
          }
          
          print('Backend today progress failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend today progress failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final todayWorkouts = LocalStorageService.getWorkoutsInRange(startOfDay, endOfDay);
    final completedToday = todayWorkouts.where((w) => w.isCompleted).length;
    final totalDurationToday = todayWorkouts.fold(0, (sum, w) => sum + w.duration);
    final totalCaloriesToday = todayWorkouts.fold(0, (sum, w) => sum + w.calories);

    // Simple daily goal (can be made configurable later)
    const dailyWorkoutGoal = 1; // At least 1 workout per day
    const dailyDurationGoal = 30; // 30 minutes per day
    
    final workoutProgress = completedToday / dailyWorkoutGoal;
    final durationProgress = totalDurationToday / dailyDurationGoal;

    return {
      'workouts_completed': completedToday,
      'workout_goal': dailyWorkoutGoal,
      'workout_progress': (workoutProgress * 100).clamp(0, 100).round(),
      'duration_completed': totalDurationToday,
      'duration_goal': dailyDurationGoal,
      'duration_progress': (durationProgress * 100).clamp(0, 100).round(),
      'calories_burned': totalCaloriesToday,
      'overall_progress': ((workoutProgress + durationProgress) / 2 * 100).clamp(0, 100).round(),
    };
  }

  // ===================== USER OPERATIONS =====================

  /// Create or update user profile
  static Future<bool> saveUserProfile({
    required String username,
    required String email,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      print('DataService.saveUserProfile called for: $username');
      final existingUser = LocalStorageService.getCurrentUser();
      print('Existing user: ${existingUser?.username}');
      
      final user = LocalUser(
        id: existingUser?.id ?? _uuid.v4(),
        username: username,
        email: email,
        workoutStreak: existingUser?.workoutStreak ?? 0,
        totalTokens: existingUser?.totalTokens ?? 0,
        lastWorkoutDate: existingUser?.lastWorkoutDate,
        createdAt: existingUser?.createdAt ?? DateTime.now(),
        purchasedRewards: existingUser?.purchasedRewards,
        settings: preferences,
      );

      print('Created user object: ${user.username}');
      await LocalStorageService.saveUser(user);
      await LocalStorageService.setUsername(username);
      await LocalStorageService.setLoggedIn(true);

      print('User profile saved successfully');
      return true;
    } catch (e) {
      print('Failed to save user profile: $e');
      return false;
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final url = Uri.parse('$baseUrl/api/v1/auth/me');
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['status'] == 'success') {
              final apiUser = responseData['data']['user'] as Map<String, dynamic>;
              
              // Sync API data with local storage
              final localUser = LocalUser(
                id: apiUser['_id'] ?? _uuid.v4(),
                username: apiUser['username'] ?? '',
                email: apiUser['email'] ?? '',
                workoutStreak: apiUser['workoutStreak'] ?? 0,
                totalTokens: apiUser['totalTokens'] ?? 0,
                lastWorkoutDate: apiUser['lastWorkoutDate'] != null 
                    ? DateTime.parse(apiUser['lastWorkoutDate'])
                    : null,
                createdAt: apiUser['createdAt'] != null 
                    ? DateTime.parse(apiUser['createdAt'])
                    : DateTime.now(),
                settings: apiUser['preferences'],
              );
              
              await LocalStorageService.saveUser(localUser);
              
              return {
                ...apiUser,
                'is_logged_in': LocalStorageService.isLoggedIn,
                'offline_mode': LocalStorageService.isOfflineMode,
                'backend_enabled': isBackendEnabled,
              };
            }
          }
          
          print('Backend user profile failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend user profile failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final user = LocalStorageService.getCurrentUser();
    if (user != null) {
      return {
        ...user.toJson(),
        'is_logged_in': LocalStorageService.isLoggedIn,
        'offline_mode': LocalStorageService.isOfflineMode,
        'backend_enabled': isBackendEnabled,
      };
    }
    return null;
  }

  /// Get current workout streak
  static Future<int> getWorkoutStreak() async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final profile = await getUserProfile();
        if (profile != null && profile['workoutStreak'] != null) {
          return profile['workoutStreak'] as int;
        }
      } catch (e) {
        print('Backend workout streak failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final user = LocalStorageService.getCurrentUser();
    return user?.workoutStreak ?? 0;
  }

  /// Get detailed streak information
  static Future<Map<String, dynamic>> getStreakDetails() async {
    if (isBackendEnabled && !LocalStorageService.isOfflineMode) {
      try {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final token = LocalStorageService.userToken;
        
        if (baseUrl.isNotEmpty && token != null) {
          final url = Uri.parse('$baseUrl/api/v1/auth/me');
          final response = await http.get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
          
          if (response.statusCode == 200) {
            final responseData = jsonDecode(response.body);
            if (responseData['status'] == 'success') {
              final apiUser = responseData['data']['user'] as Map<String, dynamic>;
              
              // If API has streak data, use it
              if (apiUser['workoutStreak'] != null) {
                final currentStreak = apiUser['workoutStreak'] as int;
                final lastWorkoutDate = apiUser['lastWorkoutDate'] != null 
                    ? DateTime.parse(apiUser['lastWorkoutDate'])
                    : DateTime.now();
                
                final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;
                
                // Calculate next milestone
                int nextMilestone = 7; // Weekly milestone
                if (currentStreak >= 7) nextMilestone = 30; // Monthly milestone
                if (currentStreak >= 30) nextMilestone = 100; // Centenary milestone
                if (currentStreak >= 100) nextMilestone = ((currentStreak ~/ 50) + 1) * 50; // Every 50 days
                
                return {
                  'current_streak': currentStreak,
                  'longest_streak': apiUser['longestStreak'] ?? currentStreak,
                  'last_workout_date': lastWorkoutDate.toIso8601String(),
                  'days_since_last_workout': daysSinceLastWorkout,
                  'is_active': daysSinceLastWorkout <= 1,
                  'next_milestone': nextMilestone,
                  'days_to_milestone': nextMilestone - currentStreak,
                  'streak_percentage_to_milestone': currentStreak / nextMilestone * 100,
                };
              }
            }
          }
          
          print('Backend streak details failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('Backend streak details failed, using local storage: $e');
      }
    }
    
    // Use local storage (fallback or default)
    final user = LocalStorageService.getCurrentUser();
    final currentStreak = user?.workoutStreak ?? 0;
    final lastWorkoutDate = user?.lastWorkoutDate ?? DateTime.now();
    
    // Calculate days since last workout
    final daysSinceLastWorkout = DateTime.now().difference(lastWorkoutDate).inDays;
    
    // Get workout history to calculate longest streak
    final allWorkouts = LocalStorageService.getAllWorkouts();
    allWorkouts.sort((a, b) => a.date.compareTo(b.date)); // Sort by date ascending
    
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;
    
    // Calculate longest streak from workout history
    for (final workout in allWorkouts) {
      if (workout.isCompleted) {
        final workoutDate = DateTime(workout.date.year, workout.date.month, workout.date.day);
        
        if (lastDate == null) {
          tempStreak = 1;
        } else {
          final dayDifference = workoutDate.difference(lastDate).inDays;
          if (dayDifference == 1) {
            tempStreak++;
          } else if (dayDifference > 1) {
            longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
            tempStreak = 1;
          }
          // If same day, don't change streak
        }
        lastDate = workoutDate;
      }
    }
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;

    // Calculate next milestone
    int nextMilestone = 7; // Weekly milestone
    if (currentStreak >= 7) nextMilestone = 30; // Monthly milestone
    if (currentStreak >= 30) nextMilestone = 100; // Centenary milestone
    if (currentStreak >= 100) nextMilestone = ((currentStreak ~/ 50) + 1) * 50; // Every 50 days

    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_workout_date': lastWorkoutDate.toIso8601String(),
      'days_since_last_workout': daysSinceLastWorkout,
      'is_active': daysSinceLastWorkout <= 1, // Streak is active if worked out today or yesterday
      'next_milestone': nextMilestone,
      'days_to_milestone': nextMilestone - currentStreak,
      'streak_percentage_to_milestone': currentStreak / nextMilestone * 100,
    };
  }

  /// Get streak achievements/milestones
  static Future<List<Map<String, dynamic>>> getStreakAchievements() async {
    final currentStreak = await getWorkoutStreak();
    
    final achievements = <Map<String, dynamic>>[];
    
    // Define milestones
    final milestones = [
      {'days': 3, 'title': 'Getting Started', 'description': 'Complete 3 days of workouts', 'icon': '🔥'},
      {'days': 7, 'title': 'Week Warrior', 'description': 'Complete a full week of workouts', 'icon': '⭐'},
      {'days': 14, 'title': 'Two Week Titan', 'description': 'Two weeks of consistent workouts', 'icon': '💪'},
      {'days': 30, 'title': 'Monthly Master', 'description': 'One month of workout dedication', 'icon': '🏆'},
      {'days': 50, 'title': 'Champion Spirit', 'description': '50 days of workout excellence', 'icon': '🎖️'},
      {'days': 100, 'title': 'Centurion', 'description': '100 days of unwavering commitment', 'icon': '👑'},
      {'days': 365, 'title': 'Year-Long Legend', 'description': 'A full year of workout consistency', 'icon': '🌟'},
    ];

    for (final milestone in milestones) {
      final days = milestone['days'] as int;
      achievements.add({
        'days': days,
        'title': milestone['title'],
        'description': milestone['description'],
        'icon': milestone['icon'],
        'achieved': currentStreak >= days,
        'progress': currentStreak >= days 
            ? 100 
            : (currentStreak / days * 100).clamp(0, 100).round(),
      });
    }

    return achievements;
  }

  /// Get user tokens
  static Future<int> getUserTokens() async {
    final user = LocalStorageService.getCurrentUser();
    return user?.tokens ?? 0;
  }

  /// Award tokens to user
  static Future<Map<String, dynamic>> awardTokens(int tokens, String reason) async {
    await LocalStorageService.addTokens(tokens);
    final newTotal = await getUserTokens();
    
    return {
      'tokens_awarded': tokens,
      'reason': reason,
      'new_total': newTotal,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get available rewards and achievements
  static Future<Map<String, dynamic>> getRewardsData() async {
    final user = LocalStorageService.getCurrentUser();
    final currentTokens = user?.tokens ?? 0;
    final workoutStreak = user?.workoutStreak ?? 0;
    final allWorkouts = LocalStorageService.getAllWorkouts();
    final totalWorkouts = allWorkouts.length;
    
    // Define achievements
    final achievements = [
      {
        'id': 'first_workout',
        'title': 'First Steps',
        'description': 'Complete your first workout',
        'icon': '🏃',
        'isUnlocked': totalWorkouts >= 1,
        'requirement': 1,
        'current': totalWorkouts,
        'type': 'workout_count',
      },
      {
        'id': 'streak_3',
        'title': 'Consistency',
        'description': 'Maintain a 3-day workout streak',
        'icon': '🔥',
        'isUnlocked': workoutStreak >= 3,
        'requirement': 3,
        'current': workoutStreak,
        'type': 'streak',
      },
      {
        'id': 'streak_7',
        'title': 'Weekly Warrior',
        'description': 'Maintain a 7-day workout streak',
        'icon': '⚡',
        'isUnlocked': workoutStreak >= 7,
        'requirement': 7,
        'current': workoutStreak,
        'type': 'streak',
      },
      {
        'id': 'streak_30',
        'title': 'Monthly Master',
        'description': 'Maintain a 30-day workout streak',
        'icon': '👑',
        'isUnlocked': workoutStreak >= 30,
        'requirement': 30,
        'current': workoutStreak,
        'type': 'streak',
      },
      {
        'id': 'workouts_10',
        'title': 'Dedicated',
        'description': 'Complete 10 workouts',
        'icon': '💪',
        'isUnlocked': totalWorkouts >= 10,
        'requirement': 10,
        'current': totalWorkouts,
        'type': 'workout_count',
      },
      {
        'id': 'workouts_50',
        'title': 'Committed',
        'description': 'Complete 50 workouts',
        'icon': '🏆',
        'isUnlocked': totalWorkouts >= 50,
        'requirement': 50,
        'current': totalWorkouts,
        'type': 'workout_count',
      },
      {
        'id': 'tokens_100',
        'title': 'Token Collector',
        'description': 'Earn 100 tokens',
        'icon': '🪙',
        'isUnlocked': currentTokens >= 100,
        'requirement': 100,
        'current': currentTokens,
        'type': 'tokens',
      },
    ];

    // Define rewards that can be unlocked with tokens
    final rewards = [
      {
        'id': 'custom_theme',
        'title': 'Custom Theme',
        'description': 'Unlock custom app themes',
        'cost': 50,
        'icon': '🎨',
        'isAffordable': currentTokens >= 50,
        'type': 'theme',
      },
      {
        'id': 'advanced_stats',
        'title': 'Advanced Statistics',
        'description': 'Detailed workout analytics',
        'cost': 100,
        'icon': '📊',
        'isAffordable': currentTokens >= 100,
        'type': 'feature',
      },
      {
        'id': 'workout_templates',
        'title': 'Workout Templates',
        'description': 'Pre-made workout routines',
        'cost': 75,
        'icon': '📋',
        'isAffordable': currentTokens >= 75,
        'type': 'feature',
      },
      {
        'id': 'premium_badges',
        'title': 'Premium Badges',
        'description': 'Exclusive achievement badges',
        'cost': 150,
        'icon': '🏅',
        'isAffordable': currentTokens >= 150,
        'type': 'cosmetic',
      },
    ];

    return {
      'current_tokens': currentTokens,
      'achievements': achievements,
      'rewards': rewards,
      'total_achievements': achievements.length,
      'unlocked_achievements': achievements.where((a) => a['isUnlocked'] == true).length,
    };
  }

  /// Purchase a reward with tokens
  static Future<Map<String, dynamic>> purchaseReward(String rewardId, int cost) async {
    final currentTokens = await getUserTokens();
    
    if (currentTokens < cost) {
      return {
        'success': false,
        'message': 'Insufficient tokens',
        'required': cost,
        'available': currentTokens,
      };
    }

    // Deduct tokens
    await LocalStorageService.addTokens(-cost);
    final newBalance = await getUserTokens();

    // Here you could save purchased rewards to user preferences
    final user = LocalStorageService.getCurrentUser();
    if (user != null) {
      user.purchasedRewards ??= [];
      if (!user.purchasedRewards!.contains(rewardId)) {
        user.purchasedRewards!.add(rewardId);
        await LocalStorageService.saveUser(user);
      }
    }

    return {
      'success': true,
      'message': 'Reward purchased successfully!',
      'reward_id': rewardId,
      'cost': cost,
      'new_balance': newBalance,
    };
  }

  // ===================== SETTINGS OPERATIONS =====================

  /// Toggle offline mode
  static Future<void> toggleOfflineMode(bool enabled) async {
    await LocalStorageService.setOfflineMode(enabled);
  }

  /// Get app settings
  static Future<Map<String, dynamic>> getAppSettings() async {
    return {
      'backend_enabled': isBackendEnabled,
      'offline_mode': LocalStorageService.isOfflineMode,
      'is_logged_in': LocalStorageService.isLoggedIn,
      'username': LocalStorageService.username,
      'last_sync': LocalStorageService.lastSync?.toIso8601String(),
      'storage_stats': LocalStorageService.getStorageStats(),
    };
  }

  /// Clear all data (for logout/reset)
  static Future<void> clearAllData() async {
    await LocalStorageService.clearAllData();
  }

  // ===================== PRIVATE HELPER METHODS =====================

  static Future<void> _updateWorkoutStreak() async {
    final user = LocalStorageService.getCurrentUser();
    if (user != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastWorkout = user.lastWorkoutDate;
      
      print('STREAK UPDATE: Current streak before update: ${user.workoutStreak}');
      print('STREAK UPDATE: Last workout date: $lastWorkout');
      print('STREAK UPDATE: Today: $today');
      
      if (lastWorkout != null) {
        final lastWorkoutDay = DateTime(lastWorkout.year, lastWorkout.month, lastWorkout.day);
        final daysDiff = today.difference(lastWorkoutDay).inDays;
        print('STREAK UPDATE: Days difference: $daysDiff');

        if (daysDiff == 0) {
          // Same day - ensure streak is at least 1
          if (user.workoutStreak == 0) {
            user.workoutStreak = 1;
            print('STREAK UPDATE: Same day, set streak to 1 (was 0)');
          } else {
            print('STREAK UPDATE: Same day, keeping existing streak: ${user.workoutStreak}');
          }
          // If already has a streak, don't change it (multiple workouts same day)
        } else if (daysDiff == 1) {
          // Consecutive day - increment streak
          user.workoutStreak += 1;
          print('STREAK UPDATE: Consecutive day, incremented streak to: ${user.workoutStreak}');
        } else {
          // Streak broken (more than 1 day gap) - reset to 1 (starting fresh today)
          user.workoutStreak = 1;
          print('STREAK UPDATE: Streak broken (${daysDiff} days gap), reset to 1');
        }
      } else {
        // First workout ever
        user.workoutStreak = 1;
        print('STREAK UPDATE: First workout ever, set streak to 1');
      }

      user.lastWorkoutDate = now;
      await LocalStorageService.saveUser(user);
    }
  }

  static Future<Map<String, dynamic>> _awardTokensForWorkout() async {
    final rewards = <Map<String, dynamic>>[];
    int totalTokens = 0;

    // Award 10 tokens for completing a workout
    const tokensForWorkout = 10;
    await LocalStorageService.addTokens(tokensForWorkout);
    totalTokens += tokensForWorkout;
    rewards.add({
      'type': 'workout_completion',
      'tokens': tokensForWorkout,
      'message': 'Workout completed!',
    });

    // Get current stats for bonus calculations
    final streak = await getWorkoutStreak();
    final allWorkouts = LocalStorageService.getAllWorkouts();
    final totalWorkoutCount = allWorkouts.length;

    // Bonus tokens for streak milestones
    if (streak == 3) {
      const bonusTokens = 25;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'streak_milestone',
        'tokens': bonusTokens,
        'message': '3-day streak bonus!',
      });
    } else if (streak == 7) {
      const bonusTokens = 50;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'streak_milestone',
        'tokens': bonusTokens,
        'message': 'Weekly streak bonus!',
      });
    } else if (streak == 30) {
      const bonusTokens = 200;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'streak_milestone',
        'tokens': bonusTokens,
        'message': 'Monthly streak bonus!',
      });
    }

    // Bonus tokens for workout count milestones
    if (totalWorkoutCount == 1) {
      const bonusTokens = 20;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'achievement',
        'tokens': bonusTokens,
        'message': 'First workout completed!',
      });
    } else if (totalWorkoutCount == 10) {
      const bonusTokens = 50;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'achievement',
        'tokens': bonusTokens,
        'message': '10 workouts milestone!',
      });
    } else if (totalWorkoutCount == 50) {
      const bonusTokens = 150;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'achievement',
        'tokens': bonusTokens,
        'message': '50 workouts milestone!',
      });
    }

    // Extra tokens for longer workouts (over 45 minutes)
    final lastWorkout = allWorkouts.last;
    if (lastWorkout.duration > 45) {
      const bonusTokens = 5;
      await LocalStorageService.addTokens(bonusTokens);
      totalTokens += bonusTokens;
      rewards.add({
        'type': 'duration_bonus',
        'tokens': bonusTokens,
        'message': 'Long workout bonus!',
      });
    }

    return {
      'total_tokens_awarded': totalTokens,
      'rewards': rewards,
      'new_token_balance': await getUserTokens(),
    };
  }

  // Helper method to get user achievements
  static Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      final workouts = LocalStorageService.getAllWorkouts();
      // final user = LocalStorageService.getCurrentUser(); // Unused for now
      final streakDetails = await getStreakDetails();
      final currentStreak = streakDetails['current_streak'] ?? 0;
      final longestStreak = streakDetails['longest_streak'] ?? 0;
      
      List<Map<String, dynamic>> achievements = [];
      
      // First workout achievement
      achievements.add({
        'id': 'first_workout',
        'title': 'First Steps',
        'description': 'Complete your first workout',
        'icon': '🎯',
        'isUnlocked': workouts.isNotEmpty,
        'current': workouts.isEmpty ? 0 : 1,
        'requirement': 1,
      });
      
      // Workout count achievements
      final workoutMilestones = [10, 25, 50, 100];
      for (int milestone in workoutMilestones) {
        achievements.add({
          'id': 'workouts_$milestone',
          'title': '$milestone Workouts',
          'description': 'Complete $milestone total workouts',
          'icon': milestone <= 25 ? '💪' : milestone <= 50 ? '🏋️' : '🏆',
          'isUnlocked': workouts.length >= milestone,
          'current': workouts.length,
          'requirement': milestone,
        });
      }
      
      // Streak achievements
      final streakMilestones = [3, 7, 14, 30];
      for (int milestone in streakMilestones) {
        achievements.add({
          'id': 'streak_$milestone',
          'title': '$milestone Day Streak',
          'description': 'Maintain a $milestone day workout streak',
          'icon': milestone <= 7 ? '🔥' : milestone <= 14 ? '⚡' : '🌟',
          'isUnlocked': longestStreak >= milestone,
          'current': currentStreak,
          'requirement': milestone,
        });
      }
      
      // Long workout achievement
      final longWorkouts = workouts.where((w) => w.duration >= 45).length;
      achievements.add({
        'id': 'long_workouts',
        'title': 'Endurance Master',
        'description': 'Complete 10 workouts of 45+ minutes',
        'icon': '⏰',
        'isUnlocked': longWorkouts >= 10,
        'current': longWorkouts,
        'requirement': 10,
      });
      
      return achievements;
    } catch (e) {
      print('Error getting achievements: $e');
      return [];
    }
  }

  // ===================== DATA SYNCHRONIZATION =====================

  /// Full data synchronization between local and backend
  static Future<Map<String, dynamic>> synchronizeData({bool force = false}) async {
    if (!isBackendEnabled || LocalStorageService.isOfflineMode) {
      return {
        'success': false,
        'message': 'Backend disabled or in offline mode',
        'workouts_synced': 0,
        'profile_synced': false,
      };
    }

    try {
      print('DataService: Starting data synchronization...');
      
      final lastSync = LocalStorageService.lastSync;
      final now = DateTime.now();
      
      // Skip if recently synced (within 5 minutes) unless forced
      if (!force && lastSync != null && now.difference(lastSync).inMinutes < 5) {
        print('DataService: Skipping sync - recently synchronized');
        return {
          'success': true,
          'message': 'Already synchronized recently',
          'workouts_synced': 0,
          'profile_synced': false,
        };
      }

      final results = await Future.wait([
        _syncWorkoutData(),
        _syncUserProfile(),
      ]);

      final workoutSyncResult = results[0];
      final profileSyncResult = results[1];

      // Update last sync timestamp
      await LocalStorageService.setLastSync(now);

      return {
        'success': true,
        'message': 'Synchronization completed',
        'workouts_synced': workoutSyncResult['synced_count'] ?? 0,
        'profile_synced': profileSyncResult['success'] ?? false,
        'last_sync': now.toIso8601String(),
      };

    } catch (e) {
      print('DataService: Sync error: $e');
      return {
        'success': false,
        'message': 'Sync failed: $e',
        'workouts_synced': 0,
        'profile_synced': false,
      };
    }
  }

  /// Sync workout data between local and backend
  static Future<Map<String, dynamic>> _syncWorkoutData() async {
    int syncedCount = 0;
    
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final token = LocalStorageService.userToken;
      
      if (baseUrl.isEmpty || token == null) {
        throw Exception('Missing backend URL or authentication token');
      }

      // 1. Upload local workouts that aren't synced to backend
      final localWorkouts = LocalStorageService.getAllWorkouts();
      final localOnlyWorkouts = localWorkouts.where((w) => !w.isSynced).toList();
      
      print('DataService: Uploading ${localOnlyWorkouts.length} local workouts to backend');
      
      for (final workout in localOnlyWorkouts) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/api/v1/workouts'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'exerciseName': workout.name,
              'workoutType': workout.category.toLowerCase(),
              'duration': workout.duration,
              'caloriesBurned': workout.calories,
              'date': workout.date.toIso8601String(),
              'sets': workout.exercises.isNotEmpty ? workout.exercises.first.sets : 1,
              'reps': workout.exercises.isNotEmpty ? workout.exercises.first.reps : 1,
              'weight': workout.exercises.isNotEmpty ? workout.exercises.first.weight : null,
              'intensityLevel': _determineIntensityLevel(workout.calories, workout.duration),
              'notes': workout.notes,
            }),
          );

          if (response.statusCode == 201) {
            // Mark as synced locally
            final updatedWorkout = workout.copyWith(isSynced: true);
            await LocalStorageService.saveWorkout(updatedWorkout);
            syncedCount++;
            print('DataService: Uploaded workout: ${workout.name}');
          } else {
            print('DataService: Failed to upload workout ${workout.name}: ${response.statusCode}');
          }
        } catch (e) {
          print('DataService: Error uploading workout ${workout.name}: $e');
        }
      }

      // 2. Download new workouts from backend
      final lastSync = LocalStorageService.lastSync;
      String url = '$baseUrl/api/v1/workouts?limit=100&sortBy=date&sortOrder=desc';
      
      if (lastSync != null) {
        final lastSyncDate = lastSync.toIso8601String().split('T')[0];
        url += '&startDate=$lastSyncDate';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> backendWorkouts = responseData['data']['workouts'] ?? [];
          
          print('DataService: Downloaded ${backendWorkouts.length} workouts from backend');
          
          for (final backendWorkout in backendWorkouts) {
            try {
              // Convert backend workout to local format
              final localWorkout = LocalWorkout(
                id: backendWorkout['_id'] ?? _uuid.v4(),
                name: backendWorkout['exerciseName'] ?? 'Unknown',
                description: backendWorkout['notes'] ?? '',
                duration: backendWorkout['duration'] ?? 0,
                calories: backendWorkout['caloriesBurned'] ?? 0,
                category: _capitalizeFirst(backendWorkout['workoutType'] ?? 'other'),
                date: DateTime.parse(backendWorkout['date'] ?? DateTime.now().toIso8601String()),
                exercises: [
                  LocalExercise(
                    name: backendWorkout['exerciseName'] ?? 'Exercise',
                    sets: backendWorkout['sets'] ?? 1,
                    reps: backendWorkout['reps'] ?? 1,
                    weight: backendWorkout['weight']?.toDouble(),
                  )
                ],
                isCompleted: true,
                notes: backendWorkout['notes'],
                isSynced: true, // Mark as synced since it came from backend
              );

              // Check if workout already exists locally
              final existingWorkout = LocalStorageService.getWorkout(localWorkout.id);
              if (existingWorkout == null) {
                await LocalStorageService.saveWorkout(localWorkout);
                print('DataService: Saved new workout from backend: ${localWorkout.name}');
              }
            } catch (e) {
              print('DataService: Error processing backend workout: $e');
            }
          }
        }
      }

      return {
        'success': true,
        'synced_count': syncedCount,
      };

    } catch (e) {
      print('DataService: Workout sync error: $e');
      return {
        'success': false,
        'synced_count': syncedCount,
        'error': e.toString(),
      };
    }
  }

  /// Sync user profile data
  static Future<Map<String, dynamic>> _syncUserProfile() async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final token = LocalStorageService.userToken;
      
      if (baseUrl.isEmpty || token == null) {
        throw Exception('Missing backend URL or authentication token');
      }

      // Get local user data
      final currentUser = LocalStorageService.getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'error': 'No local user data'};
      }

      // 1. Upload local profile changes to backend (if needed)
      // This would require tracking which profile fields have changed
      
      // 2. Download latest profile from backend
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/auth_user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final backendProfile = responseData['user'];
          
          // Update local profile with backend data
          await saveUserProfile(
            username: backendProfile['username'] ?? currentUser.username,
            email: backendProfile['email'] ?? '',
            preferences: {
              'fullName': backendProfile['fullName'] ?? '',
              'age': backendProfile['age'],
              'height': backendProfile['height'],
              'weight': backendProfile['weight'],
              'bmi': backendProfile['bmi'],
              'bmiCategory': backendProfile['bmiCategory'],
            },
          );
          
          print('DataService: Profile synced successfully');
          return {'success': true};
        }
      }

      return {'success': false, 'error': 'Failed to fetch profile from backend'};

    } catch (e) {
      print('DataService: Profile sync error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Helper method to determine workout intensity
  static String _determineIntensityLevel(int calories, int duration) {
    if (duration == 0) return 'low';
    final caloriesPerMinute = calories / duration;
    
    if (caloriesPerMinute >= 10) return 'high';
    if (caloriesPerMinute >= 6) return 'moderate';
    return 'low';
  }

  /// Helper method to capitalize first letter
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Background sync method (call periodically or on app resume)
  static Future<void> backgroundSync() async {
    if (!isBackendEnabled || LocalStorageService.isOfflineMode) return;
    
    try {
      print('DataService: Running background sync...');
      final result = await synchronizeData();
      print('DataService: Background sync completed: ${result['message']}');
    } catch (e) {
      print('DataService: Background sync failed: $e');
    }
  }

  /// Manual sync trigger for UI
  static Future<Map<String, dynamic>> manualSync() async {
    return await synchronizeData(force: true);
  }

  /// Get workout unlock status for progression system
  static Future<Map<String, dynamic>> getWorkoutUnlockStatus() async {
    try {
      final allWorkouts = LocalStorageService.getAllWorkouts();
      final streakDetails = await getStreakDetails();
      final currentStreak = streakDetails['current_streak'] ?? 0;
      final totalWorkouts = allWorkouts.length;

      return {
        'totalWorkouts': totalWorkouts,
        'currentStreak': currentStreak,
        'unlockStatus': {
          'beginner': true, // Always unlocked
          'intermediate': totalWorkouts >= 3,
          'advanced': totalWorkouts >= 10,
          'elite': totalWorkouts >= 20 && currentStreak >= 7,
        },
      };
    } catch (e) {
      print('Error getting unlock status: $e');
      return {
        'totalWorkouts': 0,
        'currentStreak': 0,
        'unlockStatus': {
          'beginner': true,
          'intermediate': false,
          'advanced': false,
          'elite': false,
        },
      };
    }
  }

  /// Add demo workout data for showcase
  static Future<void> addDemoWorkouts() async {
    try {
      final demoWorkouts = [
        {
          'name': 'Morning Walk',
          'description': 'Light cardio exercise',
          'duration': 20,
          'calories': 100,
          'category': 'Cardio',
        },
        {
          'name': 'Push-ups',
          'description': 'Basic strength training',
          'duration': 10,
          'calories': 50,
          'category': 'Strength',
        },
        {
          'name': 'Yoga Stretching',
          'description': 'Flexibility and relaxation',
          'duration': 15,
          'calories': 75,
          'category': 'Flexibility',
        },
      ];

      print('Adding demo workouts for showcase...');
      for (final workout in demoWorkouts) {
        await logWorkout(
          name: workout['name'] as String,
          description: workout['description'] as String,
          duration: workout['duration'] as int,
          calories: workout['calories'] as int,
          category: workout['category'] as String,
        );
      }
      print('Demo workouts added successfully');
    } catch (e) {
      print('Error adding demo workouts: $e');
    }
  }
}