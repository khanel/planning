import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart'; // Keep Task entity for EisenhowerCategory
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart'; // Import PrioritizationBloc
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_quadrants_widget.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/prioritized_task_list_widget.dart';
import 'package:planning/src/core/utils/logger.dart';

class EisenhowerMatrixScreen extends StatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  State<EisenhowerMatrixScreen> createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
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
            // Group tasks by Eisenhower category
            final Map<EisenhowerCategory, List<Task>> categorizedTasks = {
              for (var category in EisenhowerCategory.values)
                category:
                    state.tasks
                        .where((task) => task.eisenhowerCategory == category)
                        .toList(),
            };
            log.fine('EisenhowerMatrixScreen: Tasks categorized for display');

            // Display the matrix quadrants at the top and tasks at the bottom
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2, // Allocate more space to quadrants
                  child: EisenhowerQuadrantsWidget(
                    categorizedTasks: categorizedTasks,
                  ),
                ),
                // Not Important Axis Label (Below bottom row)

                // Task list at the bottom
                Expanded(
                  flex: 3, // Allocate more space to the task list
                  child: PrioritizedTaskListWidget(
                    tasks: state.tasks, // Use tasks from PrioritizationLoadSuccess state
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
