import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/utils/common_utilities.dart';
import '../../../core/database/database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/schedule/dao/schedule_dao.dart';

final schedulesProvider = StreamProvider<List<ScheduleWithSegments>>(
  (ref) => ref.watch(scheduleDaoProvider).watchSchedulesWithSegments(),
);

final scheduleVarianceProvider = FutureProvider.family<DurationVariance, int>((
  ref,
  scheduleId,
) async {
  final scheduleDao = ref.watch(scheduleDaoProvider);
  final transitDao = ref.watch(transitDaoProvider);
  final schedule = await scheduleDao.getScheduleById(scheduleId);
  if (schedule == null) {
    throw StateError('Schedule $scheduleId not found');
  }

  return CommonUtilities.computeVariance(
    targetStartTime: schedule.targetStartTime,
    targetArrivalTime: schedule.targetArrivalTime,
    completedDurations: await transitDao.getCompletedDurations(scheduleId),
  );
});

final segmentAveragesProvider =
    FutureProvider.family<List<SegmentAverage>, int>(
      (ref, scheduleId) =>
          ref.watch(scheduleDaoProvider).getSegmentAverages(scheduleId),
    );

final scheduleByIdProvider = FutureProvider.family<Schedule?, int>(
  (ref, scheduleId) =>
      ref.watch(scheduleDaoProvider).getScheduleById(scheduleId),
);

final scheduleControllerProvider =
    AsyncNotifierProvider<ScheduleController, void>(ScheduleController.new);

class ScheduleController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createSchedule({
    required SchedulesCompanion schedule,
    required List<ScheduleSegmentsCompanion> segments,
  }) => _run(
    () => ref
        .read(scheduleDaoProvider)
        .createScheduleWithSegments(schedule, segments),
  );

  Future<void> updateSchedule({
    required int scheduleId,
    required SchedulesCompanion schedule,
    required List<ScheduleSegmentsCompanion> segments,
  }) => _run(
    () => ref
        .read(scheduleDaoProvider)
        .updateScheduleWithSegments(scheduleId, schedule, segments),
  );

  Future<void> setActive(int scheduleId, bool isActive) => _run(() async {
    final updated = await ref
        .read(scheduleDaoProvider)
        .setScheduleActive(scheduleId, isActive);
    if (!updated) throw StateError('Schedule $scheduleId not found');
  });

  Future<void> deleteSchedule(int scheduleId) => _run(() async {
    final deleted = await ref
        .read(scheduleDaoProvider)
        .deleteSchedule(scheduleId);
    if (deleted == 0) throw StateError('Schedule $scheduleId not found');
  });

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    state = result;
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
  }
}
