import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/prioritization/presentation/bloc/prioritization_bloc.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/core/utils/logger.dart';

/// A floating action button widget that provides magic auto-prioritization functionality
/// for unprioritized tasks using the Eisenhower Matrix logic.
class MagicPrioritizationButton extends StatelessWidget {
  /// The list of unprioritized tasks to be auto-prioritized
  final List<Task> unprioritizedTasks;
  
  /// Callback triggered after magic prioritization to refresh the view
  final VoidCallback? onRefreshRequired;

  /// Creates a MagicPrioritizationButton widget
  const MagicPrioritizationButton({
    Key? key,
    required this.unprioritizedTasks,
    this.onRefreshRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show the button if there are unprioritized tasks
    if (unprioritizedTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => _showMagicPrioritizationDialog(context),
      icon: Badge(
        label: Text(unprioritizedTasks.length.toString()),
        child: const Icon(Icons.auto_fix_high),
      ),
      label: const Text('Magic'),
      tooltip: 'Auto-prioritize unprioritized tasks',
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    );
  }

  /// Shows the magic prioritization confirmation dialog
  void _showMagicPrioritizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.auto_fix_high, color: Colors.purple),
              SizedBox(width: 8),
              Text('Magic Prioritization'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will automatically prioritize ${unprioritizedTasks.length} unprioritized tasks based on:',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('• Due date (urgency)'),
              const Text('• Importance level'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Priority Rules:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Urgent + Important = Do Now'),
                    Text('• Not Urgent + Important = Decide'),
                    Text('• Urgent + Not Important = Delegate'),
                    Text('• Not Urgent + Not Important = Delete'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _performMagicPrioritization(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply Magic'),
            ),
          ],
        );
      },
    );
  }

  /// Performs the actual magic prioritization logic
  void _performMagicPrioritization(BuildContext context) {
    int prioritizedCount = 0;
    
    for (final task in unprioritizedTasks) {
      // Determine if task is important based on its importance level
      final isImportant = task.importance == TaskImportance.high || 
                         task.importance == TaskImportance.veryHigh;
      
      // Determine if task is urgent based on due date
      final isUrgent = task.isUrgent;
      
      // Apply Eisenhower Matrix logic
      EisenhowerCategory newPriority;
      if (isUrgent && isImportant) {
        newPriority = EisenhowerCategory.doNow;
      } else if (!isUrgent && isImportant) {
        newPriority = EisenhowerCategory.decide;
      } else if (isUrgent && !isImportant) {
        newPriority = EisenhowerCategory.delegate;
      } else {
        newPriority = EisenhowerCategory.delete;
      }
      
      // Update the task priority through the bloc
      context.read<PrioritizationBloc>().add(
        UpdateTaskPriority(
          task: task,
          newPriority: newPriority,
        ),
      );
      
      prioritizedCount++;
    }
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_fix_high, color: Colors.white),
            const SizedBox(width: 8),
            Text('✨ Automatically prioritized $prioritizedCount tasks!'),
          ],
        ),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Trigger refresh to sync bloc state after magic prioritization
    Future.delayed(const Duration(milliseconds: 200), () {
      log.info('MagicPrioritizationButton: Auto-refresh triggered after magic prioritization');
      onRefreshRequired?.call();
    });
  }
}
