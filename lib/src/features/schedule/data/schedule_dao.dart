import 'package:drift/drift.dart';

import '../../../core/local/database.dart';
import '../../../core/local/base_dao.dart';
import '../../../core/local/tables/schedules.dart';

part 'schedule_dao.g.dart';

@DriftAccessor(tables: [Schedules]) 
class ScheduleDao extends BaseDao<Schedules, Schedule> with _$ScheduleDaoMixin {
    ScheduleDao(AppDatabase db) : super(db);

    @override
    TableInfo<Schedules, Schedule> get table => schedules;
}