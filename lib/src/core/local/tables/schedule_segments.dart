import 'package:drift/drift.dart';
import 'schedules.dart';

@DataClassName('ScheduleSegment')
class ScheduleSegments extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get scheduleId => integer().references(Schedules, #id)();
    
    TextColumn get transportMode => text()();
    TextColumn get name => text().withDefault(const Constant(''))();
    IntColumn get orderIndex => integer()();

    IntColumn get estimatedDurationMinutes => integer().nullable()(); 
}