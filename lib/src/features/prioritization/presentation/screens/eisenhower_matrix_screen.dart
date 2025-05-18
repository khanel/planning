import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart'; // Keep Task entity for EisenhowerCategory
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart'; // Import PrioritizationBloc
import 'package:planning/src/features/task/presentation/widgets/task_list_view.dart'; // Keep TaskListView for now

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
          } else if (state is PrioritizationLoadSuccess) { // Updated state check
            // Group tasks by Eisenhower category
            final Map<EisenhowerCategory, List<Task>> categorizedTasks = {
              for (var category in EisenhowerCategory.values)
                category:
                    state.tasks // Use tasks from PrioritizationLoadSuccess state
                            .where(
                              (task) => task.eisenhowerCategory == category,
                            )
                            .toList(),
            };

            // Display the matrix quadrants at the top and tasks at the bottom
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Importance Axis Label (Above top row)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Center(
                    child: Text(
                      'Importance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // Allocate more space to quadrants
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Urgency Axis Label (Left of quadrants)
                      const RotatedBox(
                        quarterTurns: -1,
                        child: Center(
                          child: Text(
                            'Urgency',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Quadrants Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top row: Urgent & Important (Do) and Not Urgent & Important (Decide)
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Urgent & Not Important (Delegate)
                                  Expanded(
                                    child: Card(
                                      margin: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                EisenhowerCategory.delegate
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // You can add a summary or count of tasks here later
                                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delegate] ?? [])), // Optional: display tasks within quadrant
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Urgent & Important (Do)
                                  Expanded(
                                    child: Card(
                                      margin: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                EisenhowerCategory.doIt
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // You can add a summary or count of tasks here later
                                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.doIt] ?? [])), // Optional: display tasks within quadrant
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bottom row: Urgent & Not Important (Delegate) and Not Urgent & Not Important (Delete)
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Not Urgent & Not Important (Delete)
                                  Expanded(
                                    child: Card(
                                      margin: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                EisenhowerCategory.delete
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // You can add a summary or count of tasks here later
                                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delete] ?? [])), // Optional: display tasks within quadrant
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Not Urgent & Important (Decide)
                                  Expanded(
                                    child: Card(
                                      margin: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                EisenhowerCategory.decide
                                                    .toString()
                                                    .split('.')
                                                    .last,
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // You can add a summary or count of tasks here later
                                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.decide] ?? [])), // Optional: display tasks within quadrant
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Not Important Axis Label (Below bottom row)

                // Task list at the bottom
                Expanded(
                  flex: 3, // Allocate more space to the task list
                  child: TaskListView(
                    tasks: state.tasks, // Use tasks from PrioritizationLoadSuccess state
                  ), // Display all tasks here
                ),
              ],
            );
          } else if (state is PrioritizationLoadFailure) { // Updated state check
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          } else if (state is PrioritizationInitial) { // Updated state check
            context.read<PrioritizationBloc>().add(const LoadPrioritizedTasks()); // Updated bloc and event
            return const Center(child: CircularProgressIndicator());
          }
          // Removed the TaskDeleteSuccess || TaskSaveSuccess branch
          return const Center(child: Text('Something went wrong!'));
        },
      ),
    );
  }
}
