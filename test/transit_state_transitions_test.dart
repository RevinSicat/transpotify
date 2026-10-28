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
