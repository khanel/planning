import 'package:planning/src/data/models/task_data_model.dart';

/// Represents the four categories of the Eisenhower Matrix.
enum EisenhowerCategory {
  doIt, // Urgent and Important
  decide, // Not Urgent and Important
  delegate, // Urgent and Not Important
  delete // Not Urgent and Not Important
}

class Task {
  final String id;
  final String name;
  final String description;
  final DateTime? dueDate;
  final bool completed;
  final TaskImportance importance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.name,
    required this.description,
    this.dueDate,
    required this.completed,
    required this.importance,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Determines if the task is urgent based on its due date.
  /// A task is considered urgent if its due date is today or in the past.
  bool get isUrgent {
    if (dueDate == null) {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDueDate = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return taskDueDate.isBefore(today) || taskDueDate.isAtSameMomentAs(today);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          dueDate == other.dueDate &&
          completed == other.completed &&
          importance == other.importance &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      completed.hashCode ^
      importance.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  /// Determines the Eisenhower Matrix category for the task.
  EisenhowerCategory get eisenhowerCategory {
    final bool isImportant =
        importance == TaskImportance.high || importance == TaskImportance.veryHigh;

    if (isUrgent && isImportant) {
      return EisenhowerCategory.doIt;
    } else if (!isUrgent && isImportant) {
      return EisenhowerCategory.decide;
    } else if (isUrgent && !isImportant) {
      return EisenhowerCategory.delegate;
    } else {
      return EisenhowerCategory.delete;
    }
  }
}
