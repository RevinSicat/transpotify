import 'package:drift/drift.dart';

import '../../../core/local/database.dart';
import '../../../core/local/base_dao.dart';
import '../../../core/local/tables/transit_segment_logs.dart';

part 'transit_segment_log_dao.g.dart';

@DriftAccessor(tables: [TransitSegmentLogs]) 
class TransitSegmentLogDao extends BaseDao<TransitSegmentLogs, TransitSegmentLog> with _$TransitSegmentLogDaoMixin {
    TransitSegmentLogDao(AppDatabase db) : super(db);

    @override
    TableInfo<TransitSegmentLogs, TransitSegmentLog> get table => transitSegmentLogs;
}