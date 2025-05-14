// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnifiedRecordModelAdapter extends TypeAdapter<UnifiedRecordModel> {
  @override
  final int typeId = 0;

  @override
  UnifiedRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnifiedRecordModel(
      id: fields[0] as String,
      type: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      data: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnifiedRecordModel obj) {
    writer
      ..writeByte(5)
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
      other is UnifiedRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
