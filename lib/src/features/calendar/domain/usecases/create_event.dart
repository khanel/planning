import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'shared/calendar_event_validator.dart';

/// Use case for creating a new calendar event
class CreateEvent implements UseCase<CalendarEvent, CreateEventParams> {
  final CalendarRepository repository;

  CreateEvent({required this.repository});

  @override
  Future<Either<Failure, CalendarEvent>> call(CreateEventParams params) async {
    // Validate event parameters
    final eventValidationResult = CalendarEventValidator.validateEvent(params.event);
    if (eventValidationResult != null) {
      return Left(eventValidationResult);
    }

    // Validate calendar ID
    final calendarIdValidationResult = CalendarEventValidator.validateCalendarId(params.calendarId);
    if (calendarIdValidationResult != null) {
      return Left(calendarIdValidationResult);
    }

    // Create normalized event
    final normalizedEvent = CalendarEventValidator.normalizeEvent(params.event);

    return await repository.createEvent(
      event: normalizedEvent,
      calendarId: params.calendarId,
    );
  }
}

/// Parameters for CreateEvent use case
class CreateEventParams extends Equatable {
  final CalendarEvent event;
  final String calendarId;

  const CreateEventParams({
    required this.event,
    required this.calendarId,
  });

  @override
  List<Object?> get props => [event, calendarId];
}
