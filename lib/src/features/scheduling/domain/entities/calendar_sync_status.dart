/// Enum representing the synchronization status with Google Calendar
enum CalendarSyncStatus {
  /// The event is not synced with Google Calendar
  notSynced,
  
  /// The event is currently being synced
  syncing,
  
  /// The event is successfully synced with Google Calendar
  synced,
  
  /// There is a conflict between local and remote versions
  conflict,
  
  /// Synchronization failed
  failed,
}
