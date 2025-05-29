// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_sync_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalendarSyncStatusAdapter extends TypeAdapter<CalendarSyncStatus> {
  @override
  final int typeId = 4;

  @override
  CalendarSyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CalendarSyncStatus.notSynced;
      case 1:
        return CalendarSyncStatus.syncing;
      case 2:
        return CalendarSyncStatus.synced;
      case 3:
        return CalendarSyncStatus.conflict;
      case 4:
        return CalendarSyncStatus.failed;
      default:
        return CalendarSyncStatus.notSynced;
    }
  }

  @override
  void write(BinaryWriter writer, CalendarSyncStatus obj) {
    switch (obj) {
      case CalendarSyncStatus.notSynced:
        writer.writeByte(0);
        break;
      case CalendarSyncStatus.syncing:
        writer.writeByte(1);
        break;
      case CalendarSyncStatus.synced:
        writer.writeByte(2);
        break;
      case CalendarSyncStatus.conflict:
        writer.writeByte(3);
        break;
      case CalendarSyncStatus.failed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarSyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
