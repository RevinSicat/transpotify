import 'package:drift/drift.dart';
import 'transit_logs.dart';
import 'schedule_segments.dart';

@DataClassName('TransitSegmentLog')
class TransitSegmentLogs extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get transitLogId => integer().references(TransitLogs, #id)();
    IntColumn get scheduleSegmentId => integer().references(ScheduleSegments, #id)();

    DateTimeColumn get boardedAt => dateTime().nullable()();
    DateTimeColumn get alightedAt => dateTime().nullable()();

    IntColumn get actualDurationMinutes => integer().nullable()(); 
}