part of 'prioritization_bloc.dart';

abstract class PrioritizationEvent extends Equatable {
  const PrioritizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrioritizedTasks extends PrioritizationEvent {
  const LoadPrioritizedTasks();
}

/// Event to filter tasks by Eisenhower category.
class FilterTasks extends PrioritizationEvent {
  final eisenhower.EisenhowerCategory? category;

  const FilterTasks(this.category);

  @override
  List<Object?> get props => [category];
}
