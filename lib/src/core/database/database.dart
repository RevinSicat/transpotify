import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'converters/days_of_week_converter.dart';
import 'schedule/schedules.dart';
import 'schedule/schedule_segments.dart';
import 'schedule/dao/schedule_dao.dart';
import 'transit/transit_logs.dart';
import 'transit/transit_segment_logs.dart';
import 'transit/dao/transit_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Schedules, ScheduleSegments, TransitLogs, TransitSegmentLogs],
  daos: [ScheduleDao, TransitDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'transpotify.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
