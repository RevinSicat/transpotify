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

/// Thrown when an action isn't allowed from the current state
/// (e.g. boarding a segment that's already completed).
class InvalidTransitionException implements Exception {
  const InvalidTransitionException(this.message);

  final String message;

  @override
  String toString() => 'InvalidTransitionException: $message';
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

  /// Reactive active log + segments. A single joined query, so it re-emits
  /// when either the log row or any of its segment rows change.
  Stream<TransitLogWithSegments?> watchActiveLogWithSegments() {
    final query = select(transitLogs).join([
      leftOuterJoin(
        transitSegmentLogs,
        transitSegmentLogs.transitLogId.equalsExp(transitLogs.id),
      ),
    ])
      ..where(transitLogs.status.equals(TransitLogStatus.active))
      ..orderBy([
        OrderingTerm.desc(transitLogs.startedAt),
        OrderingTerm.desc(transitLogs.id),
        OrderingTerm.asc(transitSegmentLogs.orderIndex),
      ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final log = rows.first.readTable(transitLogs);
      final segments = <TransitSegmentLog>[];
      for (final row in rows) {
        if (row.readTable(transitLogs).id != log.id) break; // only the newest active log
        final segment = row.readTableOrNull(transitSegmentLogs);
        if (segment != null) segments.add(segment);
      }
      return TransitLogWithSegments(log: log, segments: segments);
    });
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

  /// `totalDurationMinutes` of every completed log for a schedule
  /// (input for `CommonUtilities.computeVariance`).
  Future<List<int>> getCompletedDurations(int scheduleId) async {
    final logs = await (select(transitLogs)
      ..where((l) =>
      l.scheduleId.equals(scheduleId) &
      l.status.equals(TransitLogStatus.completed) &
      l.totalDurationMinutes.isNotNull()))
        .get();
    return logs.map((l) => l.totalDurationMinutes!).toList();
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

  // --------------------------------------------------------------------------- State transitions
  //
  // Every transition runs in a transaction and validates the current state, so
  // the database can never hold e.g. two active commutes or a segment that was
  // alighted without being boarded. `now` is injectable for tests.

  /// Creates an active [TransitLog] plus one `pending` segment log per
  /// schedule segment (name/mode snapshotted so history survives schedule
  /// edits). Returns the new log id.
  Future<int> startCommute({
      required int scheduleId,
      required List<ScheduleSegment> segments,
      DateTime? now,
  }) {
    return transaction(() async {
      if (segments.isEmpty) {
        throw const InvalidTransitionException('Schedule has no segments');
      }
      if (await getActiveLog() != null) {
        throw const InvalidTransitionException('A commute is already active');
      }

      final logId = await into(transitLogs).insert(
        TransitLogsCompanion.insert(
          scheduleId: Value(scheduleId),
          startedAt: now ?? DateTime.now(),
        ),
      );
      for (var i = 0; i < segments.length; i++) {
        final s = segments[i];
        await into(transitSegmentLogs).insert(
          TransitSegmentLogsCompanion.insert(
            transitLogId: logId,
            scheduleSegmentId: Value(s.id),
            transportMode: s.transportMode,
            segmentName: s.name,
            orderIndex: i,
          ),
        );
      }
      return logId;
    });
  }

  /// pending -> in_transit. Earlier segments must be completed or skipped.
  Future<void> boardSegment(int segmentLogId, {DateTime? now}) {
    return transaction(() async {
      final segment = await _requireSegment(segmentLogId);
      await _requireActiveLog(segment.transitLogId);
      _requireStatus(segment, SegmentLogStatus.pending, 'board');

      final siblings = await getSegmentLogsForLog(segment.transitLogId);
      final blocking = siblings.where((s) =>
      s.orderIndex < segment.orderIndex &&
          s.status != SegmentLogStatus.completed &&
          s.status != SegmentLogStatus.skipped);
      if (blocking.isNotEmpty) {
        throw InvalidTransitionException(
            'Finish or skip "${blocking.first.segmentName}" first');
      }

      await _updateSegment(
        segmentLogId,
        TransitSegmentLogsCompanion(
          boardedAt: Value(now ?? DateTime.now()),
          status: const Value(SegmentLogStatus.inTransit),
        ),
      );
    });
  }

  /// in_transit -> completed. Duration is computed here from the stored
  /// boardedAt, never accepted from the UI.
  Future<void> alightSegment(int segmentLogId, {DateTime? now}) {
    return transaction(() async {
      final segment = await _requireSegment(segmentLogId);
      await _requireActiveLog(segment.transitLogId);
      _requireStatus(segment, SegmentLogStatus.inTransit, 'alight');

      final alightedAt = now ?? DateTime.now();
      await _updateSegment(
        segmentLogId,
        TransitSegmentLogsCompanion(
          alightedAt: Value(alightedAt),
          actualDurationMinutes: Value(_minutesBetween(segment.boardedAt!, alightedAt)),
          status: const Value(SegmentLogStatus.completed),
        ),
      );
    });
  }

  /// pending -> skipped, for legs you didn't take today. Skipped segments are
  /// ignored by the averages.
  Future<void> skipSegment(int segmentLogId) {
    return transaction(() async {
      final segment = await _requireSegment(segmentLogId);
      await _requireActiveLog(segment.transitLogId);
      _requireStatus(segment, SegmentLogStatus.pending, 'skip');
      await _updateSegment(
        segmentLogId,
        const TransitSegmentLogsCompanion(status: Value(SegmentLogStatus.skipped)),
      );
    });
  }

  /// active -> completed. Every segment must be completed or skipped.
  /// `endedAt` is the "completedAt" timestamp; `totalDurationMinutes` is
  /// door-to-door (startedAt -> endedAt).
  Future<void> completeCommute(int transitLogId, {DateTime? now}) {
    return transaction(() async {
      final log = await _requireActiveLog(transitLogId);

      final open = (await getSegmentLogsForLog(transitLogId)).where((s) =>
      s.status == SegmentLogStatus.pending ||
          s.status == SegmentLogStatus.inTransit);
      if (open.isNotEmpty) {
        throw InvalidTransitionException(
            'Finish or skip "${open.first.segmentName}" before completing');
      }

      final endedAt = now ?? DateTime.now();
      await (update(transitLogs)..where((l) => l.id.equals(transitLogId))).write(
        TransitLogsCompanion(
          status: const Value(TransitLogStatus.completed),
          endedAt: Value(endedAt),
          totalDurationMinutes: Value(_minutesBetween(log.startedAt, endedAt)),
        ),
      );
    });
  }

  /// active -> cancelled. Unfinished segments become skipped; segments that
  /// were already completed keep their data.
  Future<void> cancelCommute(int transitLogId, {DateTime? now}) {
    return transaction(() async {
      await _requireActiveLog(transitLogId);

      await (update(transitSegmentLogs)
        ..where((s) =>
        s.transitLogId.equals(transitLogId) &
        s.status.isIn([SegmentLogStatus.pending, SegmentLogStatus.inTransit])))
          .write(const TransitSegmentLogsCompanion(
          status: Value(SegmentLogStatus.skipped)));

      await (update(transitLogs)..where((l) => l.id.equals(transitLogId))).write(
        TransitLogsCompanion(
          status: const Value(TransitLogStatus.cancelled),
          endedAt: Value(now ?? DateTime.now()),
        ),
      );
    });
  }

  // --------------------------------------------------------------------------- Helpers

  /// Whole minutes between two instants, rounded, never negative.
  int _minutesBetween(DateTime from, DateTime to) {
    final seconds = to.difference(from).inSeconds;
    return seconds <= 0 ? 0 : (seconds / 60).round();
  }

  Future<TransitSegmentLog> _requireSegment(int id) async {
    final segment = await (select(transitSegmentLogs)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (segment == null) {
      throw InvalidTransitionException('Segment log $id not found');
    }
    return segment;
  }

  Future<TransitLog> _requireActiveLog(int id) async {
    final log = await (select(transitLogs)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
    if (log == null) throw InvalidTransitionException('Commute $id not found');
    if (log.status != TransitLogStatus.active) {
      throw InvalidTransitionException('Commute $id is ${log.status}, not active');
    }
    return log;
  }

  void _requireStatus(TransitSegmentLog segment, String expected, String action) {
    if (segment.status != expected) {
      throw InvalidTransitionException(
          'Cannot $action "${segment.segmentName}": it is ${segment.status}');
    }
  }

  Future<void> _updateSegment(int id, TransitSegmentLogsCompanion values) {
    return (update(transitSegmentLogs)..where((s) => s.id.equals(id))).write(values);
  }
}