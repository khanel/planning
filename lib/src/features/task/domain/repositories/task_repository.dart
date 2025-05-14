import 'package:dartz/dartz.dart' show Either;
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTask(String id);
  Future<Either<Failure, void>> saveTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
}