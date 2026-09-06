import 'package:drift/drift.dart';

import '../../../core/local/database.dart';
import '../../../core/local/base_dao.dart';
import '../../../core/local/tables/transit_logs.dart';

part 'transit_log_dao.g.dart';

@DriftAccessor(tables: [TransitLogs]) 
class TransitLogDao extends BaseDao<TransitLogs, TransitLog> with _$TransitLogDaoMixin {
    TransitLogDao(AppDatabase db) : super(db);

    @override
    TableInfo<TransitLogs, TransitLog> get table => transitLogs;
}