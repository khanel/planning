import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Import go_router
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
  // Navigation routes
  static const String _eisenhowerRoute = '/eisenhower';
  static const String _calendarRoute = '/calendar';

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

  void _navigateToEisenhowerMatrix() {
    context.go(_eisenhowerRoute);
  }

  void _navigateToCalendar() {
    context.go(_calendarRoute);
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.grid_view),
        tooltip: 'Eisenhower Matrix',
        onPressed: _navigateToEisenhowerMatrix,
      ),
      IconButton(
        icon: const Icon(Icons.calendar_today),
        tooltip: 'Calendar',
        onPressed: _navigateToCalendar,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: _buildAppBarActions(),
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
             context.read<TaskBloc>().add(const LoadTasks());
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
