import 'package:drift/drift.dart';

@DataClassName('Schedule')
class Schedules extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get name => text().withLength(min: 1, max: 100)();
    
    IntColumn get targetStartTime => integer()(); 
    IntColumn get targetArrivalTime => integer()();
    
    TextColumn get daysOfWeek => text()();
    
    BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
