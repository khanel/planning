// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_event_data_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleEventDataModelAdapter
    extends TypeAdapter<ScheduleEventDataModel> {
  @override
  final int typeId = 3;

  @override
  ScheduleEventDataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleEventDataModel(
      id: fields[0] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      title: fields[5] as String,
      description: fields[6] as String?,
      startTime: fields[7] as DateTime,
      endTime: fields[8] as DateTime,
      isAllDay: fields[9] as bool,
      googleCalendarId: fields[10] as String?,
      syncStatus: fields[11] as CalendarSyncStatus,
      lastSyncAt: fields[12] as DateTime?,
      linkedTaskId: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleEventDataModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.endTime)
      ..writeByte(9)
      ..write(obj.isAllDay)
      ..writeByte(10)
      ..write(obj.googleCalendarId)
      ..writeByte(11)
      ..write(obj.syncStatus)
      ..writeByte(12)
      ..write(obj.lastSyncAt)
      ..writeByte(13)
      ..write(obj.linkedTaskId)
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
      other is ScheduleEventDataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
