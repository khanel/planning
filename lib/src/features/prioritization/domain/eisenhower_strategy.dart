import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/prioritization_strategy.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:planning/src/core/utils/logger.dart';

// final log = getLogger('EisenhowerStrategy'); // Corrected: Use the global log instance from logger.dart

class EisenhowerStrategy implements PrioritizationStrategy<EisenhowerCategory> {
  @override
  String get name => 'Eisenhower Matrix';

  @override
  EisenhowerCategory calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  }) {
    log.fine('Calculating priority (Important: $isImportant, Urgent: $isUrgent)');
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

  @override
  String getDescription(EisenhowerCategory priority) {
    return priority.description;
  }

  @override
  Color getColor(EisenhowerCategory priority) {
    return priority.color;
  }
}
