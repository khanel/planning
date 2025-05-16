import 'package:dartz/dartz.dart' show Either;
import 'package:planning/src/core/errors/failures.dart'; // Assuming a Failure class
import 'package:planning/src/domain/entities/task.dart'; // Assuming a Task entity
import 'package:planning/src/domain/repositories/task_repository.dart'; // Assuming a TaskRepository interface
import 'package:planning/src/core/usecases/usecase.dart'; // Assuming a UseCase base class

class GetTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
