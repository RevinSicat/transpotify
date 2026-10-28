import 'package:drift/drift.dart';

import '../../database.dart';
import '../transit_logs.dart';
import '../transit_segment_logs.dart';
import '../transit_status.dart';

part 'transit_dao.g.dart';

class TransitLogWithSegments {
  const TransitLogWithSegments({required this.log, required this.segments});

  final TransitLog log;
  final List<TransitSegmentLog> segments;
}

@DriftAccessor(tables: [TransitLogs, TransitSegmentLogs])
class TransitDao extends DatabaseAccessor<AppDatabase> with _$TransitDaoMixin {
  TransitDao(super.db);

  // --------------------------------------------------------------------------- Active

  Future<TransitLog?> getActiveLog() => activeLogQuery().getSingleOrNull();

  Stream<TransitLog?> watchActiveLog() => activeLogQuery().watchSingleOrNull();

  Future<TransitLogWithSegments?> getActiveLogWithSegments() async {
    final log = await getActiveLog();
    if (log == null) return null;
    return TransitLogWithSegments(
      log: log,
      segments: await getSegmentLogsForLog(log.id),
    );
  }

  SimpleSelectStatement<$TransitLogsTable, TransitLog> activeLogQuery() {
    return select(transitLogs)
      ..where((l) => l.status.equals(TransitLogStatus.active))
      ..orderBy([(l) => OrderingTerm.desc(l.startedAt)])
      ..limit(1);
  }

  // --------------------------------------------------------------------------- Historical

  Future<List<TransitLog>> getHistoricalLogs({
      int? scheduleId,
      int limit = 50,
      int offset = 0,
  }) {
    return _historicalQuery(scheduleId, limit, offset).get();
  }

  Stream<List<TransitLog>> watchHistoricalLogs({
      int? scheduleId,
      int limit = 50,
      int offset = 0,
  }) {
    return _historicalQuery(scheduleId, limit, offset).watch();
  }

  SimpleSelectStatement<$TransitLogsTable, TransitLog> _historicalQuery(
      int? scheduleId,
      int limit,
      int offset,
  ) {
    final query = select(transitLogs)
      ..where((l) => l.status.isNotValue(TransitLogStatus.active));
    if (scheduleId != null) {
      query.where((l) => l.scheduleId.equals(scheduleId));
    }
    query
      ..orderBy([(l) => OrderingTerm.desc(l.startedAt)])
      ..limit(limit, offset: offset);
    return query;
  }

  // --------------------------------------------------------------------------- Segment logs

  Future<List<TransitSegmentLog>> getSegmentLogsForLog(int transitLogId) {
    return (select(transitSegmentLogs)
      ..where((s) => s.transitLogId.equals(transitLogId))
      ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();
  }

  Stream<List<TransitSegmentLog>> watchSegmentLogsForLog(int transitLogId) {
    return (select(transitSegmentLogs)
      ..where((s) => s.transitLogId.equals(transitLogId))
      ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .watch();
  }
}