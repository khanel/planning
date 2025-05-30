import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';

/// Repository interface for managing schedule events
/// 
/// This abstract class defines the contract for data access operations
/// related to schedule events, including CRUD operations and filtering.
abstract class SchedulingRepository {
  /// Creates a new schedule event
  /// 
  /// Returns [Right(ScheduleEvent)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, ScheduleEvent>> createEvent(ScheduleEvent event);

  /// Retrieves all schedule events
  /// 
  /// Returns [Right(List<ScheduleEvent>)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, List<ScheduleEvent>>> getEvents();

  /// Retrieves a specific schedule event by its ID
  /// 
  /// Returns [Right(ScheduleEvent)] if found,
  /// [Left(Failure)] if not found or operation fails
  Future<Either<Failure, ScheduleEvent>> getEventById(String id);

  /// Updates an existing schedule event
  /// 
  /// Returns [Right(ScheduleEvent)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, ScheduleEvent>> updateEvent(ScheduleEvent event);

  /// Deletes a schedule event by its ID
  /// 
  /// Returns [Right(void)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, void>> deleteEvent(String id);

  /// Retrieves schedule events within a specific date range
  /// 
  /// [startDate] and [endDate] define the inclusive date range
  /// Returns [Right(List<ScheduleEvent>)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, List<ScheduleEvent>>> getEventsByDateRange(
    DateTime startDate, 
    DateTime endDate,
  );

  /// Retrieves schedule events linked to a specific task
  /// 
  /// Returns [Right(List<ScheduleEvent>)] if successful,
  /// [Left(Failure)] if the operation fails
  Future<Either<Failure, List<ScheduleEvent>>> getEventsByTaskId(String taskId);
}
