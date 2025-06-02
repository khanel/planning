import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/widgets/eisenhower_matrix.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

class TestableEisenhowerMatrix extends StatelessWidget {
  final List<Task> tasks;
  
  const TestableEisenhowerMatrix({
    Key? key,
    required this.tasks,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Filter tasks by category
    final unprioritizedTasks = tasks.where((task) => 
        task.priority == EisenhowerCategory.unprioritized).toList();
        
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: unprioritizedTasks.length,
            itemBuilder: (context, index) {
              final task = unprioritizedTasks[index];
              
              // Format the due date string
              String dueDateText = 'No due date';
              if (task.dueDate != null) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final tomorrow = today.add(const Duration(days: 1));
                final dueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
                
                if (dueDate.isBefore(today)) {
                  dueDateText = 'Due: Overdue';
                } else if (dueDate.isAtSameMomentAs(today)) {
                  dueDateText = 'Due: Today';
                } else if (dueDate.isAtSameMomentAs(tomorrow)) {
                  dueDateText = 'Due: Tomorrow';
                } else {
                  dueDateText = 'Due: Future';
                }
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name),
                  Text(dueDateText),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
