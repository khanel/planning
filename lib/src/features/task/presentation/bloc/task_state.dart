part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoadInProgress extends TaskState {
  const TaskLoadInProgress();
}

class TaskLoadSuccess extends TaskState {
  final List<Task> tasks;
  final EisenhowerCategory? currentFilter;

  const TaskLoadSuccess({required this.tasks, this.currentFilter});

  @override
  List<Object?> get props => [tasks, currentFilter];
}

class TaskLoadFailure extends TaskState {
  final String message;

  const TaskLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class TaskSaveInProgress extends TaskState {
  const TaskSaveInProgress();
}

class TaskSaveSuccess extends TaskState {
  const TaskSaveSuccess();
}

class TaskSaveFailure extends TaskState {
  final String message;

  const TaskSaveFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class TaskDeleteInProgress extends TaskState {
  const TaskDeleteInProgress();
}

class TaskDeleteSuccess extends TaskState {
  const TaskDeleteSuccess();
}

class TaskDeleteFailure extends TaskState {
  final String message;

  const TaskDeleteFailure({required this.message});

  @override
  List<Object> get props => [message];
}
