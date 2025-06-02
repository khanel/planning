import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'domain/eisenhower_category_test.dart' as eisenhower_category_test;
import 'domain/eisenhower_strategy_test.dart' as eisenhower_strategy_test;
import 'domain/task_prioritization_test.dart' as task_prioritization_test;
import 'presentation/widgets/matrix_quadrant_test.dart' as matrix_quadrant_test;
import 'presentation/widgets/drag_drop_test.dart' as drag_drop_test;
import 'presentation/bloc/prioritization_bloc_test.dart' as prioritization_bloc_test;
import 'presentation/widgets/eisenhower_matrix_test.dart' as eisenhower_matrix_test;
import 'presentation/pages/eisenhower_matrix_page_test.dart' as eisenhower_matrix_page_test;

void main() {
  group('Eisenhower Matrix Feature Tests', () {
    group('Domain Layer Tests', () {
      eisenhower_category_test.main();
      eisenhower_strategy_test.main();
      task_prioritization_test.main();
    });
    
    group('Presentation Layer Tests', () {
      group('Widgets', () {
        matrix_quadrant_test.main();
        drag_drop_test.main();
        eisenhower_matrix_test.main();
      });
      
      group('BLoC', () {
        prioritization_bloc_test.main();
      });
      
      group('Pages', () {
        eisenhower_matrix_page_test.main();
      });
    });
  });
}
