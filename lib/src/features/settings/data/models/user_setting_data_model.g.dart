// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_setting_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingDataModelAdapter extends TypeAdapter<UserSettingDataModel> {
  @override
  final int typeId = 3;

  @override
  UserSettingDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettingDataModel(
      key: fields[0] as String,
      value: fields[1] as dynamic,
      description: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettingDataModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
