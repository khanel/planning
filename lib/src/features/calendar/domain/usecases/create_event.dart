import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/entities/calendar_event.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Use case for creating a new calendar event
class CreateEvent implements UseCase<CalendarEvent, CreateEventParams> {
  final CalendarRepository repository;

  CreateEvent({required this.repository});

  @override
  Future<Either<Failure, CalendarEvent>> call(CreateEventParams params) async {
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
    final eventWithTrimmedTitle = CalendarEvent(
      id: params.event.id,
      title: params.event.title.trim(),
      description: params.event.description,
      startTime: params.event.startTime,
      endTime: params.event.endTime,
      isAllDay: params.event.isAllDay,
      calendarId: params.event.calendarId,
      googleEventId: params.event.googleEventId,
    );

    return await repository.createEvent(
      event: eventWithTrimmedTitle,
      calendarId: params.calendarId,
    );
  }

  ValidationFailure? _validateEvent(CalendarEvent event) {
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
