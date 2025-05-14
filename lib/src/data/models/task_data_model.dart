import 'package:hive/hive.dart';
import 'package:planning/src/data/models/unified_record_model.dart';

part 'task_data_model.g.dart';

@HiveType(typeId: 1)
enum TaskImportance {
  @HiveField(0)
  veryLow,
  @HiveField(1)
  low,
  @HiveField(2)
  medium,
  @HiveField(3)
  high,
  @HiveField(4)
  veryHigh,
}

@HiveType(typeId: 2)
class TaskDataModel extends UnifiedRecordModel {
  @HiveField(5) // Start HiveField index after UnifiedRecordModel fields
  final String name;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final DateTime? dueDate;

  @HiveField(8)
  final bool completed;

  @HiveField(9)
  final TaskImportance importance;

  TaskDataModel({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.name,
    required this.description,
    this.dueDate,
    this.completed = false,
    this.importance = TaskImportance.medium,
  }) : super(
          id: id,
          type: 'task',
          createdAt: createdAt,
          updatedAt: updatedAt,
          data: {}, // Data field is not used in this model as fields are directly in the class
        );

  // Factory constructor for creating a TaskDataModel from a map
  factory TaskDataModel.fromMap(Map<String, dynamic> map) {
    return TaskDataModel(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      name: map['name'] as String,
      description: map['description'] as String,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      completed: map['completed'] as bool,
      importance: TaskImportance.values[map['importance'] as int],
    );
  }

  // Method for converting a TaskDataModel to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'name': name,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'importance': importance.index,
    };
  }
}
