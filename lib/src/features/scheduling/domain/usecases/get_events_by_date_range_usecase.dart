import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_event.dart';
import '../repositories/scheduling_repository.dart';

class GetEventsByDateRangeUseCase implements UseCase<List<ScheduleEvent>, GetEventsByDateRangeParams> {
  final SchedulingRepository repository;

  GetEventsByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<ScheduleEvent>>> call(GetEventsByDateRangeParams params) async {
    // Validate the date range
    final validationResult = _validateDateRange(params.startDate, params.endDate);
    if (validationResult != null) {
      return Left(validationResult);
    }

    // Normalize dates to ensure proper range coverage
    final normalizedStartDate = _normalizeToStartOfDay(params.startDate);
    final normalizedEndDate = _normalizeToEndOfDay(params.endDate);

    return await repository.getEventsByDateRange(normalizedStartDate, normalizedEndDate);
  }

  ValidationFailure? _validateDateRange(DateTime startDate, DateTime endDate) {
    // Check if start date is not after end date
    if (startDate.isAfter(endDate)) {
      return const ValidationFailure('Start date cannot be after end date');
    }

    return null; // No validation errors
  }

  DateTime _normalizeToStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 0, 0, 0, 0);
  }

  DateTime _normalizeToEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
}

class GetEventsByDateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const GetEventsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}
