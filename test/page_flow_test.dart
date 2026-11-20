import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpotify/src/core/database/database.dart';
import 'package:transpotify/src/core/database/database_providers.dart';
import 'package:transpotify/src/core/navigation/app_router.dart';
import 'package:transpotify/src/pages/schedule_page.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('schedule page creates a schedule with route segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: SchedulePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('New schedule'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Weekday commute');
    await tester.enterText(fields.at(3), 'Walk to station');
    await tester.tap(find.byTooltip('Monday'));
    await tester.ensureVisible(find.text('Save schedule'));
    await tester.tap(find.text('Save schedule'));
    await tester.pumpAndSettle();

    final schedules = await database.scheduleDao.getAllSchedules();
    expect(schedules, hasLength(1));
    expect(schedules.single.name, 'Weekday commute');
    final route = await database.scheduleDao.getScheduleWithSegments(
      schedules.single.id,
    );
    expect(route!.segments, hasLength(1));
    expect(route.segments.single.name, 'Walk to station');
    expect(find.text('Weekday commute'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('home to active commute to completed history', (tester) async {
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Test commute',
        targetStartTime: '08:00',
        targetArrivalTime: '08:30',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Walk to bus',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 5,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transpotify'), findsOneWidget);
    expect(find.text('Start Commute'), findsOneWidget);
    await tester.tap(find.text('Start Commute'));
    await tester.pumpAndSettle();

    expect(find.text('Active commute'), findsOneWidget);
    expect(find.text('Test commute'), findsOneWidget);
    await tester.tap(find.text('Board Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alight Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete commute'));
    await tester.pumpAndSettle();

    expect(find.text('Commute history'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.text('Test commute'));
    await tester.pumpAndSettle();
    expect(find.text('Walk to bus'), findsOneWidget);
    expect(find.textContaining('Actual '), findsOneWidget);

    final logs = await database.transitDao.getHistoricalLogs();
    expect(logs, hasLength(1));
    expect(logs.single.scheduleId, scheduleId);
    expect(logs.single.status, 'completed');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('active commute undo board and reset commute page flow', (tester) async {
    appRouter.go('/');
    await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Reset flow commute',
        targetStartTime: '08:00',
        targetArrivalTime: '08:30',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'First leg',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 5,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start Commute'), findsOneWidget);
    await tester.tap(find.text('Start Commute'));
    await tester.pumpAndSettle();

    // 1. Board and Undo Board
    expect(find.text('Board Walk'), findsOneWidget);
    await tester.tap(find.text('Board Walk'));
    await tester.pumpAndSettle();

    expect(find.text('Alight Walk'), findsOneWidget);
    expect(find.text('Undo board'), findsOneWidget);

    await tester.tap(find.text('Undo board'));
    await tester.pumpAndSettle();

    expect(find.text('Board Walk'), findsOneWidget);
    expect(find.text('Undo board'), findsNothing);

    // 2. Board, Alight, then Reset Commute via overflow menu
    await tester.tap(find.text('Board Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alight Walk'));
    await tester.pumpAndSettle();

    expect(find.text('All segments finished'), findsOneWidget);

    await tester.tap(find.byTooltip('Commute options'));
    await tester.pumpAndSettle();

    expect(find.text('Reset commute'), findsOneWidget);
    await tester.tap(find.text('Reset commute'));
    await tester.pumpAndSettle();

    expect(find.text('Reset this commute?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reset commute'));
    await tester.pumpAndSettle();

    // Commute is back to initial active state with 'Board Walk'
    expect(find.text('Board Walk'), findsOneWidget);
    var active = await database.transitDao.getActiveLogWithSegments();
    expect(active, isNotNull);
    expect(active!.segments.single.status, 'pending');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('manual timestamp adjustment in commute history page flow', (tester) async {
    appRouter.go('/');
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Timestamp test commute',
        targetStartTime: '08:00',
        targetArrivalTime: '08:30',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Walk segment',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 10,
        ),
      ],
    );

    final start = DateTime(2026, 1, 1, 8, 0);
    final logId = await database.transitDao.startCommute(
      scheduleId: scheduleId,
      segments: (await database.scheduleDao.getScheduleWithSegments(scheduleId))!.segments,
      now: start,
    );
    final segId = (await database.transitDao.getSegmentLogsForLog(logId)).single.id;
    await database.transitDao.boardSegment(segId, now: start);
    await database.transitDao.alightSegment(segId, now: start.add(const Duration(minutes: 10)));
    await database.transitDao.completeCommute(logId, now: start.add(const Duration(minutes: 10)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to logs
    appRouter.go('/logs');
    await tester.pumpAndSettle();

    expect(find.text('Commute history'), findsOneWidget);
    await tester.tap(find.text('Timestamp test commute'));
    await tester.pumpAndSettle();

    expect(find.text('Walk segment'), findsOneWidget);
    expect(find.textContaining('Boarded'), findsOneWidget);
    expect(find.textContaining('Alighted'), findsOneWidget);
    expect(find.textContaining('Actual 10 min'), findsOneWidget);

    // Open segment options menu and select "Adjust board time"
    await tester.tap(find.byTooltip('Segment options'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust board time'), findsOneWidget);
    await tester.tap(find.text('Adjust board time'));
    await tester.pumpAndSettle();

    // In time picker, tap OK (accepts time)
    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Open commute options menu and select "Adjust start time"
    await tester.tap(find.byTooltip('Commute options'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust start time'), findsOneWidget);
    await tester.tap(find.text('Adjust start time'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('active commute adjust start time page flow', (tester) async {
    appRouter.go('/');
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Adjust start commute',
        targetStartTime: '08:00',
        targetArrivalTime: '08:30',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Walk segment',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 10,
        ),
      ],
    );

    final start = DateTime(2026, 1, 1, 8, 0);
    await database.transitDao.startCommute(
      scheduleId: scheduleId,
      segments: (await database.scheduleDao.getScheduleWithSegments(scheduleId))!.segments,
      now: start,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    appRouter.go('/active');
    await tester.pumpAndSettle();

    expect(find.text('Active commute'), findsOneWidget);
    expect(find.textContaining('Started '), findsOneWidget);

    // 1. Open overflow menu and select "Adjust start time"
    await tester.tap(find.byTooltip('Commute options'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust start time'), findsOneWidget);
    await tester.tap(find.text('Adjust start time'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // 2. Board the segment to get board time and test segment options menu
    await tester.tap(find.text('Board Walk'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Boarded '), findsOneWidget);
    await tester.tap(find.byTooltip('Segment options'));
    await tester.pumpAndSettle();

    expect(find.text('Adjust board time'), findsOneWidget);
    await tester.tap(find.text('Adjust board time'));
    await tester.pumpAndSettle();

    expect(find.text('OK'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('transit logs delete commute history page flow', (tester) async {
    appRouter.go('/');
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Delete test commute',
        targetStartTime: '08:00',
        targetArrivalTime: '08:30',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Walk segment',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 10,
        ),
      ],
    );

    final start = DateTime(2026, 1, 1, 8, 0);
    final logId = await database.transitDao.startCommute(
      scheduleId: scheduleId,
      segments: (await database.scheduleDao.getScheduleWithSegments(scheduleId))!.segments,
      now: start,
    );
    final segId = (await database.transitDao.getSegmentLogsForLog(logId)).single.id;
    await database.transitDao.boardSegment(segId, now: start);
    await database.transitDao.alightSegment(segId, now: start.add(const Duration(minutes: 10)));
    await database.transitDao.completeCommute(logId, now: start.add(const Duration(minutes: 10)));

    expect(await database.transitDao.getHistoricalLogs(), hasLength(1));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to logs
    appRouter.go('/logs');
    await tester.pumpAndSettle();

    expect(find.text('Commute history'), findsOneWidget);
    expect(find.text('Delete test commute'), findsOneWidget);

    // Open commute options menu and select "Delete commute"
    await tester.tap(find.byTooltip('Commute options'));
    await tester.pumpAndSettle();

    expect(find.text('Delete commute'), findsOneWidget);
    await tester.tap(find.text('Delete commute'));
    await tester.pumpAndSettle();

    // Confirmation dialog is shown
    expect(find.text('Delete commute history?'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Verify it is removed from UI and database
    expect(find.text('Delete test commute'), findsNothing);
    expect(find.text('No commute history yet'), findsOneWidget);
    expect(await database.transitDao.getHistoricalLogs(), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
