
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'dart:async'; // Import for Timer
import 'package:planning/src/features/task/data/models/task_data_model.dart'; // Required for TaskImportance
import 'package:planning/src/features/task/presentation/widgets/task_form_dialog.dart';

class TaskListItem extends StatefulWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  Timer? _timer;
  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.task.dueDate == null || widget.task.completed) {
      _timeRemaining = '';
      return;
    }

    _updateTimeRemaining(); // Initial update

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    if (widget.task.dueDate == null || widget.task.completed) {
      if (mounted) {
        setState(() {
          _timeRemaining = '';
        });
      }
      _timer?.cancel();
      return;
    }

    final now = DateTime.now();
    final difference = widget.task.dueDate!.difference(now);

    if (difference.isNegative) {
      if (mounted) {
        setState(() {
          _timeRemaining = 'Overdue';
        });
      }
      _timer?.cancel();
    } else {
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      String remaining = '';
      if (days > 0) {
        remaining += '${days}d ';
      }
      if (hours > 0 || days > 0) { // Show hours if days are shown or if there are hours remaining
        remaining += '${hours}h ';
      }
      if (minutes > 0 || hours > 0 || days > 0) { // Show minutes if hours or days are shown or if there are minutes remaining
         remaining += '${minutes}m ';
      }
      remaining += '${seconds}s';


      if (mounted) {
        setState(() {
          _timeRemaining = remaining.trim();
        });
      }
    }
  }

  Color _getImportanceColor(TaskImportance importance) {
    switch (importance) {
      case TaskImportance.veryLow:
        return Colors.grey;
      case TaskImportance.low:
        return Colors.blueGrey;
      case TaskImportance.medium:
        return Colors.orange;
      case TaskImportance.high:
        return Colors.deepOrange;
      case TaskImportance.veryHigh:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blue, // Edit color
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red, // Delete color
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left for delete
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Delete'),
                content: Text('Are you sure you want to delete "${widget.task.name}"?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false), // Dismiss and return false
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true), // Dismiss and return true
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right for edit
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return TaskFormDialog(
                  onSubmit: (updatedTask) {
                    context.read<TaskBloc>().add(UpdateTask(updatedTask));
                  },
                  initialTask: widget.task,
                );
              },
            );
          });
          return Future.value(false); // Do not dismiss the item for editing
        }
        return Future.value(false); // Default to not dismissing
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // Swipe left for delete
          context.read<TaskBloc>().add(DeleteTask(widget.task.id));
        }
        // Edit action is handled in confirmDismiss, so no action needed here for startToEnd
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getImportanceColor(widget.task.importance),
                width: 5.0,
              ),
              right: BorderSide(
                color: _getImportanceColor(widget.task.importance),
                width: 5.0,
              ),
            ),
          ),
          child: ListTile(
            leading: Checkbox(
              value: widget.task.completed,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  final updatedTask = Task(
                    id: widget.task.id,
                    name: widget.task.name,
                    description: widget.task.description,
                    completed: newValue,
                    dueDate: widget.task.dueDate,
                    importance: widget.task.importance,
                    createdAt: widget.task.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  context.read<TaskBloc>().add(UpdateTask(updatedTask));
                }
              },
            ),
            title: Text(widget.task.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.task.description),
                Text(
                  'Category: ${widget.task.eisenhowerCategory.toString().split('.').last}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.task.dueDate != null && !widget.task.completed)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      _timeRemaining,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
