import 'package:drift/drift.dart';
import '../schedule/schedule_segments.dart';
import 'transit_logs.dart';

@DataClassName('TransitSegmentLog')
@TableIndex(name: 'idx_transit_segment_logs_log_order', columns: {#transitLogId, #orderIndex})
@TableIndex(name: 'idx_transit_segment_logs_schedule_segment', columns: {#scheduleSegmentId})
class TransitSegmentLogs extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get transitLogId => integer().references(TransitLogs, #id, onDelete: KeyAction.cascade)();
    IntColumn get scheduleSegmentId => integer().nullable().references(ScheduleSegments, #id, onDelete: KeyAction.setNull)();
    TextColumn get transportMode => text()();
    TextColumn get segmentName => text()();
    IntColumn get orderIndex => integer()();
    DateTimeColumn get boardedAt => dateTime().nullable()();
    DateTimeColumn get alightedAt => dateTime().nullable()();
    IntColumn get actualDurationMinutes => integer().nullable()();
    TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, in_transit, completed, skipped
}