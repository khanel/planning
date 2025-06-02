import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';
import 'shared/calendar_event_validator.dart';

/// Use case for deleting a calendar event
class DeleteEvent implements UseCase<bool, DeleteEventParams> {
  final CalendarRepository repository;

  DeleteEvent({required this.repository});

  @override
  Future<Either<Failure, bool>> call(DeleteEventParams params) async {
    // Validate event ID
    final eventIdValidationResult = CalendarEventValidator.validateEventId(params.eventId);
    if (eventIdValidationResult != null) {
      return Left(eventIdValidationResult);
    }

    // Validate calendar ID
    final calendarIdValidationResult = CalendarEventValidator.validateCalendarId(params.calendarId);
    if (calendarIdValidationResult != null) {
      return Left(calendarIdValidationResult);
    }

    // Trim IDs
    final trimmedEventId = params.eventId.trim();
    final trimmedCalendarId = params.calendarId.trim();

    return await repository.deleteEvent(
      eventId: trimmedEventId,
      calendarId: trimmedCalendarId,
    );
  }
}

/// Parameters for DeleteEvent use case
class DeleteEventParams extends Equatable {
  final String eventId;
  final String calendarId;

  const DeleteEventParams({
    required this.eventId,
    required this.calendarId,
  });

  @override
  List<Object?> get props => [eventId, calendarId];
}
