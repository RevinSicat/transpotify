import 'package:drift/drift.dart';

import '../../../core/local/database.dart';
import '../../../core/local/base_dao.dart';
import '../../../core/local/tables/schedule_segments.dart';

part 'schedule_segment_dao.g.dart';

@DriftAccessor(tables: [ScheduleSegments]) 
class ScheduleSegmentDao extends BaseDao<ScheduleSegments, ScheduleSegment> with _$ScheduleSegmentDaoMixin {
    ScheduleSegmentDao(AppDatabase db) : super(db);

    @override
    TableInfo<ScheduleSegments, ScheduleSegment> get table => scheduleSegments;
}