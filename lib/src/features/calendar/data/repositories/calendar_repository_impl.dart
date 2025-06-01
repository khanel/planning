import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/calendar/data/datasources/google_calendar_datasource.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Implementation of CalendarRepository using Google Calendar data source
class CalendarRepositoryImpl implements CalendarRepository {
  final GoogleCalendarDatasource datasource;

  CalendarRepositoryImpl({required this.datasource});

  /// Handles exceptions and converts them to appropriate failures
  Either<Failure, T> _handleError<T>(Exception exception) {
    switch (exception.runtimeType) {
      case AuthException:
        return const Left(AuthFailure());
      case NetworkException:
        return const Left(NetworkFailure());
      case ServerException:
        return const Left(ServerFailure());
      default:
        return const Left(UnknownFailure());
    }
  }

  /// Executes a datasource operation and handles exceptions
  Future<Either<Failure, T>> _executeOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      if (e is Exception) {
        return _handleError<T>(e);
      }
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  }) async {
    return _executeOperation(() => datasource.getEvents(
      timeMin: timeMin,
      timeMax: timeMax,
      calendarId: calendarId,
      maxResults: maxResults,
    ));
  }

  @override
  Future<Either<Failure, CalendarEvent>> createEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    return _executeOperation(() => datasource.createEvent(
      event: event,
      calendarId: calendarId,
    ));
  }

  @override
  Future<Either<Failure, CalendarEvent>> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    return _executeOperation(() => datasource.updateEvent(
      event: event,
      calendarId: calendarId,
    ));
  }

  @override
  Future<Either<Failure, bool>> deleteEvent({
    required String eventId,
    required String calendarId,
  }) async {
    return _executeOperation(() => datasource.deleteEvent(
      eventId: eventId,
      calendarId: calendarId,
    ));
  }
}
