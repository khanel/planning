import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/features/task/domain/usecases/save_task.dart';
import 'package:planning/src/core/utils/logger.dart'; // Add logger import

// Events
abstract class PrioritizationEvent extends Equatable {
  const PrioritizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrioritizedTasks extends PrioritizationEvent {
  const LoadPrioritizedTasks();
}

class UpdateTaskPriority extends PrioritizationEvent {
  final Task task;
  final EisenhowerCategory newPriority;

  const UpdateTaskPriority({
    required this.task,
    required this.newPriority,
  });

  @override
  List<Object?> get props => [task, newPriority];
}

class FilterTasks extends PrioritizationEvent {
  final EisenhowerCategory? category;

  const FilterTasks(this.category);

  @override
  List<Object?> get props => [category];
}

// States
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
  final EisenhowerCategory? currentFilter;

  const PrioritizationLoadSuccess({
    required this.tasks,
    required this.currentFilter,
  });

  @override
  List<Object?> get props => [tasks, currentFilter];
}

class PrioritizationLoadFailure extends PrioritizationState {
  final String message;

  const PrioritizationLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class PrioritizationBloc extends Bloc<PrioritizationEvent, PrioritizationState> {
  final GetTasks getTasks;
  final SaveTask saveTask;
  List<Task> _allTasks = [];

  PrioritizationBloc({
    required this.getTasks,
    required this.saveTask,
  }) : super(const PrioritizationInitial()) {
    on<LoadPrioritizedTasks>(_onLoadPrioritizedTasks);
    on<UpdateTaskPriority>(_onUpdateTaskPriority);
    on<FilterTasks>(_onFilterTasks);
    
    // Automatically load tasks when bloc is created
    add(const LoadPrioritizedTasks());
  }

  void _onLoadPrioritizedTasks(
    LoadPrioritizedTasks event,
    Emitter<PrioritizationState> emit,
  ) async {
    log.info('PrioritizationBloc: Loading prioritized tasks');
    emit(const PrioritizationLoadInProgress());
    try {
      // Get tasks from the repository
      final result = await getTasks(NoParams());
      
      result.fold(
        (failure) {
          log.warning('PrioritizationBloc: Failed to load tasks - $failure');
          emit(PrioritizationLoadFailure(message: failure.toString()));
        },
        (tasks) {
          _allTasks = tasks;
          log.info('PrioritizationBloc: Loaded ${tasks.length} tasks');
          // Log task details for debugging
          for (var task in tasks) {
            log.info('Task: ${task.name}, Priority: ${task.priority}');
          }
          emit(PrioritizationLoadSuccess(
            tasks: _allTasks,
            currentFilter: null,
          ));
        },
      );
    } catch (error) {
      log.severe('PrioritizationBloc: Error loading tasks - $error');
      emit(PrioritizationLoadFailure(message: error.toString()));
    }
  }

  void _onUpdateTaskPriority(
    UpdateTaskPriority event,
    Emitter<PrioritizationState> emit,
  ) async {
    try {
      // Update the task's priority
      final updatedTask = event.task.copyWith(
        priority: event.newPriority,
        updatedAt: DateTime.now(),
      );

      // Save to repository
      final result = await saveTask(SaveTaskParams(task: updatedTask));
      
      result.fold(
        (failure) => emit(PrioritizationLoadFailure(message: failure.toString())),
        (_) {
          // Replace the task in the local list
          final taskIndex = _allTasks.indexWhere((t) => t.id == updatedTask.id);
          if (taskIndex != -1) {
            _allTasks[taskIndex] = updatedTask;
          } else {
            _allTasks.add(updatedTask);
          }

          // Re-emit the success state with the updated tasks
          if (state is PrioritizationLoadSuccess) {
            final currentState = state as PrioritizationLoadSuccess;
            emit(PrioritizationLoadSuccess(
              tasks: _getFilteredTasks(_allTasks, currentState.currentFilter),
              currentFilter: currentState.currentFilter,
            ));
          }
        },
      );
    } catch (error) {
      emit(PrioritizationLoadFailure(message: error.toString()));
    }
  }

  void _onFilterTasks(
    FilterTasks event,
    Emitter<PrioritizationState> emit,
  ) {
    if (state is PrioritizationLoadSuccess) {
      emit(PrioritizationLoadSuccess(
        tasks: _getFilteredTasks(_allTasks, event.category),
        currentFilter: event.category,
      ));
    }
  }

  List<Task> _getFilteredTasks(List<Task> tasks, EisenhowerCategory? filter) {
    if (filter == null) {
      return tasks;
    }
    return tasks.where((task) => task.priority == filter).toList();
  }
}
