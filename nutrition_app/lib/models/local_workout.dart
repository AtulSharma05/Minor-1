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

  @HiveField(10)
  String? userId; // User identification for data isolation

  @HiveField(11)
  bool isSynced; // Track if workout has been synced to backend

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
    this.userId,
    this.isSynced = false,
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
      'userId': userId,
      'isSynced': isSynced,
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
      userId: json['userId'],
      isSynced: json['isSynced'] ?? false,
    );
  }

  // Create a copy of the workout with modified properties
  LocalWorkout copyWith({
    String? id,
    String? name,
    String? description,
    int? duration,
    int? calories,
    String? category,
    DateTime? date,
    List<LocalExercise>? exercises,
    bool? isCompleted,
    String? notes,
    String? userId,
    bool? isSynced,
  }) {
    return LocalWorkout(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
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
