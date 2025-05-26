import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

/// Draggable task item for the Eisenhower Matrix
class DraggableTaskItem extends StatelessWidget {
  /// The task to display
  final Task task;
  
  /// Callback when the task is dragged to a new priority quadrant
  final Function(Task, EisenhowerCategory)? onPriorityChanged;

  /// Creates a DraggableTaskItem
  const DraggableTaskItem({
    Key? key,
    required this.task,
    this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            task.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Card(
          child: ListTile(
            title: Text(task.name),
            subtitle: Text(task.description),
          ),
        ),
      ),
      child: Card(
        child: ListTile(
          title: Text(task.name),
          subtitle: Text(task.description),
          trailing: const Icon(Icons.drag_handle),
        ),
      ),
    );
  }
}

/// Target drop area for tasks in a priority quadrant
class TaskDropTarget extends StatelessWidget {
  /// The category of this drop target
  final EisenhowerCategory category;
  
  /// Callback when a task is dropped into this quadrant
  final Function(Task, EisenhowerCategory)? onTaskDropped;
  
  /// Child widget to display inside the drop target
  final Widget child;

  /// Creates a TaskDropTarget
  const TaskDropTarget({
    Key? key,
    required this.category,
    this.onTaskDropped,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? category.color
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
          child: child,
        );
      },
      onAccept: (Task task) {
        if (onTaskDropped != null) {
          onTaskDropped!(task, category);
        }
      },
    );
  }
}
