import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart' as eisenhower;
import 'package:planning/src/features/task/domain/entities/task.dart'; 
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart'; 
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_quadrants_widget.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/prioritized_task_list_widget.dart';
import 'package:planning/src/core/utils/logger.dart';

// Helper extension to safely access map values
extension SafeMapAccess<K, V> on Map<K, V> {
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;
}

class EisenhowerMatrixScreen extends StatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  State<EisenhowerMatrixScreen> createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
  // Track task priority updates during the current session
  final Map<String, eisenhower.EisenhowerCategory> _taskPriorityUpdates = {};

  Map<eisenhower.EisenhowerCategory, List<Task>> _categorizeTasks(PrioritizationLoadSuccess state) {
    final Map<eisenhower.EisenhowerCategory, List<Task>> categorizedTasks = {
      for (var category in eisenhower.EisenhowerCategory.values)
        category: <Task>[]
    };

    // Categorize tasks based on session updates first, then explicit priority, then computed category
    for (var task in state.tasks) {
      // First check if this task has been moved during this session
      if (_taskPriorityUpdates.containsKey(task.id)) {
        categorizedTasks[_taskPriorityUpdates[task.id]!]!.add(task);
      }
      // Then check if task has an explicit priority set
      else if (task.priority != eisenhower.EisenhowerCategory.unprioritized) {
        categorizedTasks[task.priority]!.add(task);
      }
      // Finally use the computed category if it's not unprioritized
      else if (task.eisenhowerCategory != eisenhower.EisenhowerCategory.unprioritized) {
        categorizedTasks[task.eisenhowerCategory]!.add(task);
      }
      // If none of the above, it goes to unprioritized
      else {
        categorizedTasks[eisenhower.EisenhowerCategory.unprioritized]!.add(task);
      }
    }
    return categorizedTasks;
  }
  @override
  void initState() {
    super.initState();
    log.info(
        'EisenhowerMatrixScreen: initState - dispatching LoadPrioritizedTasks');
    context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
  }

  @override
  Widget build(BuildContext context) {
    log.fine(
        'EisenhowerMatrixScreen: build called. Current state: ${context.watch<PrioritizationBloc>().state.runtimeType}');
    return Scaffold(
      appBar: AppBar(title: const Text('Eisenhower Matrix')),
      body: BlocBuilder<PrioritizationBloc, PrioritizationState>(
        builder: (context, state) {
          log.fine(
              'EisenhowerMatrixScreen: BlocBuilder building with state: ${state.runtimeType}');
          if (state is PrioritizationLoadInProgress) {
            log.info(
                'EisenhowerMatrixScreen: Displaying CircularProgressIndicator for PrioritizationLoadInProgress');
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrioritizationLoadSuccess) {
            log.info(
                'EisenhowerMatrixScreen: Displaying content for PrioritizationLoadSuccess with ${state.tasks.length} tasks');
            // Group tasks by Eisenhower category - ensure each task only appears in one place
            final Map<eisenhower.EisenhowerCategory, List<Task>> categorizedTasks = _categorizeTasks(state);

            // Log the categorization for debugging
            for (var category in eisenhower.EisenhowerCategory.values) {
              log.fine(
                  'EisenhowerMatrixScreen: ${category.toString().split('.').last} has ${categorizedTasks[category]?.length} tasks');
            }
            log.fine('EisenhowerMatrixScreen: Tasks categorized for display');

            // Display the matrix quadrants at the top and tasks at the bottom
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2, // Allocate more space to quadrants
                  child: EisenhowerQuadrantsWidget(
                    categorizedTasks: categorizedTasks,
                    onTaskDropped: (task, newCategory) {
                      log.info(
                          'EisenhowerMatrixScreen: Task ${task.name} dropped to ${newCategory.toString().split('.').last}');

                      // Store the update in our local tracking map
                      setState(() {
                        _taskPriorityUpdates[task.id] = newCategory;
                      });

                      // Trigger a reload of tasks to reflect the change
                      context
                          .read<PrioritizationBloc>()
                          .add(const LoadPrioritizedTasks());

                      // TODO: In a real app, we would persist this change to the database
                      // This is a temporary solution until we implement the proper UpdateTask use case
                    },
                  ),
                ),
                // Not Important Axis Label (Below bottom row)

                // Task list at the bottom
                Expanded(
                  flex: 3, // Allocate more space to the task list
                  child: PrioritizedTaskListWidget(
                    tasks: state
                        .tasks, // Use tasks from PrioritizationLoadSuccess state
                  ), // Display all tasks here
                ),
              ],
            );
          } else if (state is PrioritizationLoadFailure) {
            log.warning(
                'EisenhowerMatrixScreen: Displaying error for PrioritizationLoadFailure - ${state.message}');
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          } else if (state is PrioritizationInitial) {
            log.info(
                'EisenhowerMatrixScreen: State is PrioritizationInitial, dispatching LoadPrioritizedTasks again.');
            context.read<PrioritizationBloc>().add(
                  const LoadPrioritizedTasks(),
                );
            return const Center(child: CircularProgressIndicator());
          }
          log.severe(
              'EisenhowerMatrixScreen: Reached unexpected state in BlocBuilder: ${state.runtimeType}');
          return const Center(child: Text('Something went wrong!'));
        },
      ),
    );
  }
}
