
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provides methods to initialize and access Hive boxes for DI.
class HiveModule {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here when models are available
    // Example: Hive.registerAdapter(MyModelAdapter());
  }

  /// Opens and returns a box with the given [boxName].
  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }
}
