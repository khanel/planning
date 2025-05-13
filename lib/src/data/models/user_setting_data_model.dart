import 'package:hive/hive.dart';

part 'user_setting_data_model.g.dart';

@HiveType(typeId: 3)
class UserSettingDataModel {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final dynamic value;

  @HiveField(2)
  final String? description;

  UserSettingDataModel({
    required this.key,
    required this.value,
    this.description,
  });
}
