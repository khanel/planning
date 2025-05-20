part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTaskPriority extends TaskEvent {
  final Task task;
  final EisenhowerCategory newPriority;

  const ChangeTaskPriority({required this.task, required this.newPriority});

  @override
  List<Object?> get props => [task, newPriority];
}

class LoadTasks extends TaskEvent {
  const LoadTasks();
}
class AddTask extends TaskEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}
