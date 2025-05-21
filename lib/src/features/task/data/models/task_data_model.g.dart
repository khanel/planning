// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskDataModelAdapter extends TypeAdapter<TaskDataModel> {
  @override
  final int typeId = 2;

  @override
  TaskDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskDataModel(
      id: fields[0] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      name: fields[5] as String,
      description: fields[6] as String,
      dueDate: fields[7] as DateTime?,
      completed: fields[8] as bool,
      importance: fields[9] as TaskImportance,
    );
  }

  @override
  void write(BinaryWriter writer, TaskDataModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.dueDate)
      ..writeByte(8)
      ..write(obj.completed)
      ..writeByte(9)
      ..write(obj.importance)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskImportanceAdapter extends TypeAdapter<TaskImportance> {
  @override
  final int typeId = 1;

  @override
  TaskImportance read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskImportance.veryLow;
      case 1:
        return TaskImportance.low;
      case 2:
        return TaskImportance.medium;
      case 3:
        return TaskImportance.high;
      case 4:
        return TaskImportance.veryHigh;
      default:
        return TaskImportance.veryLow;
    }
  }

  @override
  void write(BinaryWriter writer, TaskImportance obj) {
    switch (obj) {
      case TaskImportance.veryLow:
        writer.writeByte(0);
        break;
      case TaskImportance.low:
        writer.writeByte(1);
        break;
      case TaskImportance.medium:
        writer.writeByte(2);
        break;
      case TaskImportance.high:
        writer.writeByte(3);
        break;
      case TaskImportance.veryHigh:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskImportanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
