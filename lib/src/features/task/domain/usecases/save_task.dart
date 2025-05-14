import 'package:dartz/dartz.dart' hide Task;
import 'package:equatable/equatable.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/core/usecases/usecase.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/domain/repositories/task_repository.dart';

class SaveTask implements UseCase<void, SaveTaskParams> {
  final TaskRepository repository;

  SaveTask(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveTaskParams params) async {
    return await repository.saveTask(params.task);
  }
}

class SaveTaskParams extends Equatable {
  final Task task;

  const SaveTaskParams({required this.task});

  @override
  List<Object?> get props => [task];
}