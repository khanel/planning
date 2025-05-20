import 'package:logging/logging.dart';

// Configure the logger
void setupLogger({Level level = Level.INFO}) { // Added optional level parameter with default
  Logger.root.level = level; // Use the passed level
  Logger.root.onRecord.listen((record) {
    print('\${record.level.name}: \${record.time}: \${record.loggerName}: \${record.message}');
    if (record.error != null) {
      print('Error: \${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: \${record.stackTrace}');
    }
  });
}

// Create a logger instance for use in your application
final log = Logger('App');
