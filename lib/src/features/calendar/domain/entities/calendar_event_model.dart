
import 'package:equatable/equatable.dart';

class CalendarEventModel extends Equatable {
  final String id;
  final String summary;
  // Add other relevant fields like start time, end time, description, etc.

  const CalendarEventModel({
    required this.id,
    required this.summary,
  });

  @override
  List<Object?> get props => [id, summary];
}
