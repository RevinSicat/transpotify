import 'package:drift/drift.dart';
import 'schedules.dart';

@DataClassName('TransitLog')
class TransitLogs extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get scheduleId => integer().references(Schedules, #id)();
    
    DateTimeColumn get date => dateTime()();
    TextColumn get status => text()();
}