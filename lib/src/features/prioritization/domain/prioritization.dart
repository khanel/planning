import 'package:planning/src/features/prioritization/domain/prioritization_strategy.dart';
import 'package:planning/src/features/prioritization/domain/eisenhower_category.dart';
import 'package:flutter/material.dart';
import 'package:planning/src/core/utils/logger.dart';

class Prioritization {
  final PrioritizationStrategy strategy;

  Prioritization(this.strategy) {
    log.fine('Prioritization initialized with strategy: ${strategy.runtimeType}');
  }

  EisenhowerCategory calculatePriority({
    required bool isImportant,
    required bool isUrgent,
  }) {
    log.info(
        'Calculating priority with strategy ${strategy.runtimeType}: Important=$isImportant, Urgent=$isUrgent');
    final category = strategy.calculatePriority(
      isImportant: isImportant,
      isUrgent: isUrgent,
    );
    log.fine('Calculated category: $category');
    return category;
  }

  String getDescription(EisenhowerCategory category) {
    log.info('Getting description for category: $category using strategy ${strategy.runtimeType}');
    final description = strategy.getDescription(category);
    log.fine('Description for $category: $description');
    return description;
  }

  Color getColor(EisenhowerCategory category) {
    log.info('Getting color for category: $category using strategy ${strategy.runtimeType}');
    final color = strategy.getColor(category);
    log.fine('Color for $category: $color');
    return color;
  }
}
