// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transit_log_dao.dart';

// ignore_for_file: type=lint
mixin _$TransitLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $SchedulesTable get schedules => attachedDatabase.schedules;
  $TransitLogsTable get transitLogs => attachedDatabase.transitLogs;
  TransitLogDaoManager get managers => TransitLogDaoManager(this);
}

class TransitLogDaoManager {
  final _$TransitLogDaoMixin _db;
  TransitLogDaoManager(this._db);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db.attachedDatabase, _db.schedules);
  $$TransitLogsTableTableManager get transitLogs =>
      $$TransitLogsTableTableManager(_db.attachedDatabase, _db.transitLogs);
}
