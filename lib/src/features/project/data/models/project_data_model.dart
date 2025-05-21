import 'package:hive/hive.dart';

part 'project_data_model.g.dart';

@HiveType(typeId: 4)
class ProjectDataModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime? dueDate;

  ProjectDataModel({
    required this.name,
    this.description,
    required this.createdAt,
    this.dueDate,
  });
}
