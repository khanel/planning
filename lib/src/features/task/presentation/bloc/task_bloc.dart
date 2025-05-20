import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart'
    show EisenhowerCategory;
import '../../domain/usecases/get_tasks.dart'; // Import GetTasks from the task feature
import '../../domain/usecases/save_task.dart';
import '../../domain/usecases/delete_task.dart' as delete_task_usecase;
import '../../domain/entities/task.dart'; // Import the correct Task entity

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasks getTasks;
  final SaveTask saveTask;
  final delete_task_usecase.DeleteTask deleteTask;

  TaskBloc(
      {required this.getTasks,
      required this.saveTask,
      required this.deleteTask})
      : super(const TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ChangeTaskPriority>(_onChangeTaskPriority);
  }

  Future<void> _onLoadTasks(
    LoadTasks event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskLoadInProgress());
    final result = await getTasks(NoParams());

    result.fold(
      (failure) => emit(TaskLoadFailure(message: failure.toString())),
      (tasks) => emit(TaskLoadSuccess(tasks: tasks, currentFilter: null)),
    );
  }

  Future<void> _onAddTask(
    AddTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskSaveInProgress()); // Use a generic save state for now
    final result = await saveTask(SaveTaskParams(task: event.task));

    result.fold(
      (failure) => emit(TaskSaveFailure(
          message: failure.toString())), // Use a generic save state for now
      (_) => emit(const TaskSaveSuccess()), // Use a generic save state for now
    );
  }

  Future<void> _onUpdateTask(
    UpdateTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskSaveInProgress()); // Use a generic save state for now
    final result = await saveTask(SaveTaskParams(task: event.task));

    result.fold(
      (failure) => emit(TaskSaveFailure(
          message: failure.toString())), // Use a generic save state for now
      (_) => emit(const TaskSaveSuccess()), // Use a generic save state for now
    );
  }

  Future<void> _onDeleteTask(
    DeleteTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskDeleteInProgress());
    final result = await deleteTask(
        delete_task_usecase.DeleteTaskParams(id: event.taskId));
    result.fold(
      (failure) => emit(TaskDeleteFailure(message: failure.toString())),
      (_) => emit(const TaskDeleteSuccess()),
    );
  }

  Future<void> _onChangeTaskPriority(
    ChangeTaskPriority event,
    Emitter<TaskState> emit,
  ) async {
    emit(const TaskSaveInProgress());
    final updatedTask = Task(
      id: event.task.id,
      name: event.task.name,
      description: event.task.description,
      dueDate: event.task.dueDate,
      completed: event.task.completed,
      importance: event.task.importance,
      createdAt: event.task.createdAt,
      updatedAt: DateTime.now(),
      priority: event.newPriority,
    );
    final result = await saveTask(SaveTaskParams(task: updatedTask));
    result.fold(
      (failure) => emit(TaskSaveFailure(message: failure.toString())),
      (_) => emit(const TaskSaveSuccess()),
    );
  }
}
