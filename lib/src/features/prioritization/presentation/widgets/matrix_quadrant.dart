import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

/// A widget that represents a quadrant in the Eisenhower Matrix
class MatrixQuadrant extends StatelessWidget {
  /// The title of the quadrant
  final String title;
  
  /// The color associated with the quadrant
  final Color color;
  
  /// A description of the quadrant's purpose
  final String description;
  
  /// The list of tasks in this quadrant
  final List<Task> tasks;
  
  /// Callback when a task is tapped
  final Function(Task)? onTaskTap;
  
  /// Callback when a task's priority is changed through drag and drop
  final Function(Task, EisenhowerCategory)? onPriorityChanged;
  
  /// The category this quadrant represents
  final EisenhowerCategory category;
  
  /// Whether to show an icon indicating importance
  final bool showImportanceIcon;
  
  /// Whether to show an icon indicating urgency
  final bool showUrgencyIcon;
  
  /// Creates a MatrixQuadrant widget
  const MatrixQuadrant({
    Key? key,
    required this.title,
    required this.color,
    required this.description,
    required this.tasks,
    required this.category,
    this.onTaskTap,
    this.onPriorityChanged,
    this.showImportanceIcon = false,
    this.showUrgencyIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAccept: (task) {
        if (onPriorityChanged != null) {
          print('Task dropped in $title quadrant: ${task.name}');
          onPriorityChanged!(task, category);
        }
      },
      onWillAccept: (task) {
        // Only accept if it's not already in this category
        return task != null && task.priority != category;
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty 
                ? color.withOpacity(0.4) // Highlight when dragging over
                : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: candidateData.isNotEmpty 
                  ? color.withOpacity(0.8) // Highlight border when dragging over
                  : color.withOpacity(0.5),
              width: candidateData.isNotEmpty ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: color.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (showImportanceIcon)
                              Icon(
                                Icons.priority_high,
                                color: color.withOpacity(0.8),
                                size: 16,
                              ),
                            if (showUrgencyIcon)
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Icon(
                                  Icons.timelapse,
                                  color: color.withOpacity(0.8),
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            '${tasks.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Task list
              Expanded(
                child: tasks.isEmpty
                    ? _buildEmptyState()
                    : _buildTaskList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No tasks in this quadrant',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Draggable<Task>(
          data: task,
          feedback: Material(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: color),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (task.description.isNotEmpty)
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          childWhenDragging: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(
                task.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Due: ${_formatDueDate(task.dueDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isUrgent ? Colors.red : null,
                          fontWeight: task.isUrgent ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
            ),
          ),
        );
      },
    );
  }
  
  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDateDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDateDay.isBefore(today)) {
      return 'Overdue';
    } else if (dueDateDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (dueDateDay.isAtSameMomentAs(tomorrow)) {
      return 'Tomorrow';
    } else {
      final difference = dueDateDay.difference(today).inDays;
      if (difference < 7) {
        return 'In $difference days';
      } else {
        return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
      }
    }
  }
}
