import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'package:planning/src/features/task/presentation/widgets/task_form_dialog.dart';
import 'package:planning/src/features/task/presentation/widgets/task_list_view.dart';
import 'package:planning/src/features/task/domain/entities/task.dart'; // Import EisenhowerCategory

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasks());
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return TaskFormDialog(
          onSubmit: (task) {
            context.read<TaskBloc>().add(AddTask(task));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              EisenhowerCategory? currentFilter;
              if (state is TaskLoadSuccess) {
                currentFilter = state.currentFilter;
              }
              return DropdownButton<EisenhowerCategory?>(
                value: currentFilter,
                icon: const Icon(Icons.filter_list),
                hint: const Text('Filter'),
                items: [
                  const DropdownMenuItem<EisenhowerCategory?>(
                    value: null,
                    child: Text('All Tasks'),
                  ),
                  ...EisenhowerCategory.values.map((category) {
                    return DropdownMenuItem<EisenhowerCategory>(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                ],
                onChanged: (EisenhowerCategory? newValue) {
                  context.read<TaskBloc>().add(FilterTasks(newValue));
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            return TaskListView(tasks: state.tasks);
          } else if (state is TaskLoadFailure) {
            return Center(
              child: Text('Failed to load tasks: ${state.message}'),
            );
          } else if (state is TaskInitial) {
            context.read<TaskBloc>().add(const LoadTasks());
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskDeleteSuccess || state is TaskSaveSuccess) {
             // After save/delete, reload tasks to update the list based on the current filter
             final currentFilter = (state is TaskLoadSuccess) ? state.currentFilter : null; // Preserve filter if possible
             context.read<TaskBloc>().add(const LoadTasks()); // Load all tasks first
             if (currentFilter != null) {
               // Then apply the filter if one was active
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 context.read<TaskBloc>().add(FilterTasks(currentFilter));
               });
             }
             return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Something went wrong!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
