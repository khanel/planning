import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';

abstract class PrioritizationStrategy {
  String get name;
  
  EisenhowerCategory calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  });

  String getDescription(EisenhowerCategory category);
  
  Color getColor(EisenhowerCategory category);
}
