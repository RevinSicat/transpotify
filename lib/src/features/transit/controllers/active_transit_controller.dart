import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_providers.dart';
import '../../../core/database/transit/dao/transit_dao.dart';

/// Read side: the active commute with its segments, or null when idle.
/// Re-emits automatically whenever the log or any segment changes.
final activeTransitProvider = StreamProvider<TransitLogWithSegments?>(
  (ref) => ref.watch(transitDaoProvider).watchActiveLogWithSegments(),
);

/// Write side: state transitions. The provider's own state is the status of
/// the last action (loading / error / data) so the UI can disable buttons and
/// show failures, e.g. `ref.listen(activeTransitControllerProvider, ...)`.
final activeTransitControllerProvider =
    AsyncNotifierProvider<ActiveTransitController, void>(
      ActiveTransitController.new,
    );

class ActiveTransitController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Creates the active log + pending segment logs from a schedule's segments.
  Future<void> startCommute(int scheduleId) => _run(() async {
    final schedule = await ref
        .read(scheduleDaoProvider)
        .getScheduleWithSegments(scheduleId);
    if (schedule == null) {
      throw InvalidTransitionException('Schedule $scheduleId not found');
    }
    await ref
        .read(transitDaoProvider)
        .startCommute(scheduleId: scheduleId, segments: schedule.segments);
  });

  /// Stamps `boardedAt = now` and marks the segment in transit.
  Future<void> boardSegment(int segmentLogId) =>
      _run(() => ref.read(transitDaoProvider).boardSegment(segmentLogId));

  /// Stamps `alightedAt = now` and computes `actualDurationMinutes`.
  Future<void> alightSegment(int segmentLogId) =>
      _run(() => ref.read(transitDaoProvider).alightSegment(segmentLogId));

  /// Marks the commute completed (`endedAt` = completion time).
  Future<void> completeCommute(int transitLogId) =>
      _run(() => ref.read(transitDaoProvider).completeCommute(transitLogId));

  // Extras beyond the spec, needed so a missed tap can't trap the user:
  Future<void> skipSegment(int segmentLogId) =>
      _run(() => ref.read(transitDaoProvider).skipSegment(segmentLogId));

  Future<void> cancelCommute(int transitLogId) =>
      _run(() => ref.read(transitDaoProvider).cancelCommute(transitLogId));

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(action);
    state = result;
    if (result.hasError) {
      Error.throwWithStackTrace(result.error!, result.stackTrace!);
    }
  }
}
