import 'package:flutter/material.dart';

enum EisenhowerCategory {
  doNow,
  decide,
  delegate,
  delete;

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
    }
  }

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
    }
  }

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
    }
  }
}
