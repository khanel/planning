import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Use case for updating an existing calendar event
class UpdateEvent implements UseCase<CalendarEvent, UpdateEventParams> {
  final CalendarRepository repository;

  UpdateEvent({required this.repository});

  @override
  Future<Either<Failure, CalendarEvent>> call(UpdateEventParams params) async {
    // Validate event parameters
    final validationResult = _validateEvent(params.event);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Validate calendar ID
    if (params.calendarId.trim().isEmpty) {
      return const Left(ValidationFailure('Calendar ID cannot be empty'));
    }

    // Create updated event with trimmed title
    final updatedEvent = CalendarEvent(
      id: params.event.id,
      title: params.event.title.trim(),
      description: params.event.description,
      startTime: params.event.startTime,
      endTime: params.event.endTime,
      isAllDay: params.event.isAllDay,
      calendarId: params.event.calendarId,
      googleEventId: params.event.googleEventId,
    );

    return await repository.updateEvent(
      event: updatedEvent,
      calendarId: params.calendarId,
    );
  }

  ValidationFailure? _validateEvent(CalendarEvent event) {
    // Check if ID is not empty
    if (event.id.trim().isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }

    // Check if title is not empty after trimming
    if (event.title.trim().isEmpty) {
      return const ValidationFailure('Event title cannot be empty');
    }

    // Check if end time is after start time for non-all-day events
    if (!event.isAllDay && event.endTime.isBefore(event.startTime)) {
      return const ValidationFailure('End time must be after start time');
    }

    return null; // No validation errors
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
