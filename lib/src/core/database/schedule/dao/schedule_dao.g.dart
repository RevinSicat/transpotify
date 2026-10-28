// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduleDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $ScheduleSegmentsTable get scheduleSegments =>
      attachedDatabase.scheduleSegments;
  $TransitLogsTable get transitLogs => attachedDatabase.transitLogs;
  $TransitSegmentLogsTable get transitSegmentLogs =>
      attachedDatabase.transitSegmentLogs;
  ScheduleDaoManager get managers => ScheduleDaoManager(this);
}

class ScheduleDaoManager {
  final _$ScheduleDaoMixin _db;
  ScheduleDaoManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
  $$ScheduleSegmentsTableTableManager get scheduleSegments =>
      $$ScheduleSegmentsTableTableManager(
        _db.attachedDatabase,
        _db.scheduleSegments,
      );
  $$TransitLogsTableTableManager get transitLogs =>
      $$TransitLogsTableTableManager(_db.attachedDatabase, _db.transitLogs);
  $$TransitSegmentLogsTableTableManager get transitSegmentLogs =>
      $$TransitSegmentLogsTableTableManager(
        _db.attachedDatabase,
        _db.transitSegmentLogs,
      );
}
