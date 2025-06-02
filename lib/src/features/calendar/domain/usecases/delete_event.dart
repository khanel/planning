import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/calendar/domain/repositories/calendar_repository.dart';

/// Use case for deleting a calendar event
class DeleteEvent implements UseCase<bool, DeleteEventParams> {
  final CalendarRepository repository;

  DeleteEvent({required this.repository});

  @override
  Future<Either<Failure, bool>> call(DeleteEventParams params) async {
    // Validate parameters
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Trim IDs
    final trimmedEventId = params.eventId.trim();
    final trimmedCalendarId = params.calendarId.trim();

    return await repository.deleteEvent(
      eventId: trimmedEventId,
      calendarId: trimmedCalendarId,
    );
  }

  ValidationFailure? _validateParams(DeleteEventParams params) {
    // Check if event ID is not empty after trimming
    if (params.eventId.trim().isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }

    // Check if calendar ID is not empty after trimming
    if (params.calendarId.trim().isEmpty) {
      return const ValidationFailure('Calendar ID cannot be empty');
    }

    return null; // No validation errors
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
