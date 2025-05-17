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
      appBar: AppBar(
        title: const Text('Eisenhower Matrix'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            // Group tasks by Eisenhower category
            final Map<EisenhowerCategory, List<Task>> categorizedTasks = {
              for (var category in EisenhowerCategory.values)
                category: state.tasks.where((task) => task.eisenhowerCategory == category).toList()
            };

            // Display the matrix quadrants at the top and tasks at the bottom
            return Column(
              children: [
                // Top row: Urgent & Important (Do) and Not Urgent & Important (Decide)
                Expanded(
                  flex: 2, // Allocate more space to quadrants
                  child: Row(
                    children: [
                      // Urgent & Important (Do)
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EisenhowerCategory.doIt.toString().split('.').last,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // You can add a summary or count of tasks here later
                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.doIt] ?? [])), // Optional: display tasks within quadrant
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Not Urgent & Important (Decide)
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EisenhowerCategory.decide.toString().split('.').last,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // You can add a summary or count of tasks here later
                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.decide] ?? [])), // Optional: display tasks within quadrant
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom row: Urgent & Not Important (Delegate) and Not Urgent & Not Important (Delete)
                Expanded(
                   flex: 2, // Allocate more space to quadrants
                  child: Row(
                    children: [
                      // Urgent & Not Important (Delegate)
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EisenhowerCategory.delegate.toString().split('.').last,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // You can add a summary or count of tasks here later
                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delegate] ?? [])), // Optional: display tasks within quadrant
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Not Urgent & Not Important (Delete)
                      Expanded(
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  EisenhowerCategory.delete.toString().split('.').last,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                // You can add a summary or count of tasks here later
                                // Expanded(child: TaskListView(tasks: categorizedTasks[EisenhowerCategory.delete] ?? [])), // Optional: display tasks within quadrant
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Task list at the bottom
                Expanded(
                  flex: 3, // Allocate more space to the task list
                  child: TaskListView(tasks: state.tasks), // Display all tasks here
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
