import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';

class TransitHistoryEntry {
  const TransitHistoryEntry({
    required this.log,
    required this.scheduleName,
    required this.segments,
  });

  final TransitLog log;
  final String? scheduleName;
  final List<TransitHistorySegment> segments;
}

class TransitHistorySegment {
  const TransitHistorySegment({
    required this.log,
    required this.estimatedDurationMinutes,
  });

  final TransitSegmentLog log;
  final int? estimatedDurationMinutes;
}

final transitHistoryProvider = FutureProvider<List<TransitHistoryEntry>>((
  ref,
) async {
  final transitDao = ref.watch(transitDaoProvider);
  final scheduleDao = ref.watch(scheduleDaoProvider);
  final logs = await transitDao.getHistoricalLogs(limit: 100);
  final scheduleIds = logs
      .map((log) => log.scheduleId)
      .whereType<int>()
      .toSet();

  final schedules = <int, String>{};
  final estimatesBySchedule = <int, Map<int, int>>{};
  await Future.wait(
    scheduleIds.map((id) async {
      final schedule = await scheduleDao.getScheduleWithSegments(id);
      if (schedule == null) return;
      schedules[id] = schedule.schedule.name;
      estimatesBySchedule[id] = {
        for (final segment in schedule.segments)
          segment.id: segment.estimatedDurationMinutes,
      };
    }),
  );

  return Future.wait(
    logs.map((log) async {
      final segments = await transitDao.getSegmentLogsForLog(log.id);
      final estimates = estimatesBySchedule[log.scheduleId] ?? const {};
      return TransitHistoryEntry(
        log: log,
        scheduleName: schedules[log.scheduleId],
        segments: [
          for (final segment in segments)
            TransitHistorySegment(
              log: segment,
              estimatedDurationMinutes: estimates[segment.scheduleSegmentId],
            ),
        ],
      );
    }),
  );
});
