import 'package:planning/src/features/prioritization/domain/prioritization_strategy.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:flutter/material.dart';

class Prioritization {
  final PrioritizationStrategy strategy;
  
  Prioritization(this.strategy);
  
  EisenhowerCategory calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  }) {
    return strategy.calculatePriority(
      isImportant: isImportant,
      isUrgent: isUrgent,
    );
  }

  String getDescription(EisenhowerCategory category) {
    return strategy.getDescription(category);
  }

  Color getColor(EisenhowerCategory category) {
    return strategy.getColor(category);
  }
}
