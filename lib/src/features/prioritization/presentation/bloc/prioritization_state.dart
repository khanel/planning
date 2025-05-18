part of 'prioritization_bloc.dart';

abstract class PrioritizationState extends Equatable {
  const PrioritizationState();

  @override
  List<Object?> get props => [];
}

class PrioritizationInitial extends PrioritizationState {
  const PrioritizationInitial();
}

class PrioritizationLoadInProgress extends PrioritizationState {
  const PrioritizationLoadInProgress();
}

class PrioritizationLoadSuccess extends PrioritizationState {
  final List<Task> tasks;
  final EisenhowerCategory? currentFilter; // Keep track of the active filter

  const PrioritizationLoadSuccess({required this.tasks, this.currentFilter});

  @override
  List<Object?> get props => [tasks, currentFilter];
}

class PrioritizationLoadFailure extends PrioritizationState {
  final String message;

  const PrioritizationLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}
