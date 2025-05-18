import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/prioritization_strategy.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';

class EisenhowerStrategy implements PrioritizationStrategy {
  @override
  String get name => 'Eisenhower Matrix';

  @override
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

  @override
  String getDescription(EisenhowerCategory category) {
    return category.description;
  }

  @override
  Color getColor(EisenhowerCategory category) {
    return category.color;
  }
}
