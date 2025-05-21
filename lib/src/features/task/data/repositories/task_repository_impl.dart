import 'package:dartz/dartz.dart' show Either, Left, Right;
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/data/models/unified_record_model.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart' as eisenhower;
import 'package:planning/src/features/task/data/datasources/task_local_data_source.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final taskRecords = await localDataSource.getTasks();
      final tasks = taskRecords.map(_fromDataModel).toList();
      return Right(tasks);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Task>> getTask(String id) async {
    try {
      final taskRecord = await localDataSource.getTask(id);
      final task = _fromDataModel(taskRecord);
      return Right(task);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveTask(Task task) async {
    try {
      final taskRecord = _toDataModel(task);
      await localDataSource.saveTask(taskRecord);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await localDataSource.deleteTask(id);
      return Right(null);
    } on CacheException {
      return Left(CacheFailure());
    }
  }

  Task _fromDataModel(UnifiedRecordModel model) {
    // Assuming the data field contains the TaskDataModel
    final taskDataModel = TaskDataModel.fromMap(model.data); // Need a fromMap constructor in TaskDataModel
    return Task(
      id: model.id,
      name: taskDataModel.name,
      description: taskDataModel.description,
      dueDate: taskDataModel.dueDate,
      completed: taskDataModel.completed,
      importance: taskDataModel.importance,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      priority: taskDataModel.priority,
    );
  }

  UnifiedRecordModel _toDataModel(Task task) {
    final taskDataModel = TaskDataModel(
      id: task.id,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      name: task.name,
      description: task.description,
      dueDate: task.dueDate,
      completed: task.completed,
      importance: task.importance,
      priority: task.priority is eisenhower.EisenhowerCategory 
          ? task.priority as eisenhower.EisenhowerCategory 
          : eisenhower.EisenhowerCategory.unprioritized,
    );
    return UnifiedRecordModel(
      id: task.id,
      type: 'task',
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      data: taskDataModel.toMap(), // Need a toMap method in TaskDataModel
    );
  }
}