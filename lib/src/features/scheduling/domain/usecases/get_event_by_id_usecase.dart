import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_event.dart';
import '../repositories/scheduling_repository.dart';

/// Use case for retrieving a specific schedule event by its ID
/// 
/// This use case handles the business logic for getting a schedule event
/// by its unique identifier, including validation and error handling.
class GetEventByIdUseCase implements UseCase<ScheduleEvent, GetEventByIdParams> {
  final SchedulingRepository repository;

  const GetEventByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ScheduleEvent>> call(GetEventByIdParams params) async {
    // Validate event ID
    final trimmedEventId = params.eventId.trim();
    if (trimmedEventId.isEmpty) {
      return const Left(ValidationFailure('Event ID cannot be empty'));
    }

    // Delegate to repository
    return await repository.getEventById(trimmedEventId);
  }
}

/// Parameters for the GetEventByIdUseCase
class GetEventByIdParams extends Equatable {
  final String eventId;

  const GetEventByIdParams({required this.eventId});

  @override
  List<Object> get props => [eventId];
}
