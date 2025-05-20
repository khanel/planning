import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart'; // Keep Task entity for EisenhowerCategory
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart'; // Import PrioritizationBloc
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_quadrants_widget.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/prioritized_task_list_widget.dart';

class EisenhowerMatrixScreen extends StatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  State<EisenhowerMatrixScreen> createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
  @override
  void initState() {
    super.initState();
    // Load prioritized tasks when the screen initializes
    context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eisenhower Matrix')),
      body: BlocBuilder<PrioritizationBloc, PrioritizationState>(
        builder: (context, state) {
          if (state is PrioritizationLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrioritizationLoadSuccess) {
            // Updated state check
            // Group tasks by Eisenhower category
            final Map<EisenhowerCategory, List<Task>> categorizedTasks = {
              for (var category in EisenhowerCategory.values)
                category:
                    state
                        .tasks // Use tasks from PrioritizationLoadSuccess state
                        .where((task) => task.eisenhowerCategory == category)
                        .toList(),
            };

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
                    tasks:
                        state
                            .tasks, // Use tasks from PrioritizationLoadSuccess state
                  ), // Display all tasks here
                ),
              ],
            );
          } else if (state is PrioritizationLoadFailure) {
            // Updated state check
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          } else if (state is PrioritizationInitial) {
            // Updated state check
            context.read<PrioritizationBloc>().add(
              const LoadPrioritizedTasks(),
            ); // Updated bloc and event
            return const Center(child: CircularProgressIndicator());
          }
          // Removed the TaskDeleteSuccess || TaskSaveSuccess branch
          return const Center(child: Text('Something went wrong!'));
        },
      ),
    );
  }
}
