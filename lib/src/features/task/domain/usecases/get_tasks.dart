import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/domain/repositories/task_repository.dart';

class GetTasks implements UseCase<List<Task>, NoParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}