// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_segment_dao.dart';

// ignore_for_file: type=lint
mixin _$ScheduleSegmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $ScheduleSegmentsTable get scheduleSegments =>
      attachedDatabase.scheduleSegments;
  ScheduleSegmentDaoManager get managers => ScheduleSegmentDaoManager(this);
}

class ScheduleSegmentDaoManager {
  final _$ScheduleSegmentDaoMixin _db;
  ScheduleSegmentDaoManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
  $$ScheduleSegmentsTableTableManager get scheduleSegments =>
      $$ScheduleSegmentsTableTableManager(
        _db.attachedDatabase,
        _db.scheduleSegments,
      );
}
