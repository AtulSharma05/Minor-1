import 'package:hive/hive.dart';

part 'local_workout.g.dart';

@HiveType(typeId: 0)
class LocalWorkout extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int duration; // in minutes

  @HiveField(4)
  int calories;

  @HiveField(5)
  String category; // e.g., 'strength', 'cardio', 'flexibility'

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  List<LocalExercise> exercises;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  String? notes;

  LocalWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.calories,
    required this.category,
    required this.date,
    required this.exercises,
    this.isCompleted = false,
    this.notes,
  });

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'calories': calories,
      'category': category,
      'date': date.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  // Create from JSON (for API responses)
  factory LocalWorkout.fromJson(Map<String, dynamic> json) {
    return LocalWorkout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      duration: json['duration'],
      calories: json['calories'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      exercises: (json['exercises'] as List)
          .map((e) => LocalExercise.fromJson(e))
          .toList(),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }
}

@HiveType(typeId: 1)
class LocalExercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int sets;

  @HiveField(2)
  int reps;

  @HiveField(3)
  double? weight; // in kg

  @HiveField(4)
  int? duration; // in seconds (for time-based exercises)

  @HiveField(5)
  String? notes;

  LocalExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'notes': notes,
    };
  }

  factory LocalExercise.fromJson(Map<String, dynamic> json) {
    return LocalExercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      notes: json['notes'],
    );
  }
}

@HiveType(typeId: 2)
class LocalUser extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String email;

  @HiveField(3)
  int workoutStreak;

  @HiveField(4)
  int totalTokens;

  @HiveField(5)
  DateTime lastWorkoutDate;

  @HiveField(6)
  Map<String, dynamic>? preferences;

  @HiveField(7)
  List<String>? purchasedRewards;

  @HiveField(8)
  int tokens; // Current available tokens

  LocalUser({
    required this.id,
    required this.username,
    required this.email,
    this.workoutStreak = 0,
    this.totalTokens = 0,
    required this.lastWorkoutDate,
    this.preferences,
    this.purchasedRewards,
    this.tokens = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'workoutStreak': workoutStreak,
      'totalTokens': totalTokens,
      'lastWorkoutDate': lastWorkoutDate.toIso8601String(),
      'preferences': preferences,
      'purchasedRewards': purchasedRewards,
      'tokens': tokens,
    };
  }

  factory LocalUser.fromJson(Map<String, dynamic> json) {
    return LocalUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      workoutStreak: json['workoutStreak'] ?? 0,
      totalTokens: json['totalTokens'] ?? 0,
      lastWorkoutDate: DateTime.parse(json['lastWorkoutDate']),
      preferences: json['preferences'],
      purchasedRewards: json['purchasedRewards']?.cast<String>(),
      tokens: json['tokens'] ?? 0,
    );
  }
}
