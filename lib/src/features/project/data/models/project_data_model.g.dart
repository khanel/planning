// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectDataModelAdapter extends TypeAdapter<ProjectDataModel> {
  @override
  final int typeId = 4;

  @override
  ProjectDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectDataModel(
      name: fields[0] as String,
      description: fields[1] as String?,
      createdAt: fields[2] as DateTime,
      dueDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectDataModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.dueDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
