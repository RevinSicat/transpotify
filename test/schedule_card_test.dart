import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpotify/src/common/utils/common_utilities.dart';
import 'package:transpotify/src/common/widgets/schedule_card.dart';
import 'package:transpotify/src/core/database/database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('renders schedule details and dispatches menu actions', (
    tester,
  ) async {
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'A very long weekday commute schedule title',
        targetStartTime: '08:00',
        targetArrivalTime: '09:00',
        daysOfWeek: const [5, 1, 7],
      ),
      [],
    );
    final schedule = await database.scheduleDao.getScheduleWithSegments(
      scheduleId,
    );
    final actions = <ScheduleCardAction>[];
    var commutePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ScheduleCard(
              schedule: schedule!,
              variance: const DurationVariance(
                expectedMinutes: 60,
                averageMinutes: 42,
                sampleCount: 3,
              ),
              onCommutePressed: (id) => commutePressed = id == scheduleId,
              onActionSelected: actions.add,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Avg. 42 min'), findsOneWidget);
    expect(find.text('18 mins less than expected time'), findsOneWidget);
    expect(find.text('8:00 AM  →  9:00 AM'), findsOneWidget);
    expect(find.text('Mn'), findsOneWidget);
    expect(find.text('Tu'), findsOneWidget);
    expect(find.text('Wd'), findsOneWidget);
    expect(find.text('Th'), findsOneWidget);
    expect(find.text('Fr'), findsOneWidget);
    expect(find.text('Sa'), findsOneWidget);
    expect(find.text('Su'), findsOneWidget);
    final dayLabelTop = tester.getTopLeft(find.text('Mn')).dy;
    for (final day in ['Tu', 'Wd', 'Th', 'Fr', 'Sa', 'Su']) {
      expect(tester.getTopLeft(find.text(day)).dy, dayLabelTop);
    }
    expect(find.text('Start Commute'), findsOneWidget);

    final theme = Theme.of(tester.element(find.text('Mn')));
    final scheduledDayBadge = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Mn'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    final unscheduledDayBadge = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Tu'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    expect(
      (scheduledDayBadge.decoration! as BoxDecoration).color,
      theme.colorScheme.primaryContainer,
    );
    expect(
      (unscheduledDayBadge.decoration! as BoxDecoration).color,
      theme.colorScheme.surfaceContainerHighest,
    );

    final title = tester.widget<Text>(
      find.text('A very long weekday commute schedule title'),
    );
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);

    await tester.tap(find.text('Start Commute'));
    expect(commutePressed, isTrue);

    await tester.tap(find.byTooltip('Schedule options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit schedule'));
    await tester.pumpAndSettle();
    expect(actions, [ScheduleCardAction.edit]);
  });

  testWidgets('shows resume action for the currently active commute', (
    tester,
  ) async {
    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Commute',
        targetStartTime: '08:00',
        targetArrivalTime: '09:00',
        daysOfWeek: const [1],
        isActive: const Value(false),
      ),
      [],
    );
    final schedule = await database.scheduleDao.getScheduleWithSegments(
      scheduleId,
    );
    var commutePressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleCard(
            schedule: schedule!,
            variance: const DurationVariance(
              expectedMinutes: 60,
              averageMinutes: null,
              sampleCount: 0,
            ),
            isCurrentCommute: true,
            onCommutePressed: (id) => commutePressed = id == scheduleId,
            onActionSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Resume Active Commute'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    await tester.tap(find.text('Resume Active Commute'));
    expect(commutePressed, isTrue);
  });
}
