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
}
