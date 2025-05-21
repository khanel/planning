// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagDataModelAdapter extends TypeAdapter<TagDataModel> {
  @override
  final int typeId = 5;

  @override
  TagDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TagDataModel(
      name: fields[0] as String,
      color: fields[1] as String?,
      description: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TagDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
