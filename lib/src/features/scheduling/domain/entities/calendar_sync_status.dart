import 'package:hive/hive.dart';

part 'calendar_sync_status.g.dart';

/// Enum representing the synchronization status with Google Calendar
@HiveType(typeId: 4)
enum CalendarSyncStatus {
  /// The event is not synced with Google Calendar
  @HiveField(0)
  notSynced,
  
  /// The event is currently being synced
  @HiveField(1)
  syncing,
  
  /// The event is successfully synced with Google Calendar
  @HiveField(2)
  synced,
  
  /// There is a conflict between local and remote versions
  @HiveField(3)
  conflict,
  
  /// Synchronization failed
  @HiveField(4)
  failed,
}
