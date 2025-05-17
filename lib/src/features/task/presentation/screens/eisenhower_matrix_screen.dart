import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'package:planning/src/features/task/presentation/widgets/task_list_view.dart';

class EisenhowerMatrixScreen extends StatefulWidget {
  const EisenhowerMatrixScreen({super.key});

  @override
  State<EisenhowerMatrixScreen> createState() => _EisenhowerMatrixScreenState();
}

class _EisenhowerMatrixScreenState extends State<EisenhowerMatrixScreen> {
  @override
  void initState() {
    super.initState();
    // Load tasks when the screen initializes
    context.read<TaskBloc>().add(const LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eisenhower Matrix')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            // Group tasks by Eisenhower category
            final Map<EisenhowerCategory, List<Task>> categorizedTasks = {
              for (var category in EisenhowerCategory.values)
                category:
                    (state is TaskLoadSuccess)
                        ? state.tasks
                            .where(
                              (task) => task.eisenhowerCategory == category,
                            )
                            .toList()
                        : [],
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
                    tasks: (state is TaskLoadSuccess) ? state.tasks : [],
                  ), // Display all tasks here
                ),
              ],
            );
          } else if (state is TaskLoadFailure) {
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          } else if (state is TaskInitial) {
            context.read<TaskBloc>().add(const LoadTasks());
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskDeleteSuccess || state is TaskSaveSuccess) {
            // After save/delete, reload tasks to update the list
            context.read<TaskBloc>().add(const LoadTasks());
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Something went wrong!'));
        },
      ),
    );
  }
}
