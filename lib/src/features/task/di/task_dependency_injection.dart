import 'package:get_it/get_it.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:planning/src/features/task/data/datasources/task_local_data_source.dart';
import 'package:planning/src/features/task/data/datasources/task_local_data_source_impl.dart';
import 'package:planning/src/features/task/data/repositories/task_repository_impl.dart';
import 'package:planning/src/features/task/domain/repositories/task_repository.dart';
import 'package:planning/src/features/task/domain/usecases/delete_task.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';
import 'package:planning/src/core/di/injection_container.dart'; // Import sl

@module
abstract class TaskDependencyInjection {
  @lazySingleton
  TaskLocalDataSource get taskLocalDataSource => TaskLocalDataSourceImpl(taskBox: sl());

  @lazySingleton
  TaskRepository get taskRepository => TaskRepositoryImpl(localDataSource: sl());

  @lazySingleton
  GetTasks get getTasksUseCase => GetTasks(sl());

  @lazySingleton
  SaveTask get saveTaskUseCase => SaveTask(sl());

  @lazySingleton
  DeleteTask get deleteTaskUseCase => DeleteTask(sl());
}