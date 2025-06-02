import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/task/domain/entities/task.dart';

/// Helper class to generate test data for Eisenhower Matrix tests
class TestTaskFactory {
  /// Create a single task with the given priority
  static Task createTask({
    required String id,
    required String name,
    String description = 'Test Description',
    required DateTime dueDate,
    bool completed = false,
    TaskImportance importance = TaskImportance.medium,
    required EisenhowerCategory priority,
  }) {
    final DateTime now = DateTime.now();
    
    return Task(
      id: id,
      name: name,
      description: description,
      dueDate: dueDate,
      completed: completed,
      importance: importance,
      createdAt: now,
      updatedAt: now,
      priority: priority,
    );
  }
  
  /// Create a set of tasks for each Eisenhower category
  static List<Task> createTaskSet() {
    final DateTime now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));
    
    return [
      // Do Now task (Important and Urgent)
      createTask(
        id: '1',
        name: 'Do Now Task',
        dueDate: yesterday, // Urgent (past due)
        importance: TaskImportance.high, // Important
        priority: EisenhowerCategory.doNow,
      ),
      
      // Decide task (Important but Not Urgent)
      createTask(
        id: '2',
        name: 'Decide Task',
        dueDate: nextWeek, // Not urgent
        importance: TaskImportance.high, // Important
        priority: EisenhowerCategory.decide,
      ),
      
      // Delegate task (Urgent but Not Important)
      createTask(
        id: '3',
        name: 'Delegate Task',
        dueDate: yesterday, // Urgent (past due)
        importance: TaskImportance.low, // Not important
        priority: EisenhowerCategory.delegate,
      ),
      
      // Delete task (Not Important and Not Urgent)
      createTask(
        id: '4',
        name: 'Delete Task',
        dueDate: nextWeek, // Not urgent
        importance: TaskImportance.low, // Not important
        priority: EisenhowerCategory.delete,
      ),
      
      // Unprioritized task
      createTask(
        id: '5',
        name: 'Unprioritized Task',
        dueDate: tomorrow,
        importance: TaskImportance.medium,
        priority: EisenhowerCategory.unprioritized,
      ),
    ];
  }
  
  /// Create a set of tasks with different due dates for testing date formatting
  static List<Task> createTasksWithDifferentDueDates() {
    final DateTime now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));
    
    return [
      // Overdue task
      createTask(
        id: '6',
        name: 'Overdue Task',
        dueDate: yesterday,
        priority: EisenhowerCategory.unprioritized,
      ),
      
      // Due today
      createTask(
        id: '7',
        name: 'Today Task',
        dueDate: today,
        priority: EisenhowerCategory.unprioritized,
      ),
      
      // Due tomorrow
      createTask(
        id: '8',
        name: 'Tomorrow Task',
        dueDate: tomorrow,
        priority: EisenhowerCategory.unprioritized,
      ),
      
      // Due next week
      createTask(
        id: '9',
        name: 'Next Week Task',
        dueDate: nextWeek,
        priority: EisenhowerCategory.unprioritized,
      ),
    ];
  }
  
  /// Create tasks with varying importance and urgency combinations
  static List<Task> createTasksWithImportanceUrgencyCombinations() {
    final DateTime now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 7));
    
    return [
      // Important and Urgent
      createTask(
        id: '10',
        name: 'Important Urgent Task',
        dueDate: yesterday, // Urgent
        importance: TaskImportance.high, // Important
        priority: EisenhowerCategory.unprioritized, // Let it be calculated
      ),
      
      // Important but Not Urgent
      createTask(
        id: '11',
        name: 'Important Not Urgent Task',
        dueDate: nextWeek, // Not urgent
        importance: TaskImportance.high, // Important
        priority: EisenhowerCategory.unprioritized, // Let it be calculated
      ),
      
      // Not Important but Urgent
      createTask(
        id: '12',
        name: 'Not Important Urgent Task',
        dueDate: yesterday, // Urgent
        importance: TaskImportance.low, // Not important
        priority: EisenhowerCategory.unprioritized, // Let it be calculated
      ),
      
      // Not Important and Not Urgent
      createTask(
        id: '13',
        name: 'Not Important Not Urgent Task',
        dueDate: nextWeek, // Not urgent
        importance: TaskImportance.low, // Not important
        priority: EisenhowerCategory.unprioritized, // Let it be calculated
      ),
    ];
  }
}
