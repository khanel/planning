import 'package:flutter_test/flutter_test.dart';
import 'package:planning/src/features/scheduling/data/models/schedule_event_data_model.dart';
import 'package:planning/src/features/scheduling/domain/entities/calendar_sync_status.dart';

void main() {
  group('ScheduleEventDataModel', () {
    late ScheduleEventDataModel scheduleEventDataModel;
    final DateTime now = DateTime.now();
    final DateTime startTime = now.add(const Duration(hours: 1));
    final DateTime endTime = now.add(const Duration(hours: 2));

    setUp(() {
      scheduleEventDataModel = ScheduleEventDataModel(
        id: 'event-1',
        title: 'Team Meeting',
        description: 'Weekly team standup meeting',
        startTime: startTime,
        endTime: endTime,
        isAllDay: false,
        createdAt: now,
        updatedAt: now,
        googleCalendarId: 'gcal-123',
        syncStatus: CalendarSyncStatus.synced,
        lastSyncAt: now,
        linkedTaskId: 'task-456',
      );
    });

    group('Constructor', () {
      test('should create ScheduleEventDataModel with all properties', () {
        expect(scheduleEventDataModel.id, 'event-1');
        expect(scheduleEventDataModel.type, 'schedule_event');
        expect(scheduleEventDataModel.title, 'Team Meeting');
        expect(scheduleEventDataModel.description, 'Weekly team standup meeting');
        expect(scheduleEventDataModel.startTime, startTime);
        expect(scheduleEventDataModel.endTime, endTime);
        expect(scheduleEventDataModel.isAllDay, false);
        expect(scheduleEventDataModel.createdAt, now);
        expect(scheduleEventDataModel.updatedAt, now);
        expect(scheduleEventDataModel.googleCalendarId, 'gcal-123');
        expect(scheduleEventDataModel.syncStatus, CalendarSyncStatus.synced);
        expect(scheduleEventDataModel.lastSyncAt, now);
        expect(scheduleEventDataModel.linkedTaskId, 'task-456');
      });

      test('should create ScheduleEventDataModel with minimal properties', () {
        final minimalEvent = ScheduleEventDataModel(
          id: 'event-2',
          title: 'Quick Call',
          startTime: startTime,
          endTime: endTime,
          createdAt: now,
          updatedAt: now,
        );

        expect(minimalEvent.id, 'event-2');
        expect(minimalEvent.type, 'schedule_event');
        expect(minimalEvent.title, 'Quick Call');
        expect(minimalEvent.description, isNull);
        expect(minimalEvent.isAllDay, false);
        expect(minimalEvent.syncStatus, CalendarSyncStatus.notSynced);
        expect(minimalEvent.googleCalendarId, isNull);
        expect(minimalEvent.lastSyncAt, isNull);
        expect(minimalEvent.linkedTaskId, isNull);
      });
    });

    group('Serialization', () {
      test('should convert to map correctly', () {
        final map = scheduleEventDataModel.toMap();

        expect(map['id'], 'event-1');
        expect(map['title'], 'Team Meeting');
        expect(map['description'], 'Weekly team standup meeting');
        expect(map['startTime'], startTime.toIso8601String());
        expect(map['endTime'], endTime.toIso8601String());
        expect(map['isAllDay'], false);
        expect(map['createdAt'], now.toIso8601String());
        expect(map['updatedAt'], now.toIso8601String());
        expect(map['googleCalendarId'], 'gcal-123');
        expect(map['syncStatus'], CalendarSyncStatus.synced.index);
        expect(map['lastSyncAt'], now.toIso8601String());
        expect(map['linkedTaskId'], 'task-456');
      });

      test('should convert from map correctly', () {
        final map = {
          'id': 'event-1',
          'title': 'Team Meeting',
          'description': 'Weekly team standup meeting',
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          'isAllDay': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'googleCalendarId': 'gcal-123',
          'syncStatus': CalendarSyncStatus.synced.index,
          'lastSyncAt': now.toIso8601String(),
          'linkedTaskId': 'task-456',
        };

        final eventFromMap = ScheduleEventDataModel.fromMap(map);

        expect(eventFromMap.id, scheduleEventDataModel.id);
        expect(eventFromMap.title, scheduleEventDataModel.title);
        expect(eventFromMap.description, scheduleEventDataModel.description);
        expect(eventFromMap.startTime, scheduleEventDataModel.startTime);
        expect(eventFromMap.endTime, scheduleEventDataModel.endTime);
        expect(eventFromMap.isAllDay, scheduleEventDataModel.isAllDay);
        expect(eventFromMap.createdAt, scheduleEventDataModel.createdAt);
        expect(eventFromMap.updatedAt, scheduleEventDataModel.updatedAt);
        expect(eventFromMap.googleCalendarId, scheduleEventDataModel.googleCalendarId);
        expect(eventFromMap.syncStatus, scheduleEventDataModel.syncStatus);
        expect(eventFromMap.lastSyncAt, scheduleEventDataModel.lastSyncAt);
        expect(eventFromMap.linkedTaskId, scheduleEventDataModel.linkedTaskId);
      });

      test('should handle null values in serialization', () {
        final eventWithNulls = ScheduleEventDataModel(
          id: 'event-3',
          title: 'Simple Event',
          startTime: startTime,
          endTime: endTime,
          createdAt: now,
          updatedAt: now,
        );

        final map = eventWithNulls.toMap();
        expect(map['description'], isNull);
        expect(map['googleCalendarId'], isNull);
        expect(map['lastSyncAt'], isNull);
        expect(map['linkedTaskId'], isNull);

        final eventFromMap = ScheduleEventDataModel.fromMap(map);
        expect(eventFromMap.description, isNull);
        expect(eventFromMap.googleCalendarId, isNull);
        expect(eventFromMap.lastSyncAt, isNull);
        expect(eventFromMap.linkedTaskId, isNull);
      });
    });

    group('Domain Entity Conversion', () {
      test('should convert to domain entity correctly', () {
        final domainEntity = scheduleEventDataModel.toDomainEntity();

        expect(domainEntity.id, scheduleEventDataModel.id);
        expect(domainEntity.title, scheduleEventDataModel.title);
        expect(domainEntity.description, scheduleEventDataModel.description);
        expect(domainEntity.startTime, scheduleEventDataModel.startTime);
        expect(domainEntity.endTime, scheduleEventDataModel.endTime);
        expect(domainEntity.isAllDay, scheduleEventDataModel.isAllDay);
        expect(domainEntity.createdAt, scheduleEventDataModel.createdAt);
        expect(domainEntity.updatedAt, scheduleEventDataModel.updatedAt);
        expect(domainEntity.googleCalendarId, scheduleEventDataModel.googleCalendarId);
        expect(domainEntity.syncStatus, scheduleEventDataModel.syncStatus);
        expect(domainEntity.lastSyncAt, scheduleEventDataModel.lastSyncAt);
        expect(domainEntity.linkedTaskId, scheduleEventDataModel.linkedTaskId);
      });

      test('should create from domain entity correctly', () {
        final domainEntity = scheduleEventDataModel.toDomainEntity();
        final dataModelFromDomain = ScheduleEventDataModel.fromDomainEntity(domainEntity);

        expect(dataModelFromDomain.id, scheduleEventDataModel.id);
        expect(dataModelFromDomain.title, scheduleEventDataModel.title);
        expect(dataModelFromDomain.description, scheduleEventDataModel.description);
        expect(dataModelFromDomain.startTime, scheduleEventDataModel.startTime);
        expect(dataModelFromDomain.endTime, scheduleEventDataModel.endTime);
        expect(dataModelFromDomain.isAllDay, scheduleEventDataModel.isAllDay);
        expect(dataModelFromDomain.createdAt, scheduleEventDataModel.createdAt);
        expect(dataModelFromDomain.updatedAt, scheduleEventDataModel.updatedAt);
        expect(dataModelFromDomain.googleCalendarId, scheduleEventDataModel.googleCalendarId);
        expect(dataModelFromDomain.syncStatus, scheduleEventDataModel.syncStatus);
        expect(dataModelFromDomain.lastSyncAt, scheduleEventDataModel.lastSyncAt);
        expect(dataModelFromDomain.linkedTaskId, scheduleEventDataModel.linkedTaskId);
      });
    });
  });
}
