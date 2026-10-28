import 'package:drift/drift.dart';
import '../converters/days_of_week_converter.dart';

@DataClassName('Schedule')
class Schedules extends Table {
    IntColumn get id => integer().autoIncrement()();

    TextColumn get name => text().withLength(min: 1, max: 100)();
    TextColumn get targetStartTime => text()(); // Format: "HH:mm"
    TextColumn get targetArrivalTime => text()(); // Format: "HH:mm"
    TextColumn get daysOfWeek => text().map(const DaysOfWeekConverter())(); // e.g. [1, 2, 3, 4, 5]

    BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}