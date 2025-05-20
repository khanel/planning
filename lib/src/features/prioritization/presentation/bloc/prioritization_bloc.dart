import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart' as eisenhower;
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/domain/usecases/get_tasks.dart';
import 'package:planning/src/core/utils/logger.dart';

part 'prioritization_event.dart';
part 'prioritization_state.dart';

class PrioritizationBloc extends Bloc<PrioritizationEvent, PrioritizationState> {
  final GetTasks getTasks; // Inject the GetTasks use case
  // final log = getLogger('PrioritizationBloc'); // Removed: Use global log instance from logger.dart

  PrioritizationBloc({required this.getTasks}) : super(const PrioritizationInitial()) {
    on<LoadPrioritizedTasks>(_onLoadPrioritizedTasks);
    on<FilterTasks>(_onFilterTasks);
    // Potentially add other event handlers here later if needed for prioritization
    log.fine('PrioritizationBloc initialized'); // Example log
  }

  Future<void> _onFilterTasks(
    FilterTasks event,
    Emitter<PrioritizationState> emit,
  ) async {
    log.info('_onFilterTasks called with category ${event.category}');
    emit(const PrioritizationLoadInProgress()); // Indicate loading state

    final result = await getTasks(NoParams()); // Fetch all tasks

    result.fold(
      (failure) {
        log.severe('Error fetching tasks', failure);
        emit(PrioritizationLoadFailure(message: failure.toString())); // Handle failure
      },
      (allTasks) {
        // Apply the filter
        final filteredTasks = event.category == null
            ? allTasks // Show all tasks if filter is null
            : allTasks
                .where((task) => task.eisenhowerCategory == event.category)
                .toList();

        emit(PrioritizationLoadSuccess(tasks: filteredTasks, currentFilter: event.category)); // Emit success with filtered tasks
        log.fine('Tasks filtered successfully: ${filteredTasks.length} tasks');
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
      (failure) {
        log.severe('Error fetching tasks', failure);
        emit(PrioritizationLoadFailure(message: failure.toString())); // Handle failure
      },
      (allTasks) {
        // Initially load all tasks, filtering will be done by FilterTasks event
        emit(PrioritizationLoadSuccess(tasks: allTasks, currentFilter: null)); // Emit success with all tasks
        log.fine('All tasks loaded successfully: ${allTasks.length} tasks');
      },
    );
  }
}
