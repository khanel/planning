import 'eisenhower_category.dart';

/// Strategy class that implements the Eisenhower Matrix prioritization logic
class EisenhowerStrategy {
  /// Calculate the Eisenhower priority category based on importance and urgency
  /// 
  /// Returns:
  /// - [EisenhowerCategory.doNow] for important and urgent tasks
  /// - [EisenhowerCategory.decide] for important but not urgent tasks
  /// - [EisenhowerCategory.delegate] for urgent but not important tasks
  /// - [EisenhowerCategory.delete] for neither important nor urgent tasks
  EisenhowerCategory calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  }) {
    if (isImportant && isUrgent) {
      return EisenhowerCategory.doNow;
    } else if (isImportant && !isUrgent) {
      return EisenhowerCategory.decide;
    } else if (!isImportant && isUrgent) {
      return EisenhowerCategory.delegate;
    } else {
      return EisenhowerCategory.delete;
    }
  }
}
