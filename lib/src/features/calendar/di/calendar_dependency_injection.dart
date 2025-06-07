import 'package:injectable/injectable.dart';
import 'package:planning/src/core/di/injection_container.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:planning/src/features/calendar/services/core/calendar_integration_service.dart';
import 'package:planning/src/features/calendar/services/core/session_aware_calendar_service.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_background_sync.dart';
import 'package:planning/src/features/calendar/services/sync/calendar_sync_service.dart';
import 'package:planning/src/core/auth/google_auth_service.dart';

/// Dependency injection module for calendar feature
/// 
/// This module follows the established architectural pattern used in other features,
/// providing proper separation of concerns and testability.
/// 
/// Architecture layers:
/// - Services (high-level application services)
/// - Repositories (domain layer contracts)
/// - Datasources (data layer implementations)
/// 
/// Refactored during TDD REFACTOR phase to improve code organization.
@module
abstract class CalendarDependencyInjection {
  /// Google Calendar datasource implementation
  /// 
  /// Note: This requires a CalendarApi instance which should be provided
  /// by the authentication layer when creating calendar services.
  GoogleCalendarDatasource googleCalendarDatasource(/* CalendarApi calendarApi */) =>
      throw UnimplementedError('CalendarApi must be provided by auth layer');

  /// Calendar repository implementation
  @lazySingleton
  CalendarRepository calendarRepository(GoogleCalendarDatasource datasource) =>
      CalendarRepositoryImpl(datasource: datasource);

  /// Calendar integration service factory
  /// 
  /// This service bridges authentication and calendar operations.
  /// It should be created when an authenticated CalendarApi is available.
  CalendarIntegrationService calendarIntegrationService(CalendarRepository repository) =>
      CalendarIntegrationService(repository: repository);

  /// Session-aware calendar service
  /// 
  /// Manages authentication state and provides calendar operations
  /// with automatic session management.
  @lazySingleton
  SessionAwareCalendarService sessionAwareCalendarService() =>
      SessionAwareCalendarService(authService: sl<GoogleAuthService>());

  /// Calendar sync service
  /// 
  /// Provides OAuth authentication, token management, and calendar
  /// synchronization capabilities with Google Calendar API.
  @lazySingleton
  CalendarSyncService calendarSyncService() =>
      CalendarSyncService.withAuthService(authService: sl<GoogleAuthService>());

  /// Calendar background sync service
  /// 
  /// Manages background synchronization of calendar events using WorkManager.
  /// Requires CalendarSyncService for executing sync operations.
  @lazySingleton
  CalendarBackgroundSync calendarBackgroundSync() =>
      CalendarBackgroundSync(syncService: sl<CalendarSyncService>());
}