// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalWorkoutAdapter extends TypeAdapter<LocalWorkout> {
  @override
  final int typeId = 0;

  @override
  LocalWorkout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalWorkout(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      duration: fields[3] as int,
      calories: fields[4] as int,
      category: fields[5] as String,
      date: fields[6] as DateTime,
      exercises: (fields[7] as List).cast<LocalExercise>(),
      isCompleted: fields[8] as bool,
      notes: fields[9] as String?,
      userId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalWorkout obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.duration)
      ..writeByte(4)
      ..write(obj.calories)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.exercises)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalWorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalExerciseAdapter extends TypeAdapter<LocalExercise> {
  @override
  final int typeId = 1;

  @override
  LocalExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalExercise(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      weight: fields[3] as double?,
      duration: fields[4] as int?,
      notes: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalExercise obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocalUserAdapter extends TypeAdapter<LocalUser> {
  @override
  final int typeId = 2;

  @override
  LocalUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalUser(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      workoutStreak: fields[3] as int,
      totalTokens: fields[4] as int,
      lastWorkoutDate: fields[5] as DateTime,
      preferences: (fields[6] as Map?)?.cast<String, dynamic>(),
      purchasedRewards: (fields[7] as List?)?.cast<String>(),
      tokens: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LocalUser obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.workoutStreak)
      ..writeByte(4)
      ..write(obj.totalTokens)
      ..writeByte(5)
      ..write(obj.lastWorkoutDate)
      ..writeByte(6)
      ..write(obj.preferences)
      ..writeByte(7)
      ..write(obj.purchasedRewards)
      ..writeByte(8)
      ..write(obj.tokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
