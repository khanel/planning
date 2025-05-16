import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final int importance; // 1 to 5
  final bool isCompleted;
  final String projectId;
  final List<String> tagIds;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.importance,
    required this.isCompleted,
    required this.projectId,
    required this.tagIds,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        importance,
        isCompleted,
        projectId,
        tagIds,
      ];
}
