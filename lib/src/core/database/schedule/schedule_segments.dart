import 'package:drift/drift.dart';
import 'schedules.dart';

@DataClassName('ScheduleSegment')
@TableIndex(name: 'idx_schedule_segments_schedule_order', columns: {#scheduleId, #orderIndex})
class ScheduleSegments extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get scheduleId => integer().references(Schedules, #id, onDelete: KeyAction.cascade)();
    TextColumn get name => text()();
    TextColumn get transportMode => text()(); // bus, train, walk, car, motorcycle, bike
    IntColumn get orderIndex => integer()();
    IntColumn get estimatedDurationMinutes => integer()();
}