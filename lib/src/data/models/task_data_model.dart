
import 'package:hive/hive.dart';

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
class TaskDataModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final DateTime? dueDate;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final TaskImportance importance;

  TaskDataModel({
    required this.name,
    required this.description,
    this.dueDate,
    this.completed = false,
    this.importance = TaskImportance.medium,
  });
}
