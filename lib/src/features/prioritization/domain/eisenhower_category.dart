import 'package:flutter/material.dart';
import 'package:planning/src/features/prioritization/domain/priority.dart';

/// Represents the four categories of the Eisenhower Matrix plus an unprioritized state.
enum EisenhowerCategory implements Priority {
  doNow,
  decide,
  delegate,
  delete,
  unprioritized; // Not yet assigned by user

  @override
  String get name {
    switch (this) {
      case EisenhowerCategory.doNow:
        return 'Do';
      case EisenhowerCategory.decide:
        return 'Decide';
      case EisenhowerCategory.delegate:
        return 'Delegate';
      case EisenhowerCategory.delete:
        return 'Delete';
      case EisenhowerCategory.unprioritized:
        return 'Unprioritized';
    }
  }

  @override
  String get description {
    switch (this) {
      case EisenhowerCategory.doNow:
        return 'Important and Urgent';
      case EisenhowerCategory.decide:
        return 'Important but Not Urgent';
      case EisenhowerCategory.delegate:
        return 'Not Important but Urgent';
      case EisenhowerCategory.delete:
        return 'Not Important and Not Urgent';
      case EisenhowerCategory.unprioritized:
        return 'Not yet prioritized';
    }
  }

  @override
  Color get color {
    switch (this) {
      case EisenhowerCategory.doNow:
        return Colors.red;
      case EisenhowerCategory.decide:
        return Colors.blue;
      case EisenhowerCategory.delegate:
        return Colors.orange;
      case EisenhowerCategory.delete:
        return Colors.grey;
      case EisenhowerCategory.unprioritized:
        return Colors.grey.shade400;
    }
  }
}
