import 'package:hive/hive.dart';

part 'local_user.g.dart';

@HiveType(typeId: 2)
class LocalUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? email;

  @HiveField(3)
  int tokens;

  @HiveField(4)
  int totalTokens;

  @HiveField(5)
  int workoutStreak;

  @HiveField(6)
  int longestStreak;

  @HiveField(7)
  DateTime? lastWorkoutDate;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  List<String>? purchasedRewards;

  @HiveField(10)
  Map<String, dynamic>? settings;

  LocalUser({
    required this.id,
    this.username,
    this.email,
    this.tokens = 0,
    this.totalTokens = 0,
    this.workoutStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
    required this.createdAt,
    this.purchasedRewards,
    this.settings,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'tokens': tokens,
      'total_tokens': totalTokens,
      'workout_streak': workoutStreak,
      'longest_streak': longestStreak,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'purchased_rewards': purchasedRewards,
      'settings': settings,
    };
  }

  // Create from JSON
  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      tokens: json['tokens'] ?? 0,
      totalTokens: json['total_tokens'] ?? 0,
      workoutStreak: json['workout_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastWorkoutDate: json['last_workout_date'] != null 
          ? DateTime.parse(json['last_workout_date'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      purchasedRewards: json['purchased_rewards']?.cast<String>(),
      settings: json['settings'],
    );
  }

  // Create a default user
  factory LocalUser.createDefault({String? username, String? email}) {
    return LocalUser(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      email: email,
      createdAt: DateTime.now(),
      purchasedRewards: [],
      settings: {},
    );
  }

  @override
  String toString() {
    return 'LocalUser(id: $id, username: $username, tokens: $tokens, streak: $workoutStreak)';
  }
}
