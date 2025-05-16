part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoadInProgress extends TaskState {
  const TaskLoadInProgress();
}

class TaskLoadSuccess extends TaskState {
  final List<Task> tasks;

  const TaskLoadSuccess({required this.tasks});

  @override
  List<Object> get props => [tasks];
}

class TaskLoadFailure extends TaskState {
  final String message;

  const TaskLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// TODO: Add other task-related states like TaskAddSuccess, TaskUpdateSuccess, TaskDeleteSuccess, etc.
