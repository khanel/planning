import 'package:dartz/dartz.dart';
import 'package:planning/src/core/errors/exceptions.dart';
import 'package:planning/src/core/errors/failures.dart';
import 'package:planning/src/features/scheduling/data/datasources/scheduling_local_data_source.dart';
import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/schedule_event.dart';
import 'package:planning/src/features/scheduling/domain/repositories/scheduling_repository.dart';

/// Implementation of [SchedulingRepository] using local data source
/// 
/// This class handles the business logic of converting between domain entities
/// and data models, while delegating storage operations to the local data source.
class SchedulingRepositoryImpl implements SchedulingRepository {
  final SchedulingLocalDataSource localDataSource;

  const SchedulingRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ScheduleEvent>> createEvent(ScheduleEvent event) async {
    try {
      final dataModel = ScheduleEventDataModel.fromDomainEntity(event);
      await localDataSource.saveEvent(dataModel);
      return Right(event);
    } on CacheException {
      return Left(CacheFailure('Failed to create schedule event'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEvent>>> getEvents() async {
    try {
      final dataModels = await localDataSource.getEvents();
      final events = dataModels.map((model) => model.toDomainEntity()).toList();
      return Right(events);
    } on CacheException {
      return Left(CacheFailure('Failed to retrieve schedule events'));
    }
  }

  @override
  Future<Either<Failure, ScheduleEvent>> getEventById(String id) async {
    try {
      final dataModel = await localDataSource.getEventById(id);
      final event = dataModel.toDomainEntity();
      return Right(event);
    } on CacheException {
      return Left(CacheFailure('Failed to retrieve schedule event by id'));
    }
  }

  @override
  Future<Either<Failure, ScheduleEvent>> updateEvent(ScheduleEvent event) async {
    try {
      final dataModel = ScheduleEventDataModel.fromDomainEntity(event);
      await localDataSource.saveEvent(dataModel);
      return Right(event);
    } on CacheException {
      return Left(CacheFailure('Failed to update schedule event'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    try {
      await localDataSource.deleteEvent(id);
      return const Right(null);
    } on CacheException {
      return Left(CacheFailure('Failed to delete schedule event'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEvent>>> getEventsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final dataModels = await localDataSource.getEventsByDateRange(startDate, endDate);
      final events = dataModels.map((model) => model.toDomainEntity()).toList();
      return Right(events);
    } on CacheException {
      return Left(CacheFailure('Failed to retrieve events by date range'));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleEvent>>> getEventsByTaskId(String taskId) async {
    try {
      final dataModels = await localDataSource.getEventsByTaskId(taskId);
      final events = dataModels.map((model) => model.toDomainEntity()).toList();
      return Right(events);
    } on CacheException {
      return Left(CacheFailure('Failed to retrieve events by task id'));
    }
  }
}
