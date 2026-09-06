import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

import '../../features/schedule/data/schedule_dao.dart';
import '../../features/schedule/data/schedule_repository.dart';
import '../../features/schedule/data/schedule_segment_dao.dart';
import '../../features/schedule/data/schedule_segment_repository.dart';
import '../../features/transit_log/data/transit_log_dao.dart';
import '../../features/transit_log/data/transit_log_repository.dart';
import '../../features/transit_log/data/transit_segment_log_dao.dart';
import '../../features/transit_log/data/transit_segment_log_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
    final db = AppDatabase();
    ref.onDispose(db.close);
    return db;
});

// --- Schedules (the plan) ---------------------------------------------

final scheduleDaoProvider = Provider<ScheduleDao>((ref) {
    return ScheduleDao(ref.watch(appDatabaseProvider));
});

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
    return ScheduleRepository(ref.watch(scheduleDaoProvider));
});

final scheduleSegmentDaoProvider = Provider<ScheduleSegmentDao>((ref) {
    return ScheduleSegmentDao(ref.watch(appDatabaseProvider));
});

final scheduleSegmentRepositoryProvider = Provider<ScheduleSegmentRepository>((ref) {
    return ScheduleSegmentRepository(ref.watch(scheduleSegmentDaoProvider));
});

// --- Transit logs (the execution) --------------------------------------

final transitLogDaoProvider = Provider<TransitLogDao>((ref) {
    return TransitLogDao(ref.watch(appDatabaseProvider));
});

final transitLogRepositoryProvider = Provider<TransitLogRepository>((ref) {
    return TransitLogRepository(ref.watch(transitLogDaoProvider));
});

final transitSegmentLogDaoProvider = Provider<TransitSegmentLogDao>((ref) {
    return TransitSegmentLogDao(ref.watch(appDatabaseProvider));
});

final transitSegmentLogRepositoryProvider = Provider<TransitSegmentLogRepository>((ref) {
    return TransitSegmentLogRepository(
        ref.watch(transitSegmentLogDaoProvider),
    );
});