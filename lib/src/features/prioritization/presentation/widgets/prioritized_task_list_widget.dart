import 'package:flutter/material.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/presentation/widgets/task_list_view.dart';

class PrioritizedTaskListWidget extends StatelessWidget {
  final List<Task> tasks;

  const PrioritizedTaskListWidget({Key? key, required this.tasks})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TaskListView(tasks: tasks);
  }
}
