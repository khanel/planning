import 'package:planning/src/data/models/task_data_model.dart';

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
}