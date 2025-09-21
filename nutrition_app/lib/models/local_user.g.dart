// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      username: fields[1] as String?,
      email: fields[2] as String?,
      tokens: fields[3] as int,
      totalTokens: fields[4] as int,
      workoutStreak: fields[5] as int,
      longestStreak: fields[6] as int,
      lastWorkoutDate: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime,
      purchasedRewards: (fields[9] as List?)?.cast<String>(),
      settings: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalUser obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.tokens)
      ..writeByte(4)
      ..write(obj.totalTokens)
      ..writeByte(5)
      ..write(obj.workoutStreak)
      ..writeByte(6)
      ..write(obj.longestStreak)
      ..writeByte(7)
      ..write(obj.lastWorkoutDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.purchasedRewards)
      ..writeByte(10)
      ..write(obj.settings);
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
