import 'package:equatable/equatable.dart';
import 'package:planning/src/features/task/data/models/task_data_model.dart';
import 'package:planning/src/features/prioritization/domain/priority.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart'
    as eisenhower;
import 'package:planning/src/features/prioritization/domain/eisenhower_strategy.dart';

class Task extends Equatable {
  final String id;
  String name;
  String description;
  DateTime? dueDate;
  bool completed;
  TaskImportance importance;
  final DateTime createdAt;
  DateTime updatedAt;
  Priority priority; // User-assigned priority, default=unprioritized

  Task({
    required this.id,
    required this.name,
    required this.description,
    this.dueDate,
    required this.completed,
    required this.importance,
    required this.createdAt,
    required this.updatedAt,
    Priority? priority,
  }) : priority = priority ?? eisenhower.EisenhowerCategory.unprioritized;

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

  /// Creates a copy of this task with the given fields replaced with the new values.
  Task copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? dueDate,
    bool? completed,
    TaskImportance? importance,
    DateTime? createdAt,
    DateTime? updatedAt,
    Priority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      importance: importance ?? this.importance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        dueDate,
        completed,
        importance,
        createdAt,
        updatedAt,
        priority,
      ];

  @override
  bool get stringify => true;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      completed.hashCode ^
      importance.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      priority.hashCode;

  /// Returns the user-assigned quadrant if set and is an EisenhowerCategory, otherwise computes it.
  eisenhower.EisenhowerCategory get eisenhowerCategory {
    if (priority is eisenhower.EisenhowerCategory) {
      // If the priority is explicitly set to unprioritized, compute it
      if (priority == eisenhower.EisenhowerCategory.unprioritized) {
        final strategy = EisenhowerStrategy();
        return strategy.calculatePriority(
          isImportant: importance == TaskImportance.high || importance == TaskImportance.veryHigh,
          isUrgent: isUrgent,
        );
      }
      return priority as eisenhower.EisenhowerCategory;
    }

    // If no user-assigned priority or not an EisenhowerCategory, compute it
    final strategy = EisenhowerStrategy();
    return strategy.calculatePriority(
      isImportant: importance == TaskImportance.high || importance == TaskImportance.veryHigh,
      isUrgent: isUrgent,
    );
  }
}
