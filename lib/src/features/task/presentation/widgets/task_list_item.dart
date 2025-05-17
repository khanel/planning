
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'package:planning/src/data/models/task_data_model.dart'; // Required for TaskImportance
import 'package:planning/src/features/task/presentation/widgets/task_form_dialog.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return TaskFormDialog(
                    onSubmit: (updatedTask) {
                      context.read<TaskBloc>().add(UpdateTask(updatedTask));
                    },
                    initialTask: task,
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete "${task.name}"?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Dismiss the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                          Navigator.of(context).pop(); // Dismiss the dialog
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
