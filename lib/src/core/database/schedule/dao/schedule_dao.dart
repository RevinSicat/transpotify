import 'package:drift/drift.dart';

import '../../database.dart';
import '../../transit/transit_segment_logs.dart';
import '../../transit/transit_status.dart';
import '../schedule_segments.dart';
import '../schedules.dart';

part 'schedule_dao.g.dart';

class ScheduleWithSegments {
  const ScheduleWithSegments({required this.schedule, required this.segments});

  final Schedule schedule;
  final List<ScheduleSegment> segments;

  int get estimatedTotalMinutes => segments.fold(0, (sum, s) => sum + s.estimatedDurationMinutes);
}

class SegmentAverage {
  const SegmentAverage({
    required this.segment,
    required this.averageMinutes,
    required this.sampleCount,
  });

  final ScheduleSegment segment;

  final double? averageMinutes;
  final int sampleCount;

  double get effectiveMinutes => averageMinutes ?? segment.estimatedDurationMinutes.toDouble();
}

@DriftAccessor(tables: [Schedules, ScheduleSegments, TransitSegmentLogs])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  // --------------------------------------------------------------------------- Create

  Future<int> createScheduleWithSegments(
      SchedulesCompanion schedule,
      List<ScheduleSegmentsCompanion> segments) {
    return transaction(() async {
      final scheduleId = await into(schedules).insert(schedule);
      for (var i = 0; i < segments.length; i++) {
        await into(scheduleSegments).insert(
          segments[i].copyWith(
            scheduleId: Value(scheduleId),
            orderIndex: Value(i),
          ),
        );
      }
      return scheduleId;
    });
  }

  // --------------------------------------------------------------------------- Read

  Future<List<Schedule>> getAllSchedules({bool activeOnly = false}) {
    final query = select(schedules);
    if (activeOnly) query.where((s) => s.isActive.equals(true));
    query.orderBy([(s) => OrderingTerm.asc(s.targetStartTime)]);
    return query.get();
  }

  Stream<List<Schedule>> watchAllSchedules({bool activeOnly = false}) {
    final query = select(schedules);
    if (activeOnly) query.where((s) => s.isActive.equals(true));
    query.orderBy([(s) => OrderingTerm.asc(s.targetStartTime)]);
    return query.watch();
  }

  Future<Schedule?> getScheduleById(int id) {
    return (select(schedules)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<List<ScheduleSegment>> getSegmentsForSchedule(int scheduleId) {
    return (select(scheduleSegments)
          ..where((s) => s.scheduleId.equals(scheduleId))
          ..orderBy([(s) => OrderingTerm.asc(s.orderIndex)]))
        .get();
  }

  Future<ScheduleWithSegments?> getScheduleWithSegments(int id) async {
    final schedule = await getScheduleById(id);
    if (schedule == null) return null;
    final segments = await getSegmentsForSchedule(id);
    return ScheduleWithSegments(schedule: schedule, segments: segments);
  }

  Stream<List<ScheduleWithSegments>> watchSchedulesWithSegments({bool activeOnly = false,}) {
    final query = select(schedules).join([
      leftOuterJoin(
        scheduleSegments,
        scheduleSegments.scheduleId.equalsExp(schedules.id),
      ),
    ]);
    if (activeOnly) query.where(schedules.isActive.equals(true));
    query.orderBy([
      OrderingTerm.asc(schedules.targetStartTime),
      OrderingTerm.asc(schedules.id),
      OrderingTerm.asc(scheduleSegments.orderIndex),
    ]);

    return query.watch().map((rows) {
      // Insertion-ordered map keeps the query's schedule ordering.
      final grouped = <int, ScheduleWithSegments>{};
      for (final row in rows) {
        final schedule = row.readTable(schedules);
        final segment = row.readTableOrNull(scheduleSegments);
        final existing = grouped[schedule.id];
        if (existing == null) {
          grouped[schedule.id] = ScheduleWithSegments(
            schedule: schedule,
            segments: [if (segment != null) segment],
          );
        } else if (segment != null) {
          existing.segments.add(segment);
        }
      }
      return grouped.values.toList();
    });
  }

  // --------------------------------------------------------------------------- Aggregation

  Future<List<SegmentAverage>> getSegmentAverages(int scheduleId) async {
    final avgMinutes = transitSegmentLogs.actualDurationMinutes.avg();
    final samples = transitSegmentLogs.id.count();

    final query = select(scheduleSegments).join([
            leftOuterJoin(
              transitSegmentLogs,
              transitSegmentLogs.scheduleSegmentId.equalsExp(
                    scheduleSegments.id,
                  ) &
                  transitSegmentLogs.status.equals(SegmentLogStatus.completed) &
                  transitSegmentLogs.actualDurationMinutes.isNotNull(),
            ),
          ])
          ..addColumns([avgMinutes, samples])
          ..where(scheduleSegments.scheduleId.equals(scheduleId))
          ..groupBy([scheduleSegments.id])
          ..orderBy([OrderingTerm.asc(scheduleSegments.orderIndex)]);

    final rows = await query.get();
    return rows.map(
          (row) => SegmentAverage(
            segment: row.readTable(scheduleSegments),
            averageMinutes: row.read(avgMinutes),
            sampleCount: row.read(samples) ?? 0,
          ),
        )
        .toList();
  }

  Future<double> getPredictedTotalMinutes(int scheduleId) async {
    final averages = await getSegmentAverages(scheduleId);
    return averages.fold<double>(0, (sum, a) => sum + a.effectiveMinutes);
  }

  // --------------------------------------------------------------------------- Update

  Future<bool> setScheduleActive(int id, bool isActive) async {
    final updated = await (update(schedules)..where((s) => s.id.equals(id)))
        .write(SchedulesCompanion(isActive: Value(isActive)));
    return updated > 0;
  }

  Future<int> deleteSchedule(int id) {
    return (delete(schedules)..where((s) => s.id.equals(id))).go();
  }
}
