import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Use case for getting calendar events within a date range
class GetEvents implements UseCase<List<CalendarEvent>, GetEventsParams> {
  final CalendarRepository repository;

  GetEvents({required this.repository});

  @override
  Future<Either<Failure, List<CalendarEvent>>> call(GetEventsParams params) async {
    return await repository.getEvents(
      timeMin: params.timeMin,
      timeMax: params.timeMax,
      calendarId: params.calendarId,
      maxResults: params.maxResults,
    );
  }
}

/// Parameters for GetEvents use case
class GetEventsParams extends Equatable {
  final String? calendarId;
  final DateTime timeMin;
  final DateTime timeMax;
  final int? maxResults;

  const GetEventsParams({
    this.calendarId,
    required this.timeMin,
    required this.timeMax,
    this.maxResults,
  });

  @override
  List<Object?> get props => [calendarId, timeMin, timeMax, maxResults];
}
