import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/data/models/task_data_model.dart'; // Required for TaskImportance // Assuming Task entity is here

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally, load tasks when the screen is initialized
    // context.read<TaskBloc>().add(const LoadTasks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoadSuccess) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('No tasks yet!'));
            }
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (bool? newValue) {
                      if (newValue != null) {
                        final updatedTask = Task(
                          id: task.id,
                          name: task.name,
                          description: task.description,
                          completed: newValue,
                          dueDate: task.dueDate,
                          importance: task.importance,
                          createdAt: task.createdAt,
                          updatedAt: DateTime.now(),
                        );
                        context.read<TaskBloc>().add(UpdateTask(updatedTask));
                      }
                    },
                  ),
                  title: Text(task.name),
                  subtitle: Text(task.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: Implement navigation to an edit task screen or show a dialog
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // TODO: Implement delete task confirmation and dispatch DeleteTask event
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is TaskLoadFailure) {
            return Center(child: Text('Failed to load tasks: ${state.message}'));
          } else if (state is TaskInitial) {
            // It's good practice to dispatch an event to load data if in initial state
            // and no data has been loaded yet.
            context.read<TaskBloc>().add(const LoadTasks());
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: Text('Something went wrong!')); // Fallback UI
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement navigation to an add task screen or show a dialog
          // For now, let's dispatch an AddTask event with placeholder data
          final newTask = Task(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
            name: 'New Task from FAB',
            description: 'This is a task added via FAB.',
            completed: false,
            dueDate: DateTime.now().add(const Duration(days: 1)), // Example due date
            importance: TaskImportance.medium, // Example importance
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          context.read<TaskBloc>().add(AddTask(newTask));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
