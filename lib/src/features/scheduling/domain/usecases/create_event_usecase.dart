import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';

/// Use case for creating a new schedule event
/// 
/// This use case handles the business logic for creating schedule events,
/// including validation and coordination with the repository layer.
class CreateEventUseCase implements UseCase<ScheduleEvent, CreateEventParams> {
  final SchedulingRepository repository;

  const CreateEventUseCase(this.repository);

  @override
  Future<Either<Failure, ScheduleEvent>> call(CreateEventParams params) async {
    // Validate the event before creating
    final event = params.event;
    
    // Basic validation using the entity's built-in validation
    if (!event.isValid) {
      return Left(CacheFailure('Invalid event parameters'));
    }
    
    // Delegate to repository for actual creation
    return await repository.createEvent(event);
  }
}

/// Parameters for the CreateEventUseCase
class CreateEventParams extends Equatable {
  final ScheduleEvent event;

  const CreateEventParams({required this.event});

  @override
  List<Object?> get props => [event];
}
