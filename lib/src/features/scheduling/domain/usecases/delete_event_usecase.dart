import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/scheduling_repository.dart';

class DeleteEventUseCase implements UseCase<void, DeleteEventParams> {
  final SchedulingRepository repository;

  DeleteEventUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteEventParams params) async {
    // Validate the event ID before deleting
    final validationResult = _validateEventId(params.eventId);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Trim the event ID
    final trimmedEventId = params.eventId.trim();

    return await repository.deleteEvent(trimmedEventId);
  }

  ValidationFailure? _validateEventId(String eventId) {
    // Check if ID is not empty after trimming
    if (eventId.trim().isEmpty) {
      return const ValidationFailure('Event ID cannot be empty');
    }

    return null; // No validation errors
  }
}

class DeleteEventParams extends Equatable {
  final String eventId;

  const DeleteEventParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
