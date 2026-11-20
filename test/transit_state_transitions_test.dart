import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transpotify/src/core/database/database.dart';
import 'package:transpotify/src/core/database/database_providers.dart';
import 'package:transpotify/src/core/database/transit/dao/transit_dao.dart';
import 'package:transpotify/src/core/database/transit/transit_status.dart';
import 'package:transpotify/src/features/transit/controllers/active_transit_controller.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  test('commute transitions timestamp segments and complete the log', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 2);
    final schedule = await database.scheduleDao.getScheduleWithSegments(
      scheduleId,
    );
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    final transitLogId = await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );
    var transit = await dao.getActiveLogWithSegments();
    expect(transit!.log.status, TransitLogStatus.active);
    expect(transit.segments, hasLength(2));
    expect(
      transit.segments.map((segment) => segment.status),
      everyElement(SegmentLogStatus.pending),
    );

    final firstSegmentId = transit.segments[0].id;
    final secondSegmentId = transit.segments[1].id;
    await expectLater(
      dao.boardSegment(
        secondSegmentId,
        now: start.add(const Duration(minutes: 1)),
      ),
      throwsA(isA<InvalidTransitionException>()),
    );

    final firstBoardedAt = start.add(const Duration(minutes: 1));
    final firstAlightedAt = start.add(const Duration(minutes: 4));
    await dao.boardSegment(firstSegmentId, now: firstBoardedAt);
    await dao.alightSegment(firstSegmentId, now: firstAlightedAt);

    transit = await dao.getActiveLogWithSegments();
    expect(transit!.segments[0].boardedAt, firstBoardedAt);
    expect(transit.segments[0].alightedAt, firstAlightedAt);
    expect(transit.segments[0].actualDurationMinutes, 3);
    expect(transit.segments[0].status, SegmentLogStatus.completed);
    await expectLater(
      dao.alightSegment(firstSegmentId),
      throwsA(isA<InvalidTransitionException>()),
    );

    final secondBoardedAt = start.add(const Duration(minutes: 5));
    final secondAlightedAt = start.add(const Duration(minutes: 10));
    await dao.boardSegment(secondSegmentId, now: secondBoardedAt);
    await dao.alightSegment(secondSegmentId, now: secondAlightedAt);
    await dao.completeCommute(
      transitLogId,
      now: start.add(const Duration(minutes: 20)),
    );

    final completed = await (database.select(
      database.transitLogs,
    )..where((log) => log.id.equals(transitLogId))).getSingle();
    expect(completed.status, TransitLogStatus.completed);
    expect(completed.endedAt, start.add(const Duration(minutes: 20)));
    expect(completed.totalDurationMinutes, 20);
  });

  test('controller exposes commute transitions through its provider', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 1);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    final controller = container.read(activeTransitControllerProvider.notifier);

    await controller.startCommute(scheduleId);
    var transit = await database.transitDao.getActiveLogWithSegments();
    expect(transit, isNotNull);
    expect(transit!.segments.single.status, SegmentLogStatus.pending);

    await controller.boardSegment(transit.segments.single.id);
    await controller.alightSegment(transit.segments.single.id);
    final segment = (await database.transitDao.getSegmentLogsForLog(
      transit.log.id,
    )).single;
    expect(segment.boardedAt, isNotNull);
    expect(segment.alightedAt, isNotNull);
    expect(segment.actualDurationMinutes, isNotNull);

    await controller.completeCommute(transit.log.id);
    final completed = await (database.select(
      database.transitLogs,
    )..where((log) => log.id.equals(transit.log.id))).getSingle();
    expect(completed.status, TransitLogStatus.completed);
    expect(completed.endedAt, isNotNull);
  });

  test('undoBoardSegment reverts in-transit segment back to pending', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 2);
    final schedule = await database.scheduleDao.getScheduleWithSegments(scheduleId);
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );

    var transit = await dao.getActiveLogWithSegments();
    final firstSegmentId = transit!.segments[0].id;

    await dao.boardSegment(firstSegmentId, now: start.add(const Duration(minutes: 1)));
    transit = await dao.getActiveLogWithSegments();
    expect(transit!.segments[0].status, SegmentLogStatus.inTransit);
    expect(transit.segments[0].boardedAt, isNotNull);

    await dao.undoBoardSegment(firstSegmentId);
    transit = await dao.getActiveLogWithSegments();
    expect(transit!.segments[0].status, SegmentLogStatus.pending);
    expect(transit.segments[0].boardedAt, isNull);
  });

  test('resetSegment clears timestamps and sets completed/skipped segment to pending', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 2);
    final schedule = await database.scheduleDao.getScheduleWithSegments(scheduleId);
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );

    var transit = await dao.getActiveLogWithSegments();
    final firstSegmentId = transit!.segments[0].id;

    await dao.boardSegment(firstSegmentId, now: start);
    await dao.alightSegment(firstSegmentId, now: start.add(const Duration(minutes: 5)));

    transit = await dao.getActiveLogWithSegments();
    expect(transit!.segments[0].status, SegmentLogStatus.completed);
    expect(transit.segments[0].actualDurationMinutes, 5);

    await dao.resetSegment(firstSegmentId);
    transit = await dao.getActiveLogWithSegments();
    expect(transit!.segments[0].status, SegmentLogStatus.pending);
    expect(transit.segments[0].boardedAt, isNull);
    expect(transit.segments[0].alightedAt, isNull);
    expect(transit.segments[0].actualDurationMinutes, isNull);
  });

  test('resetCommute resets all segments without cancelling the active transit log', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 2);
    final schedule = await database.scheduleDao.getScheduleWithSegments(scheduleId);
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    final transitLogId = await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );

    var transit = await dao.getActiveLogWithSegments();
    final firstSegmentId = transit!.segments[0].id;
    final secondSegmentId = transit.segments[1].id;

    await dao.boardSegment(firstSegmentId, now: start);
    await dao.alightSegment(firstSegmentId, now: start.add(const Duration(minutes: 4)));
    await dao.boardSegment(secondSegmentId, now: start.add(const Duration(minutes: 5)));

    await dao.resetCommute(transitLogId);

    transit = await dao.getActiveLogWithSegments();
    expect(transit, isNotNull);
    expect(transit!.log.status, TransitLogStatus.active);
    expect(
      transit.segments.map((s) => s.status),
      everyElement(SegmentLogStatus.pending),
    );
    expect(
      transit.segments.map((s) => s.boardedAt),
      everyElement(isNull),
    );
    expect(
      transit.segments.map((s) => s.alightedAt),
      everyElement(isNull),
    );
    expect(
      transit.segments.map((s) => s.actualDurationMinutes),
      everyElement(isNull),
    );
  });

  test('updateSegmentTimestamps recalculates segment duration and completed log totals', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 1);
    final schedule = await database.scheduleDao.getScheduleWithSegments(scheduleId);
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    final transitLogId = await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );

    var transit = await dao.getActiveLogWithSegments();
    final segmentId = transit!.segments.single.id;

    await dao.boardSegment(segmentId, now: start);
    await dao.alightSegment(segmentId, now: start.add(const Duration(minutes: 10)));
    await dao.completeCommute(transitLogId, now: start.add(const Duration(minutes: 10)));

    var segment = (await dao.getSegmentLogsForLog(transitLogId)).single;
    expect(segment.actualDurationMinutes, 10);

    // Adjust board time from 8:00 to 8:03 (making duration 7 mins)
    await dao.updateSegmentTimestamps(
      segmentId,
      boardedAt: start.add(const Duration(minutes: 3)),
    );

    segment = (await dao.getSegmentLogsForLog(transitLogId)).single;
    expect(segment.actualDurationMinutes, 7);
    expect(segment.boardedAt, start.add(const Duration(minutes: 3)));

    final log = await (database.select(database.transitLogs)
          ..where((l) => l.id.equals(transitLogId)))
        .getSingle();
    expect(log.totalDurationMinutes, 7);

    // Throws exception if alight is before board
    await expectLater(
      dao.updateSegmentTimestamps(
        segmentId,
        alightedAt: start.add(const Duration(minutes: 1)),
      ),
      throwsA(isA<InvalidTransitionException>()),
    );
  });

  test('updateCommuteStartedAt updates active and completed commute start time', () async {
    final scheduleId = await _createSchedule(database, segmentCount: 1);
    final schedule = await database.scheduleDao.getScheduleWithSegments(scheduleId);
    final dao = database.transitDao;
    final start = DateTime(2026, 1, 1, 8);

    final transitLogId = await dao.startCommute(
      scheduleId: scheduleId,
      segments: schedule!.segments,
      now: start,
    );

    // Update active commute startedAt from 8:00 to 7:55
    final adjustedStart = DateTime(2026, 1, 1, 7, 55);
    await dao.updateCommuteStartedAt(transitLogId, adjustedStart);

    var transit = await dao.getActiveLogWithSegments();
    expect(transit!.log.startedAt, adjustedStart);

    // Complete commute at 8:15
    final segmentId = transit.segments.single.id;
    await dao.boardSegment(segmentId, now: adjustedStart);
    await dao.alightSegment(segmentId, now: DateTime(2026, 1, 1, 8, 15));
    await dao.completeCommute(transitLogId, now: DateTime(2026, 1, 1, 8, 15));

    var log = await (database.select(database.transitLogs)
          ..where((l) => l.id.equals(transitLogId)))
        .getSingle();
    expect(log.totalDurationMinutes, 20);

    // Update completed commute startedAt to 7:50 (duration becomes 25)
    final adjustedStart2 = DateTime(2026, 1, 1, 7, 50);
    await dao.updateCommuteStartedAt(transitLogId, adjustedStart2);

    log = await (database.select(database.transitLogs)
          ..where((l) => l.id.equals(transitLogId)))
        .getSingle();
    expect(log.startedAt, adjustedStart2);
    expect(log.totalDurationMinutes, 25);

    // Throws exception if startedAt is after endedAt
    await expectLater(
      dao.updateCommuteStartedAt(
        transitLogId,
        DateTime(2026, 1, 1, 8, 30),
      ),
      throwsA(isA<InvalidTransitionException>()),
    );
  });
}

Future<int> _createSchedule(AppDatabase database, {required int segmentCount}) {
  return database.scheduleDao.createScheduleWithSegments(
    SchedulesCompanion.insert(
      name: 'Morning commute',
      targetStartTime: '08:00',
      targetArrivalTime: '09:00',
      daysOfWeek: const [1],
    ),
    List.generate(
      segmentCount,
      (index) => ScheduleSegmentsCompanion.insert(
        scheduleId: 0,
        name: 'Segment $index',
        transportMode: index == 0 ? 'walk' : 'bus',
        orderIndex: index,
        estimatedDurationMinutes: 5,
      ),
    ),
  );
}
