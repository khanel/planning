import 'package:dartz/dartz.dart' hide Task; // Assuming dartz is used for Either
import 'package:planning/src/core/errors/failures.dart'; // Assuming a Failure class
import 'package:planning/src/domain/entities/task.dart'; // Assuming a Task entity

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  // TODO: Add other repository methods like saveTask, deleteTask, etc.
}
