import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/matrix_quadrant.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

/// A widget that displays the Eisenhower Matrix with four quadrants and unprioritized tasks
class EisenhowerMatrix extends StatelessWidget {
  /// The list of all tasks to display in the matrix
  final List<Task> tasks;
  
  /// Callback when a task is tapped
  final Function(Task)? onTaskTap;
  
  /// Callback when a task's priority is changed through drag and drop
  final Function(Task, EisenhowerCategory)? onPriorityChanged;

  /// Creates an EisenhowerMatrix widget
  const EisenhowerMatrix({
    Key? key,
    required this.tasks,
    this.onTaskTap,
    this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter tasks by quadrant
    final doNowTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.doNow).toList();
    final decideTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.decide).toList();
    final delegateTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.delegate).toList();
    final deleteTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.delete).toList();
    final unprioritizedTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.unprioritized).toList();
    
    // Print task counts for debugging
    print('EisenhowerMatrix: Tasks loaded - ${tasks.length}');
    print('EisenhowerMatrix: Do Now tasks - ${doNowTasks.length}');
    print('EisenhowerMatrix: Decide tasks - ${decideTasks.length}');
    print('EisenhowerMatrix: Delegate tasks - ${delegateTasks.length}');
    print('EisenhowerMatrix: Delete tasks - ${deleteTasks.length}');
    print('EisenhowerMatrix: Unprioritized tasks - ${unprioritizedTasks.length}');
    
    // Print task details
    for (final task in tasks) {
      print('Task: ${task.name}, Priority: ${task.priority.runtimeType} - ${task.priority}');
    }

    return Column(
      children: [
        // Matrix title and axis labels
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Eisenhower Matrix',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        
        // Top axis label (Urgent vs Not Urgent)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 2,
                child: Text(
                  'URGENT',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'NOT URGENT',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        
        // Matrix grid with side labels
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left axis label (Important vs Not Important)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RotatedBox(
                  quarterTurns: 3,                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Text(
                        'IMPORTANT',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'NOT IMPORTANT',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
              
              // 2x2 Matrix grid
              Expanded(
                child: Column(
                  children: [
                    // Top row: Do Now and Decide
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Q1: Do Now (Important & Urgent)
                          Expanded(
                            child: MatrixQuadrant(
                              title: EisenhowerCategory.doNow.name,
                              color: EisenhowerCategory.doNow.color,
                              description: EisenhowerCategory.doNow.description,
                              tasks: doNowTasks,
                              category: EisenhowerCategory.doNow,
                              onTaskTap: onTaskTap,
                              onPriorityChanged: onPriorityChanged,
                            ),
                          ),
                          // Q2: Decide (Important & Not Urgent)
                          Expanded(
                            child: MatrixQuadrant(
                              title: EisenhowerCategory.decide.name,
                              color: EisenhowerCategory.decide.color,
                              description: EisenhowerCategory.decide.description,
                              tasks: decideTasks,
                              category: EisenhowerCategory.decide,
                              onTaskTap: onTaskTap,
                              onPriorityChanged: onPriorityChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom row: Delegate and Delete
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Q3: Delegate (Not Important & Urgent)
                          Expanded(
                            child: MatrixQuadrant(
                              title: EisenhowerCategory.delegate.name,
                              color: EisenhowerCategory.delegate.color,
                              description: EisenhowerCategory.delegate.description,
                              tasks: delegateTasks,
                              category: EisenhowerCategory.delegate,
                              onTaskTap: onTaskTap,
                              onPriorityChanged: onPriorityChanged,
                            ),
                          ),
                          // Q4: Delete (Not Important & Not Urgent)
                          Expanded(
                            child: MatrixQuadrant(
                              title: EisenhowerCategory.delete.name,
                              color: EisenhowerCategory.delete.color,
                              description: EisenhowerCategory.delete.description,
                              tasks: deleteTasks,
                              category: EisenhowerCategory.delete,
                              onTaskTap: onTaskTap,
                              onPriorityChanged: onPriorityChanged,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Unprioritized tasks section
        if (unprioritizedTasks.isNotEmpty)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Unprioritized Tasks (${unprioritizedTasks.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: unprioritizedTasks.length,
                    itemBuilder: (context, index) {
                      final task = unprioritizedTasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: Draggable<Task>(
                          data: task,
                          feedback: Material(
                            elevation: 4.0,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: EisenhowerCategory.unprioritized.color),
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
                                const SizedBox(height: 4),
                                _buildDueDate(task),
                              ],
                            ),
                            onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
  
  /// Formats the due date for display
  Widget _buildDueDate(Task task) {
    if (task.dueDate == null) {
      return const Text('No due date', style: TextStyle(fontSize: 12));
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    
    String formattedDate;
    
    if (dueDate.isBefore(today)) {
      formattedDate = 'Overdue';
    } else if (dueDate.isAtSameMomentAs(today)) {
      formattedDate = 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      formattedDate = 'Tomorrow';
    } else {
      final difference = dueDate.difference(today).inDays;
      if (difference < 7) {
        formattedDate = '$difference days';
      } else {
        formattedDate = '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}';
      }
    }
    
    return Text(
      'Due: $formattedDate',
      style: TextStyle(
        fontSize: 12,
        color: dueDate.isBefore(today) ? Colors.red : null,
        fontWeight: dueDate.isBefore(today) ? FontWeight.bold : null,
      ),
    );
  }
}
