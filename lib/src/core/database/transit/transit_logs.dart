import 'package:drift/drift.dart';
import '../schedule/schedules.dart';

@DataClassName('TransitLog')
@TableIndex(name: 'idx_transit_logs_schedule', columns: {#scheduleId})
@TableIndex(name: 'idx_transit_logs_started_at', columns: {#startedAt})
@TableIndex(name: 'idx_transit_logs_status', columns: {#status})
class TransitLogs extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get scheduleId => integer().nullable().references(Schedules, #id, onDelete: KeyAction.setNull)();
    DateTimeColumn get startedAt => dateTime()();
    DateTimeColumn get endedAt => dateTime().nullable()();
    TextColumn get status => text().withDefault(const Constant('active'))(); // active, completed, cancelled
    IntColumn get totalDurationMinutes => integer().nullable()();
}