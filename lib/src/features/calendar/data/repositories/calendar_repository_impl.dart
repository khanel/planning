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

  @override
  Future<Either<Failure, List<CalendarEvent>>> getEvents({
    required DateTime timeMin,
    required DateTime timeMax,
    String? calendarId,
    int? maxResults,
  }) async {
    try {
      final events = await datasource.getEvents(
        timeMin: timeMin,
        timeMax: timeMax,
        calendarId: calendarId,
        maxResults: maxResults,
      );
      return Right(events);
    } on AuthException {
      return const Left(AuthFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> createEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    try {
      final createdEvent = await datasource.createEvent(
        event: event,
        calendarId: calendarId,
      );
      return Right(createdEvent);
    } on AuthException {
      return const Left(AuthFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> updateEvent({
    required CalendarEvent event,
    required String calendarId,
  }) async {
    try {
      final updatedEvent = await datasource.updateEvent(
        event: event,
        calendarId: calendarId,
      );
      return Right(updatedEvent);
    } on AuthException {
      return const Left(AuthFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEvent({
    required String eventId,
    required String calendarId,
  }) async {
    try {
      final result = await datasource.deleteEvent(
        eventId: eventId,
        calendarId: calendarId,
      );
      return Right(result);
    } on AuthException {
      return const Left(AuthFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}
