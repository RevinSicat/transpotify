// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transit_dao.dart';

// ignore_for_file: type=lint
mixin _$TransitDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $TransitLogsTable get transitLogs => attachedDatabase.transitLogs;
  $ScheduleSegmentsTable get scheduleSegments =>
      attachedDatabase.scheduleSegments;
  $TransitSegmentLogsTable get transitSegmentLogs =>
      attachedDatabase.transitSegmentLogs;
  TransitDaoManager get managers => TransitDaoManager(this);
}

class TransitDaoManager {
  final _$TransitDaoMixin _db;
  TransitDaoManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
  $$TransitLogsTableTableManager get transitLogs =>
      $$TransitLogsTableTableManager(_db.attachedDatabase, _db.transitLogs);
  $$ScheduleSegmentsTableTableManager get scheduleSegments =>
      $$ScheduleSegmentsTableTableManager(
        _db.attachedDatabase,
        _db.scheduleSegments,
      );
  $$TransitSegmentLogsTableTableManager get transitSegmentLogs =>
      $$TransitSegmentLogsTableTableManager(
        _db.attachedDatabase,
        _db.transitSegmentLogs,
      );
}
