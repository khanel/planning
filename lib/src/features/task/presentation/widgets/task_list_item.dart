
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/presentation/bloc/task_bloc.dart';
import 'dart:async'; // Import for Timer
import 'package:planning/src/data/models/task_data_model.dart'; // Required for TaskImportance
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                    initialTask: widget.task,
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
                    content: Text('Are you sure you want to delete "${widget.task.name}"?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Dismiss the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<TaskBloc>().add(DeleteTask(widget.task.id));
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
