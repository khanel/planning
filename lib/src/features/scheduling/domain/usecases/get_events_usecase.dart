import 'package:dartz/dartz.dart';

import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';

class GetEventsUseCase implements UseCase<List<ScheduleEvent>, NoParams> {
  final SchedulingRepository repository;

  GetEventsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScheduleEvent>>> call(NoParams params) async {
    return await repository.getEvents();
  }
}
