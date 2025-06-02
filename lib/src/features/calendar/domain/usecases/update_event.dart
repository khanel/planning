import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'shared/calendar_event_validator.dart';

/// Use case for updating an existing calendar event
class UpdateEvent implements UseCase<CalendarEvent, UpdateEventParams> {
  final CalendarRepository repository;

  UpdateEvent({required this.repository});

  @override
  Future<Either<Failure, CalendarEvent>> call(UpdateEventParams params) async {
    // Validate event parameters (with ID requirement for updates)
    final eventValidationResult = CalendarEventValidator.validateEvent(params.event, requireId: true);
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

    return await repository.updateEvent(
      event: normalizedEvent,
      calendarId: params.calendarId,
    );
  }
}

/// Parameters for UpdateEvent use case
class UpdateEventParams extends Equatable {
  final CalendarEvent event;
  final String calendarId;

  const UpdateEventParams({
    required this.event,
    required this.calendarId,
  });

  @override
  List<Object?> get props => [event, calendarId];
}
