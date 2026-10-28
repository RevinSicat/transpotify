import 'package:drift/drift.dart' show Migrator;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpotify/src/core/database/database.dart';

void main() {
  test('schema upgrade is safe for an existing database', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final scheduleId = await database.scheduleDao.createScheduleWithSegments(
      SchedulesCompanion.insert(
        name: 'Existing commute',
        targetStartTime: '08:00',
        targetArrivalTime: '09:00',
        daysOfWeek: const [1, 2, 3, 4, 5],
      ),
      [],
    );

    await database.migration.onUpgrade(Migrator(database), 1, 2);

    final schedule = await database.scheduleDao.getScheduleById(scheduleId);
    expect(schedule?.name, 'Existing commute');
    expect(await database.scheduleDao.getAllSchedules(), hasLength(1));
  });
}
