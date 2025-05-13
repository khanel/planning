import 'package:hive/hive.dart';

part 'tag_data_model.g.dart';

@HiveType(typeId: 5)
class TagDataModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? color;

  @HiveField(2)
  final String? description;

  TagDataModel({
    required this.name,
    this.color,
    this.description,
  });
}
