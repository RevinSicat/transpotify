import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpotify/src/common/theme/app_colors.dart';
import 'package:transpotify/src/common/widgets/segment_accordion.dart';
import 'package:transpotify/src/core/database/database.dart';
import 'package:transpotify/src/core/database/schedule/dao/schedule_dao.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('expands segments with mode colors and average or estimate', (
    tester,
  ) async {
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Commute',
        targetStartTime: '08:00',
        targetArrivalTime: '09:00',
        daysOfWeek: const [1],
      ),
      [
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Walk to the downtown central station entrance',
          transportMode: 'walk',
          orderIndex: 0,
          estimatedDurationMinutes: 5,
        ),
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Express bus',
          transportMode: 'bus',
          orderIndex: 1,
          estimatedDurationMinutes: 20,
        ),
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Train',
          transportMode: 'train',
          orderIndex: 2,
          estimatedDurationMinutes: 30,
        ),
        ScheduleSegmentsCompanion.insert(
          scheduleId: 0,
          name: 'Unknown mode',
          transportMode: 'hovercraft',
          orderIndex: 3,
          estimatedDurationMinutes: 3,
        ),
      ],
    );
    final schedule = await database.scheduleDao.getScheduleWithSegments(
      scheduleId,
    );
    final segments = [
      SegmentAverage(
        segment: schedule!.segments[0],
        averageMinutes: 4.4,
        sampleCount: 2,
      ),
      SegmentAverage(
        segment: schedule.segments[1],
        averageMinutes: null,
        sampleCount: 0,
      ),
      SegmentAverage(
        segment: schedule.segments[2],
        averageMinutes: 32,
        sampleCount: 1,
      ),
      SegmentAverage(
        segment: schedule.segments[3],
        averageMinutes: null,
        sampleCount: 0,
      ),
    ];

    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SegmentAccordion(
              segments: segments,
              initiallyExpanded: true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Route segments'), findsOneWidget);
    expect(find.text('4 segments · 59 min'), findsOneWidget);
    expect(find.text('Avg. 4 min'), findsOneWidget);
    expect(find.text('Est. 20 min'), findsOneWidget);
    expect(find.text('Avg. 32 min'), findsOneWidget);
    expect(find.text('Est. 3 min'), findsOneWidget);
    expect(find.text('Walk'), findsOneWidget);
    expect(find.text('Bus'), findsOneWidget);
    expect(find.text('Train'), findsNWidgets(2));
    expect(find.text('Hovercraft'), findsOneWidget);
    expect(find.byIcon(Icons.directions_walk), findsOneWidget);
    expect(find.byIcon(Icons.directions_bus), findsOneWidget);
    expect(find.byIcon(Icons.train), findsOneWidget);
    expect(find.byIcon(Icons.directions_transit), findsOneWidget);

    final busIcon = tester.widget<Icon>(find.byIcon(Icons.directions_bus));
    expect(busIcon.color, AppColors.transportModeColor('bus'));
    final trainIcon = tester.widget<Icon>(find.byIcon(Icons.train));
    expect(trainIcon.color, AppColors.transportModeColor('train'));

    final longName = tester.widget<Text>(
      find.text('Walk to the downtown central station entrance'),
    );
    expect(longName.maxLines, 1);
    expect(longName.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an empty state for schedules without segments', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SegmentAccordion(segments: [])),
      ),
    );
    await tester.tap(find.text('Route segments'));
    await tester.pumpAndSettle();

    expect(find.text('No segments'), findsOneWidget);
    expect(find.text('No segments in this schedule yet.'), findsOneWidget);
  });
}
