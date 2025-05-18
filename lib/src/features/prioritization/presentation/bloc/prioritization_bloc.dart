import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/features/task/domain/entities/task.dart'; // Import Task entity and EisenhowerCategory
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart'; // Import GetTasks use case

part 'prioritization_event.dart';
part 'prioritization_state.dart';

class PrioritizationBloc extends Bloc<PrioritizationEvent, PrioritizationState> {
  final GetTasks getTasks; // Inject the GetTasks use case

  PrioritizationBloc({required this.getTasks}) : super(const PrioritizationInitial()) {
    on<LoadPrioritizedTasks>(_onLoadPrioritizedTasks);
    on<FilterTasks>(_onFilterTasks);
    // Potentially add other event handlers here later if needed for prioritization
  }

  Future<void> _onFilterTasks(
    FilterTasks event,
    Emitter<PrioritizationState> emit,
  ) async {
    // This bloc will likely need access to ALL tasks to filter them.
    // It could either load them itself using getTasks, or receive them
    // from another bloc (like the TaskBloc) if they are already loaded.
    // For simplicity now, let's assume it loads them itself.
    // A more sophisticated approach might involve listening to the TaskBloc state.

    emit(const PrioritizationLoadInProgress()); // Indicate loading state

    final result = await getTasks(NoParams()); // Fetch all tasks

    result.fold(
      (failure) => emit(PrioritizationLoadFailure(message: failure.toString())), // Handle failure
      (allTasks) {
        // Apply the filter
        final filteredTasks = event.category == null
            ? allTasks // Show all tasks if filter is null
            : allTasks
                .where((task) => task.eisenhowerCategory == event.category)
                .toList();

        emit(PrioritizationLoadSuccess(tasks: filteredTasks, currentFilter: event.category)); // Emit success with filtered tasks
      },
    );
  }

  Future<void> _onLoadPrioritizedTasks(
    LoadPrioritizedTasks event,
    Emitter<PrioritizationState> emit,
  ) async {
    emit(const PrioritizationLoadInProgress()); // Indicate loading state

    final result = await getTasks(NoParams()); // Fetch all tasks

    result.fold(
      (failure) => emit(PrioritizationLoadFailure(message: failure.toString())), // Handle failure
      (allTasks) {
        // Initially load all tasks, filtering will be done by FilterTasks event
        emit(PrioritizationLoadSuccess(tasks: allTasks, currentFilter: null)); // Emit success with all tasks
      },
    );
  }
}
