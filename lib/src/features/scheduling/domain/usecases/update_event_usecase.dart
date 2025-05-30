import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_event.dart';
import '../repositories/scheduling_repository.dart';

class UpdateEventUseCase implements UseCase<ScheduleEvent, UpdateEventParams> {
  final SchedulingRepository repository;

  UpdateEventUseCase(this.repository);

  @override
  Future<Either<Failure, ScheduleEvent>> call(UpdateEventParams params) async {
    // Validate the event before updating
    final validationResult = _validateEvent(params.event);
    if (validationResult != null) {
      return Left(validationResult);
    }

    return await repository.updateEvent(params.event);
  }

  ValidationFailure? _validateEvent(ScheduleEvent event) {
    // Check if ID is not empty
    if (event.id.isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }

    // Check if title is not empty
    if (event.title.trim().isEmpty) {
      return const ValidationFailure('Event title cannot be empty');
    }

    // For non-all-day events, validate time order
    if (!event.isAllDay && event.startTime.isAfter(event.endTime)) {
      return const ValidationFailure('Start time must be before end time');
    }

    return null; // No validation errors
  }
}

class UpdateEventParams {
  final ScheduleEvent event;

  UpdateEventParams({required this.event});
}
