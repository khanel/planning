import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';

/// Use case for retrieving schedule events linked to a specific task
/// 
/// This use case handles the business logic for getting events that are
/// associated with a specific task ID, including validation and error handling.
class GetEventsByTaskIdUseCase implements UseCase<List<ScheduleEvent>, GetEventsByTaskIdParams> {
  final SchedulingRepository repository;

  const GetEventsByTaskIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScheduleEvent>>> call(GetEventsByTaskIdParams params) async {
    // Validate task ID
    final trimmedTaskId = params.taskId.trim();
    if (trimmedTaskId.isEmpty) {
      return const Left(ValidationFailure('Task ID cannot be empty'));
    }

    // Delegate to repository
    return await repository.getEventsByTaskId(trimmedTaskId);
  }
}

/// Parameters for the GetEventsByTaskIdUseCase
class GetEventsByTaskIdParams extends Equatable {
  final String taskId;

  const GetEventsByTaskIdParams({required this.taskId});

  @override
  List<Object> get props => [taskId];
}
