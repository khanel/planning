
import 'package:hive/hive.dart';

part 'unified_record_model.g.dart';

@HiveType(typeId: 0)
class UnifiedRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final Map<String, dynamic> data;

  UnifiedRecordModel({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.data,
  });
}
